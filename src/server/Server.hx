import haxe.crypto.Md5;
import js.Lib;
import meteor.Accounts;
import meteor.Collection.FindOptions;
import meteor.Error;
import meteor.Meteor;
import meteor.packages.npm.Feed;
import meteor.packages.PublishCounts;
import meteor.packages.Roles;
import meteor.Picker;
import model.Articles;
import model.Articles.Article;
import model.Reports;
import model.TagGroups;
import model.Tags;

/**
 * Server
 * @author TiagoLr
 */
class Server {

	public static function main() {
		Shared.init();
		setupPublishes();
		setupPermissions();
		setupHooks();
		setupMethods();
		setupMaintenanceMethods();
		setupAccounts();
		setupEmail();
		setupRss();
		SEO.init();
		
		createAdmin();
		createTagGroups();
		createIndexes();
	}
	
	static private function setupPublishes():Void {
		Meteor.publish(TagGroups.NAME, function() {
			return TagGroups.collection.find({}, {sort:{weight:1}});
		});
		
		Meteor.publish(Tags.NAME, function() {
			return Tags.collection.find();
		});
		
		Meteor.publish(Articles.NAME, function(selector, options) {
			if (selector == null) selector = { }; 	// FIX - calling meteor.subscribe with a parameter set to null causes error
			if (options == null) options = { }; 	// FIX - calling meteor.subscribe with a parameter set to null causes error
			return Articles.collection.find(selector, options);
		});
		
		Meteor.publish('countArticles', function(id:String , selector: { } ) {
			if (selector == null) selector = { }	// FIX - calling meteor.subscribe with a parameter set to null causes error
			PublishCounts.publish(Lib.nativeThis, 'countArticles$id', Articles.collection.find(selector));
		});
		
		Meteor.publish("searchArticles", function(query, options:FindOptions) {
			if (query == null || query == "") {
				return Articles.collection.find({});
			}
			if (options == null) options = { };
			
			options.fields = untyped { score: { '$meta': "textScore" }}; 		// configure fields to include score results
			if (options.sort == null || options.sort.score != null) { 	// if no sorting defined or sorting set to score
				options.sort = { score: { '$meta': "textScore" }}; 			// configure sorting for indexed search score
			}
			
			#if text_search
			return Articles.collection.find( { "$text": { "$search": query } } , options);
			#else
			return Articles.collection.find();
			#end
		});
		
		Meteor.publish(Reports.NAME, function() {
			if (Permissions.isModerator()) {
				return Reports.collection.find();
			} else {
				return null;
			}
		});
	}
	
	static private function setupPermissions():Void {
		
		TagGroups.collection.allow({
			insert: function (_, _) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canInsertTagGroups());
			},
			update: function (_, _, _, _) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canUpdateTagGroups());
			},
			remove: function (_, _) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canRemoveTagGroups());
			}
		});
		
		Articles.collection.allow({
			insert: function (_, _) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canInsertArticles());
			},
			update: function (_, document:Article, fields:Array<Dynamic>, modifier:Dynamic) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canUpdateArticles(document));
			},
			remove: function (_, document:Article) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canRemoveArticles(document));
			}
		});
		
		Reports.collection.allow( {
			insert: function (_, _) {
				Permissions.requireLogin();
				return true;
			},
			remove: function (_, _) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.isModerator());
			}
		});
		
		// remove default user ability to change profile
		Meteor.users.deny( { 
			update: function (_, _, _, _) { 
				return true; 
			}
		});
		
		Meteor.users.allow({
			update: function (_, document:Dynamic, fields:Array<Dynamic>, modifier:Dynamic) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canUpdateUsers(document, fields));
			},
		});
	}
	
	static private function setupHooks():Void {
		Articles.collection.after.insert(function (userId, doc:Article) {
			if (doc.tags == null) doc.tags = [];
			
			for (tagname in doc.tags) {
				Tags.addArticle(tagname, doc._id);
			}
		});
		
		Articles.collection.after.update(function (userId, doc:Article) {
			var prev:Article = untyped Lib.nativeThis.previous;
			
			if (doc.tags == null) doc.tags = [];
			if (prev.tags == null) prev.tags = [];
			
			// increment new tags
			for (tagname in doc.tags) {
				if (prev.tags.indexOf(tagname) == -1) {
					Tags.addArticle(tagname, doc._id);
				}
			}
			
			// decrement removed tags 
			for (tagname in prev.tags) {
				if (doc.tags.indexOf(tagname) == -1) {
					Tags.removeArticle(tagname, doc._id);
				}
			}
		});
		
		Articles.collection.after.remove(function (userId, doc) {
			if (doc.tags == null) doc.tags = [];
			
			var tags:Array<String> = doc.tags;
			for (tagname in tags) {
				Tags.removeArticle(tagname, doc._id);
			}
		});
	}
	
	static private function setupMethods():Void {
		Meteor.methods( {
			
			toggleArticleVote: function (id:String) {
				Permissions.requireLogin();
				if (Articles.collection.findOne( { _id:id } ) == null) {
					var err = Configs.shared.error.args_article_not_found;
					throw new Error(err.code, err.reason, err.details);
				}
				
				var votes:Array<String> = Meteor.user().profile.votes;
				if (votes == null) {
					votes = new Array<String>();
				}
				
				if (votes.indexOf(id) == -1) {
					// add article vote
					votes.push(id);
					Articles.collection.update( { _id:id }, { '$inc': { votes: 1 }}, { getAutoValues:false } );
				} else {
					// remove article vote
					votes.remove(id);
					Articles.collection.update( { _id:id }, { '$inc': { votes: -1 }}, { getAutoValues:false } );
				}
					
				Meteor.users.update({_id: Meteor.userId()}, {'$set': {"profile.votes": votes}}, { getAutoValues:false});
			},
			
			removeUser: function (id:String) {
				Permissions.requireLogin();
				Permissions.requirePermission(Permissions.canRemoveUser(Meteor.users.findOne( { _id:id } )));
				
				var user = Meteor.users.findOne( { _id:id } );
				if (user == null) {
					var err = Configs.shared.error.args_user_not_found;
					throw new Error(err.code, err.reason, err.details);
				}
				
				// remove user votes
				var votes = user.profile.votes;
				if (votes != null && votes.length > 0) {
					for (articleId in votes) {
						Articles.collection.update( { _id:articleId }, { '$dec': { votes: 1 }}, { getAutoValues:false } );
					}
				}
				
				// remove user articles
				Articles.collection.remove( { user:id } );
				Meteor.users.remove( { _id:id } );
			},
		
			transferArticle: function(articleId:String, username:String) {
				Permissions.requireLogin();
				Permissions.requirePermission(Permissions.canTransferArticle());
				
				// verify user args
				var user = Meteor.users.findOne( { username:username } );
				if (user == null) {
					var err = Configs.shared.error.args_user_not_found;
					throw new Error(err.code, err.reason, err.details);
				}
				
				// verify articleId
				var article = Articles.collection.findOne( { _id:articleId } );
				if (article == null) {
					var err = Configs.shared.error.args_article_not_found;
					throw new Error(err.code, err.reason, err.details);
				}
				
				Articles.collection.update( { _id:articleId }, { '$set': { user:user._id, username:username }}, { getAutoValues:false } );
			}
			
		});
	}
	
	/**
	 * Methods used for database maintenance and admin tasks
	 */
	static private function setupMaintenanceMethods():Void {
		Meteor.methods( {
			
			// old fix for tags without articles ids
			updateTagsArticles: function () {
				Permissions.requirePermission(Permissions.isAdmin());
				
				Tags.collection.remove( { } );
				var articles:Array<Article> = cast Articles.collection.find().fetch();
				for (article in articles) {
					for (tagname in article.tags) {
						if (Tags.collection.findOne( { name:tagname } ) == null) {
							Tags.collection.insert( { name:tagname } );
						}
						Tags.addArticle(tagname, article._id);
					}
				}
			},
			
			// old fix for users without profile
			addProfiles: function () {
				Permissions.requirePermission(Permissions.isAdmin());
				Meteor.users.update({profile:{'$exists':false}}, {'$set': {"profile": {}}}, { getAutoValues:false, removeEmptyStrings:false});
			},
			
			setPermissions: function (username:String, permissions:Array<String>) {
				Permissions.requirePermission(Permissions.isAdmin());
				
				// verify user args
				var user = Meteor.users.findOne( { username:username } );
				if (user == null) {
					var err = Configs.shared.error.args_user_not_found;
					throw new Error(err.code, err.reason, err.details);
				}
				
				// verify permission args
				if (permissions == null) {
					var err = Configs.shared.error.args_user_not_found;
					throw new Error(err.code, err.reason, err.details);
				}
				if (!Std.is(permissions, Array)) {
					var err = Configs.shared.error.args_bad_permissions;
					throw new Error(err.code, err.reason, err.details);
				}
				
				// make sure permissions are well set
				for (p in permissions) {
					if (Reflect.field(Permissions.roles, p) == null || p == Permissions.roles.ADMIN) {
						var err = Configs.shared.error.args_bad_permissions;
						throw new Error(err.code, err.reason, err.details);
					}
				}
				
				// make sure is not setting admin permissions
				Permissions.requirePermission(!Roles.userIsInRole(user._id, [Permissions.roles.ADMIN]));
				
				Roles.setUserRoles(user._id, permissions);
			}, 
			
		});
	}
	
	static private function setupAccounts() {
		
		Accounts.onCreateUser(function(options:Dynamic, user:User) {
			if (options.profile != null) {
				user.profile = options.profile;
			}
			
			if (user.services != null) {
				
				// setup a github user account
				if (user.services.github != null) {
					var gh = user.services.github;
					//user.emails = gh.emails;
					var username = gh.username; 
					var i = 1;
					while (Meteor.users.findOne({username:username}) != null) {
						username = gh.username + ' ($i)';
						i++;
					}
					user.username = username;
				} 
				else 
				if (user.services.google != null) {
					var go = user.services.google;
					//user.emails = [ { address:go.email, verified:go.verified_email } ];
					var username = go.name;
					var i = 1;
					while (Meteor.users.findOne({username:username}) != null) {
						username = go.name + ' ($i)';
						i++;
					}
					user.username = username;
				}
				else 
				if (user.services.twitter != null) {
					var tw = user.services.twitter;
					
					var username = tw.screenName;
					var i = 1;
					while (Meteor.users.findOne( { username:username } ) != null) {
						username = tw.screenName + ' ($i)';
						i++;
					}
					user.username = username;
				}
			}
			
			return user;
		});
	}
	
	/**
	 * 
	 */
	static private function setupEmail() {
		Accounts.emailTemplates.siteName = "Haxe Resource";
		Accounts.emailTemplates.from = "Haxe Resource <no-reply@haxeresource.com>";
	}
	
	/**
	 * creates a server route for rss feeds
	 * feeds are generated on request and cached for x minutes defined in the configs file.
	 */
	static private function setupRss() {
		
		// todo remove untyped
		Picker.route('/rss/articles', function(params, req, res, next) {
			var queryGroup = params.query == null ? null : params.query.group;
			var queryTag = params.query == null ? null : params.query.tag;
			
			// if cache exists return cached
			var cached = Cache.getArticleRss({group:queryGroup, tag:queryTag});
			if (cached != null) {
				res.writeHead(200, { 'Content-Type' : 'application/atom+xml' } );
				res.end(cached);
				return;
			}
			
			// fetch tags from request query
			var titleSuffix = "All Articles";
			var tags:Array<String> = null;
			if (queryGroup != null) {
				var group = TagGroups.collection.findOne( { name:queryGroup } );
				tags = [];
				if (group != null) {
					var resolved = Shared.utils.resolveTags(group);
					for (t in resolved) {
						tags.push(t);
					}
					tags.push(group.mainTag);
					titleSuffix = '$queryGroup Group';
				}
			} else if (queryTag != null) {
				tags = [];
				if (Tags.collection.findOne({ name:queryTag }) != null) {
					tags.push(queryTag);
					titleSuffix = '$queryTag Tag';
				}
			}
			
			// initialize feeds
			var feed = new Feed( {
				title: 'HaxeResource $titleSuffix',
				description: 'Articles and tutorials from the haxe community',
				link: Configs.shared.host,
				// todo image
				// todo copyright
				// todo author
			});
			
			// create article selector
			var selector:Dynamic = { };
			selector.created = { '$gte': Date.fromTime(Date.now().getTime() - 1000 * 60 * 60 * 24 * 30) }; // fetch from last 30 days 
			if (tags != null) {
				selector.tags = { '$in': tags };
			}
			
			// add feed for each article in selector
			Articles.collection.find( selector, { sort:{created:-1}} ).forEach(function(doc:Article) {
				feed.addItem({
					title: doc.title,
					link: Configs.shared.host + '/articles/view/' + doc._id + '/' + Shared.utils.formatUrlName(doc.title),
					description: doc.description,
					author: [{
						name: doc.username,
						// todo link
					}],
					date: doc.created,
					// todo image
				});
			});
			
			// cache and send the result
			var output = feed.render('atom-1.0');
			Cache.setArticleRss({group:queryGroup, tag:queryTag}, output);
			res.writeHead(200, { 'Content-Type' : 'application/atom+xml' } );
			res.end(output);
		});
	}
	
	/**
	 * Create admin account if there is none
	 */
	static private function createAdmin():Void {
		if (Meteor.users.findOne( { roles: { '$in':[Permissions.roles.ADMIN] }} ) == null) {
			var pwd = Md5.encode(Std.string(Math.random()));
			trace('creating admin with pw : $pwd');
			var adminId = Accounts.createUser( {
				username:'hxresadmin',
				password:pwd,
				profile:{},
			});
			
			Meteor.users.update( { _id:adminId }, { '$set': { profile: { }}} ); // FIX - possibly not needed
			
			if (adminId != null) {
				Meteor.users.update(adminId, { '$set': { initPwd: pwd }} ); // store initial admin pass in database unencrypted
				Roles.setUserRoles(adminId, [Permissions.roles.ADMIN]);
			} else {
				trace('Error occurred, failed to create admin user account');
			}
		}
	}
	
	/**
	 * Update existing tag groups or create new ones.
	 */
	static private function createTagGroups():Void {
		TagGroups.collection.remove( { } ); // first remove all groups
		
		TagGroups.collection.insert( {
			name: 'Haxe',
			mainTag:'haxe',
			tags: ["~/^haxe-..*$/"], 
			icon:'/img/haxe-logo-50x50.png',
			description: "Haxe syntax, macros, compilation and more.",
			weight:0
		});
		
		TagGroups.collection.insert( {
			name:'Openfl',	
			mainTag:'openfl',
			tags: ["~/^openfl-..*$/"],
			icon:'/img/openfl-logo-50x50.png',
			description: "Openfl and lime frameworks.",
			weight:1
		});
		
		TagGroups.collection.insert( {
			name:'HaxeFlixel',	
			mainTag:'flixel',
			tags: ["~/^flixel-..*$/", "~/^haxeflixel-..*$/"], 
			icon:'/img/haxeflixel-logo-50x50.png',
			description: "Haxe flixel and game development.",
			weight:2
		});
		
		TagGroups.collection.insert( {
			name:'Other',	
			mainTag:'other',
			tags: ["~/^other-..*$/"], 
			icon:'/img/other-logo-50x50.png',
			description: "Other libraries and subjects.",
			weight:3
		});
	}
	
	/**
	 * Setup database indexes
	 */
	static private function createIndexes() {
		Meteor.startup(function() {
			#if text_search
			untyped Articles.collection._ensureIndex( {
				content:'text',
				title: 'text',
				description: 'text',
				tags:'text',
			}, 
			{ name:'article_search_index',
				background:true, 
				weights: {
					title: 10,
					tags: 5,
					description: 3,
					content:1,
				}
			});
			#end
			untyped Articles.collection._ensureIndex( { "user" : 1 } );
			untyped Articles.collection._ensureIndex( { "username" : 1 } );
			untyped Articles.collection._ensureIndex( { "tags": 1 } );
		});
	}
	
}



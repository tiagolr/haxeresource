import haxe.crypto.Md5;
import js.Lib;
import meteor.Accounts;
import meteor.Error;
import meteor.Meteor;
import meteor.packages.PublishCounts;
import meteor.packages.Roles;
import model.Articles;
import model.Articles.Article;
import model.TagGroups;
import model.TagGroups.TagGroup;
import model.Tags;
import model.Tags.Tag;

/**
 * Server
 * @author TiagoLr
 */
class Server {

	public static function main() {
		Shared.init();
		setupPublishes();
		setupPermissions();
		setupCollectionHooks();
		setupMethods();
		setupMaintenanceMethods();
		setupAccounts();
		createAdmin();
		createTagGroups();
	}
	
	static private function setupPublishes():Void {
		Meteor.publish(TagGroups.NAME, function() {
			return TagGroups.collection.find({}, {sort:{weight:1}});
		});
		
		Meteor.publish(Tags.NAME, function() {
			return Tags.collection.find();
		});
		
		Meteor.publish(Articles.NAME, function(selector, options) {
			if (selector == null) selector = { }; // FIX - calling meteor.subscribe with a parameter set to null causes error
			if (options == null) options = { }; // FIX - calling meteor.subscribe with a parameter set to null causes error
			return Articles.collection.find(selector, options);
		});
		
		Meteor.publish('countArticles', function(id:String , selector: { } ) {
			if (selector == null) selector = { }// FIX - calling meteor.subscribe with a parameter set to null causes error
			PublishCounts.publish(Lib.nativeThis, 'countArticles$id', Articles.collection.find(selector));
		});
	}
	
	static private function setupPermissions():Void {
		Tags.collection.allow({
			//insert: function (_, _) {
				//Permissions.requireLogin();
				//return Permissions.requirePermission(Permissions.canInsertTags());
			//},
			//update: function (_, _, _, _) {
				//Permissions.requireLogin();
				//return Permissions.requirePermission(Permissions.canUpdateTags());
			//},
			//remove: function (_, _) {
				//Permissions.requireLogin();
				//return Permissions.requirePermission(Permissions.canRemoveTags());
			//}
		});
		
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
	
	static private function setupCollectionHooks():Void {
		Articles.collection.after.insert(function (userId, doc:Article) {
			if (doc.tags == null) doc.tags = [];
			
			for (tag in doc.tags) {
				Tags.incrementArticleCount(tag);
			}
		});
		
		Articles.collection.after.update(function (userId, doc:Article) {
			var prev:Article = untyped Lib.nativeThis.previous;
			
			if (doc.tags == null) doc.tags = [];
			if (prev.tags == null) prev.tags = [];
			
			// increment new tags
			for (tag in doc.tags) {
				if (prev.tags.indexOf(tag) == -1) {
					Tags.incrementArticleCount(tag);
				}
			}
			
			// decrement removed tags 
			for (tag in prev.tags) {
				if (doc.tags.indexOf(tag) == -1) {
					Tags.decrementArticleCount(tag);
				}
			}
		});
		
		Articles.collection.after.remove(function (userId, doc) {
			if (doc.tags == null) doc.tags = [];
			
			var tags:Array<String> = doc.tags;
			for (tag in tags) {
				Tags.decrementArticleCount(tag);
			}
		});
	}
	
	static private function setupMethods():Void {
		Meteor.methods( {
			
			toggleArticleVote: function (id:String) {
				Permissions.requireLogin();
				if (Articles.collection.findOne( { _id:id } ) == null) {
					var err = Configs.shared.error.args_article_not_found;
					Error.throw_(new Error(err.code, err.reason, err.details));
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
					Error.throw_(new Error(err.code, err.reason, err.details));
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
		
			setPermissions: function (username:String, permissions:Array<String>) {
				Permissions.requirePermission(Permissions.isAdmin());
				
				// verify user args
				var user = Meteor.users.findOne( { username:username } );
				if (user == null) {
					var err = Configs.shared.error.args_user_not_found;
					var error = new Error(err.code, err.reason, err.details);
					Error.throw_(error);
				}
				
				// verify permission args
				if (permissions == null) {
					var err = Configs.shared.error.args_user_not_found;
					Error.throw_(new Error(err.code, err.reason, err.details));
				}
				if (!Std.is(permissions, Array)) {
					var err = Configs.shared.error.args_bad_permissions;
					Error.throw_(new Error(err.code, err.reason, err.details));
				}
				
				// make sure permissions are well set
				for (p in permissions) {
					if (Reflect.field(Permissions.roles, p) == null || p == Permissions.roles.ADMIN) {
						var err = Configs.shared.error.args_bad_permissions;
						Error.throw_(new Error(err.code, err.reason, err.details));
					}
				}
				
				// make sure is not setting admin permissions
				Permissions.requirePermission(!Roles.userIsInRole(user._id, [Permissions.roles.ADMIN]));
				
				Roles.setUserRoles(user._id, permissions);
			}
			
		});
	}
	
	/**
	 * Methods used for database maintenance and migration
	 */
	static private function setupMaintenanceMethods():Void {
		Meteor.methods( {
			
			updateTagsArticleCount: function() {
				
				Articles.collection.update({ tags: null }, {'$set': { tags: [] }}, { multi:true });
				
				Permissions.requirePermission(Permissions.isAdmin());
				var tags:Array<Tag> = cast Tags.collection.find( { } ).fetch();
				for (t in tags) {
					var count = Articles.collection.find(Articles.queryFromTags([t.name])).count();
					Tags.collection.update( { name:t.name }, { '$set': { articleCount: count }} );
					t = Tags.collection.findOne( { name:t.name } );
					if (t.articleCount == 0) {
						Tags.collection.remove( { name:t.name } );
					}
				}
			},
			
			resetProfile: function () {
				Meteor.users.update( { _id:Meteor.userId() }, { '$set': { profile: { }}} );
			}
		});	
	}
	
	static private function setupAccounts() {
		Accounts.onCreateUser(function(options:Dynamic, user:User) {
			if (user.services != null) {
				
				// setup a github user account
				if (user.services.github != null) {
					var gh = user.services.github;
					if (user.profile == null) {
						user.profile = { };
					}
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
					if (user.profile == null) {
						user.profile = { };
					}
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
					if (!user.profile == null) {
						user.profile = { };
					}
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
	
	
	static private function createAdmin():Void {
		if (Meteor.users.findOne( { roles: { '$in':[Permissions.roles.ADMIN] }} ) == null) {
			var pwd = Md5.encode(Std.string(Math.random()));
			trace('creating admin with pw : $pwd');
			var adminId = Accounts.createUser( {
				username:'hxresadmin',
				password:pwd,
				profile:{},
			});
			
			Meteor.users.update( { _id:adminId }, { '$set': { profile: { }}} ); // FIX
			
			if (adminId != null) {
				Meteor.users.update(adminId, { '$set': { initPwd: pwd }} ); // store initial admin pass in database unencrypted
				Roles.setUserRoles(adminId, [Permissions.roles.ADMIN]);
			} else {
				trace('Error occurred, failed to create admin user account');
			}
		}
	}
	
	static private function createTagGroups():Void {
		TagGroups.collection.upsert( { name:'Haxe' }, { '$set' : {
			mainTag:'haxe',
			tags: ["~/^haxe-..*$/"], 
			icon:'/img/haxe-logo-50x50.png',
			weight:0
		}});
		
		TagGroups.collection.upsert( { name:'Openfl' }, { '$set' : {
			mainTag:'openfl',
			tags: ["~/^openfl-..*$/"],
			icon:'/img/openfl-logo-50x50.png',
			weight:1
		}});
		
		TagGroups.collection.upsert( { name:'HaxeFlixel' }, { '$set' : {
			mainTag:'flixel',
			tags: ["~/^flixel-..*$/", "~/^haxeflixel-..*$/"], 
			icon:'/img/haxeflixel-logo-50x50.png',
			weight:2
		}});
		
		TagGroups.collection.upsert( { name:'Other' }, { '$set' : {
			mainTag:'other',
			tags: ["~/^other-..*$/"], 
			icon:'/img/other-logo-50x50.png',
			weight:3
		}});
	}
	
	//-----------------------------------------------
	// AUX
	//-----------------------------------------------
	
}

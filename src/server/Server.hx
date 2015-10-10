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
		
		//-----------------------------------------------
		// Setup publishes
		//-----------------------------------------------
		
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
		
		//-------------------------------------------
		// Setup Permissions
		//-------------------------------------------
		
		Tags.collection.allow({
			insert: function (_, _) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canInsertTags());
			},
			update: function (_, _, _, _) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canUpdateTags());
			},
			remove: function (_, _) {
				Permissions.requireLogin();
				return Permissions.requirePermission(Permissions.canRemoveTags());
			}
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
				return Permissions.requirePermission(Permissions.canUpdateArticles(document, fields));
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
		
		//-----------------------------------------------
		// Define methods
		//-----------------------------------------------
		Meteor.methods( {
			
			toggleArticleVote: function (id:String) {
				Permissions.requireLogin();
				if (Articles.collection.findOne( { _id:id } ) == null) {
					var err = Configs.server.error.ARG_ARTICLE_NOT_FOUND;
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
					var err = Configs.server.error.ARG_USER_NOT_FOUND;
					Error.throw_(new Error(err.code, err.reason, err.details));
				}
				
				// remove user votes
				var votes = user.profile.votes;
				if (votes != null && votes.length > 0) {
					for (articleId in votes) {
						Articles.collection.update( { _id:articleId }, { '$dec': { votes: 1 }}, { getAutoValues:false } );
					}
				}
				
				Meteor.users.remove( { _id:id } );
				
				// TODO
				// remove user articles?
				// remove user comments?
				// remove user tags
			}
		});
		
		//-----------------------------------------------
		
		// create admin account if there is none
		if (Meteor.users.findOne( { roles: { '$in':[Permissions.roles.ADMIN] }} ) == null) {
			var pwd = Md5.encode(Std.string(Math.random()));
			trace('creating admin with pw : $pwd');
			var adminId = Accounts.createUser( {
				username:'hxresadmin',
				password:pwd,
				profile:{},
			});
			
			if (adminId != null) {
				Meteor.users.update(adminId, { '$set': { initPwd: pwd }} ); // store initial admin pass in database unencrypted
				Roles.setUserRoles(adminId, [Permissions.roles.ADMIN]);
			} else {
				trace('Error occurred, failed to create admin user account');
			}
		}
		
		// Create tag groups
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
		
		#if debug
		//-----------------------------------------------
		// Create testing documents
		//-----------------------------------------------
		if (Articles.collection.find().count() == 0) {
			Articles.create({
				title: "Test Haxe Article1",
				description: "Has no link, has content, tags to: haxe-syntax",
				link: "http://www.haxedomain.com",
				content: "This article has some content.", 
				user: "",
				tags: ["haxe-syntax"],
			});
			
			Articles.create({
				title: "Test Haxe Article2",
				description: "Has link, has content, tags to: haxe, haxe-macros",
				link: "http://www.google.com",
				content: "This article has some content.", 
				user: "",
				tags: ["haxe", "haxe-macros"],
			});
			
			Articles.create({
				title: "Test Haxe Article3",
				description: "Has link, has content, tags: none",
				link: "http://www.google.com",
				content: "This article has some content.", 
				user: "",
				tags: ["haxe", "haxe-macros"],
			});
			
			Articles.create({
				title: "Test Openfl Article1",
				description: "Has link, has content, tags: openfl, openfl-gamedev",
				link: "http://www.google.com",
				content: "This article has some content.", 
				user: "",
				tags: ["openfl", "openfl-gamedev"],
			});
			
			Articles.create({
				title: "Test Openfl Article2",
				description: "Has no link, has content, tags: openfl, opEnfl-gaMeDev",
				content: "This article has some content.", 
				user: "",
				tags: ["openfl", "opEnfl-gaMeDev"],
			});
			
			Articles.create({
				title: "Test Openfl Article3",
				description: "Has link, has no content, tags: openfl, openfl-gamedev",
				link: "http://www.google.com",
				user: "",
				tags: ["oPenFl", "openfl-gamedev"],
			});
		}
		#end
	}
}

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
		defineMethods();
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
		Articles.collection.after.update(function () {
			var prev:Article = untyped Lib.nativeThis.previous;
			if (prev.tags != null) {
				for (tag in prev.tags) {
					removeTagIfEmtpy(tag);
				}
			}
		});
		
		Articles.collection.after.remove(function (userId, doc) {
			if (doc != null && doc.tags != null) {
				var tags:Array<String> = doc.tags;
				for (tag in tags) {
					removeTagIfEmtpy(tag);
				}
			}
		});
	}
	
	static private function defineMethods():Void {
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
				
				Meteor.users.remove( { _id:id } );
				
				// TODO
				// remove user articles?
				// remove user comments?
				// remove user tags
			},
			
			removeEmptyTags: function() {
				Permissions.requirePermission(Permissions.isAdmin());
				var tags:Array<Tag> = cast Tags.collection.find( { } ).fetch();
				for (t in tags) {
					removeTagIfEmtpy(t.name);
				}
			},
			
			setPermissions: function (userId:String, permissions:Array<String>) {
				// verify user args
				var user = Meteor.users.findOne( { _id:userId } );
				if (permissions == null) {
					var err = Configs.shared.error.args_user_not_found;
					Error.throw_(new Error(err.code, err.reason, err.details));
				}
				
				// verify permission args
				if (!Std.is(permissions, Array)) {
					var err = Configs.shared.error.args_bad_permissions;
					Error.throw_(new Error(err.code, err.reason, err.details));
				}
				
				// make sure permissions are well set
				for (p in permissions) {
					if (Reflect.field(Permissions.roles, p) == null) {
						var err = Configs.shared.error.args_bad_permissions;
						Error.throw_(new Error(err.code, err.reason, err.details));
					}
				}
				
				Permissions.requirePermission(Permissions.isAdmin());
				Permissions.requirePermission(!Roles.userIsInRole(userId, [Permissions.roles.ADMIN])); // not setting admin permissions
				
				Roles.setUserRoles(userId, permissions);
			}
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
	}
	
	//-----------------------------------------------
	// AUX
	//-----------------------------------------------
	static function removeTagIfEmtpy(tagName:String) {
		if (Articles.collection.findOne(Articles.queryFromTags([tagName])) == null) {
			Tags.collection.remove( { name:tagName } );
		}
	}
	
}

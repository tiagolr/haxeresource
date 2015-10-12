import js.Boot;
import meteor.Accounts;
import meteor.Error;
import meteor.Meteor;
import meteor.packages.Roles;
import model.Articles;
import model.Articles.Article;

/**
 * ...
 * @author TiagoLr
 */
#if (debug && client)
@:expose("Permissions")
#end
class Permissions {

	public static var roles = {
		ADMIN:'ADMIN',
		MODERATOR:'MODERATOR',
	}
	
	public static function requireLogin():Bool {
		if (!isLogged()) {
			var err = Configs.shared.error.not_authorized;
			Error.throw_(new Error(err.code, err.reason, err.details));
		}
		return true;
	}
	
	public static function requirePermission(hasPermission:Bool):Bool {
		if (!hasPermission) {
			var err = Configs.shared.error.no_permission;
			Error.throw_(new Error(err.code, err.reason, err.details));
		}
		return true;
	}

	static public function isLogged():Bool { 
		return Meteor.userId() != null;
	}
	
	static public function isAdmin():Bool {
		return Roles.userIsInRole(Meteor.userId(), [roles.ADMIN]);  
	}
	
	static public function isModerator():Bool {
		return Roles.userIsInRole(Meteor.userId(), [roles.ADMIN, roles.MODERATOR]);
	}
	
	static public function canInsertTags():Bool {
		return isModerator();
	}
	
	static public function canUpdateTags():Bool {
		return isModerator();
	}
	
	static public function canRemoveTags():Bool {
		return isModerator();
	}
	
	static public function canInsertTagGroups():Bool {
		return isModerator();
	}
	
	static public function canUpdateTagGroups():Bool {
		return isModerator();
	}
	
	static public function canRemoveTagGroups():Bool {
		return isModerator();
	}
	
	static public function canInsertArticles():Bool {
		return isLogged();
	}
	
	static public function canUpdateArticles(document:Article):Bool {
		return	isModerator() || Articles.isOwner(document); // moderators and owners can edit article
	}
	
	static public function canRemoveArticles(document:Article):Bool {
		return isModerator() || Articles.isOwner(document); // moderators and owners can remove article
	}
	
	static public function canUpdateUsers(document:Dynamic, fields:Array<Dynamic>):Bool {
		return isAdmin();
	}
	
	static public function canRemoveUser(document:Dynamic):Bool {
		return isAdmin();
	}
	
}
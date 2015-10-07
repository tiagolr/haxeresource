import model.Articles;
import model.TagGroups;
import model.Tags;

/**
 * Shared
 * @author TiagoLr
 */
#if (debug && client)
@:expose("Shared")
#end
class Shared {

	public static var utils:SharedUtils = new SharedUtils();
	//public static var permissions:Permissions = new Permissions();
	
	public static function init() {
		new TagGroups();
		new Articles();
		new Tags();
		
		untyped Articles.collection.attachSchema(Articles.schema);
		untyped Tags.collection.attachSchema(Tags.schema);
		untyped TagGroups.collection.attachSchema(TagGroups.schema);
	}
	
}
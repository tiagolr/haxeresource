import model.Articles;
import model.TagGroups;
import model.Tags;

/**
 * Shared
 * @author TiagoLr
 */
class Shared {

	public static var utils:SharedUtils = new SharedUtils();
	
	public static function init() {
		new TagGroups();
		new Articles();
		new Tags();
		
		#if (server || debug)
		untyped Articles.collection.attachSchema(Articles.schema);
		untyped Tags.collection.attachSchema(Tags.schema);
		untyped TagGroups.collection.attachSchema(TagGroups.schema);
		#end
	}
	
}
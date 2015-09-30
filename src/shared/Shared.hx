import model.Articles;
import model.TagGroups;
import model.Tags;

using Lambda;
/**
 * Shared
 * @author TiagoLr
 */
class Shared {

	public static function init() {
		new TagGroups();
		new Articles();
		new Tags();
		
		Tags.collection.allow({
			insert: function (name) {
				return true;
			}
		});
		
		#if (server || debug)
		untyped Articles.collection.attachSchema(Articles.schema);
		untyped Tags.collection.attachSchema(Tags.schema);
		untyped TagGroups.collection.attachSchema(TagGroups.schema);
		#end
	}
	
	// return tag names that belong to a TagGroup
	static public function resolveTags(g:TagGroup):Array<String> {
		var tags = Tags.collection.find().fetch();
		var resolved = new Array<String>();
		
		for (entry in g.tags) {
			if (StringTools.startsWith(entry, '~')) {
				var split = entry.split('/');
				var reg = new EReg(split[1], split[2]);
				
				for (t in tags) {
					if (reg.match(t.name) && !resolved.has(t.name)) { 
						resolved.push(t.name);
					}
				}
				
			} else { // if selector is not a regex, find an exact match
				for (t in tags) { 
					if (t.name == entry && !resolved.has(t.name)) {
						resolved = [t.name];
						break;
					}
				}
			}
		}
		
		return resolved;
	}
	
}
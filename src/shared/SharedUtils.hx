import haxe.crypto.Md5;
import model.TagGroups.TagGroup;
import model.Tags;

using Lambda;
/**
 * ...
 * @author TiagoLr
 */
class SharedUtils{

	public function new() { }

	public function objectToHash(o: { } ):String {
		var str = Std.string(o);
		return Md5.encode(str);
	}
	
	// return tag names that belong to a TagGroup
	public function resolveTags(g:TagGroup):Array<String> {
		var tags = Tags.collection.find().fetch();
		var resolved:Array<String> = new Array<String>();
		
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
		
		// finaly sort tags by name
		resolved.sort(function(a:String, b:String) {
			if (a < b) return -1;
			if (a > b) return 1;
			return 0;
		});
		
		return resolved;
	}
	
}
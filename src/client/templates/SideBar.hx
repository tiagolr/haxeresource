package templates;
import meteor.Template;
import model.TagGroups;
import model.TagGroups.TagGroup;
import model.Tags;
import model.Tags.Tag;

/**
 * ...
 * @author TiagoLr
 */
class SideBar{

	static public function init() {
		Template.get('sidebar').helpers( {
			
			tag_groups:function() {
				var tags:Array<Tag> = cast Tags.collection.find().fetch();
				var groups:Array<TagGroup> = cast TagGroups.collection.find().fetch();
				
				// resolve each group tags from tag names and regular expressions
				for (g in groups) {
					var resolvedTags = [];
					for (t in g.tags) {
						var res = resolveTags(t, tags);
						for (r in res) {
							r.name = formatTagName(r.name);
							if (resolvedTags.indexOf(r) == -1) {
								resolvedTags.push(r);
							}
						}
					}
					untyped g.tags = resolvedTags;
				}
				
				return groups;
			}
			
		});
	}
	
	// return existing tag names from name or regular expression
	static public function resolveTags(strOrRegex:String, tags:Array<Tag>) {
		var resolved = new Array<Tag>();
		
		if (StringTools.startsWith(strOrRegex, '~')) {
			var split = strOrRegex.split('/');
			var reg = new EReg(split[1], split[2]);
			
			for (t in tags) {
				if (reg.match(t.name)) { 
					resolved.push(t);
				}
			}
			
		} else {
			for (t in tags) {
				if (t.name == strOrRegex) {
					resolved = [t];
					break;
				}
			}
		}
		
		return resolved;
	}
	
	static function formatTagName(tag:String):String {
		var split = tag.split('-');
		if (split.length > 1) {
			split.shift();
			tag = split.join('-');
		}
		if (tag.length < 2) 
			return tag; // bug prevention
		
		return tag.substr(0, 1).toUpperCase() + tag.substr(1); // first letter uppercase
	}
	
}
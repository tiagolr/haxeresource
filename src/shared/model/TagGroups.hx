package model;
import meteor.Collection;
import meteor.packages.SimpleSchema;

typedef TagGroup = {
	?_id:String,
	name:String,
	?icon:String,
	?description:String,
	tags:Array<String>, // tag names or regexes (eg: ~/.*/i)
	mainTag:String,
}
/**
 * Categories
 * @author TiagoLr
 */
class TagGroups extends Collection {

	public static inline var NAME = 'tag_groups';
	public static var schema(default, null):SimpleSchema;

	public static var collection(default,null):TagGroups;
	public function new() {
		super(NAME);
		collection = this;
		schema = new SimpleSchema({
			name: {
				type: String,
				unique: true,
			},
			mainTag: {
				type: String,
				max:Tags.MAX_CHARS,
			},
			tags: {
				optional: true,
				type: [String],
			}
		});
	}
	
	public static function create(tagGroup:TagGroup):TagGroup {
		TagGroups.collection.insert(tagGroup);
		return tagGroup;
	}
	
}
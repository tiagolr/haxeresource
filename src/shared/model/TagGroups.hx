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
	?weight:Int,
	?resolvedTags:Array<{name:String, formattedName:String}>, // client only: contains the tags resolved by their regular expressions
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
			weight: {
				type: untyped Number,
				defaultValue: 10,
			},
			icon: {
				type:String
			},
			tags: {
				optional: true,
				type: [String],
			}
		});
	}
	
}
package model;
import meteor.Collection;

typedef TagGroup = {
	?_id:String,
	name:String,
	?icon:String,
	?description:String,
	tags:Array<String>,
}
/**
 * Categories
 * @author TiagoLr
 */
class TagGroups extends Collection {

	public static inline var NAME = 'tag_groups';

	public static var collection(default,null):TagGroups;
	public function new() {
		super(NAME);
		collection = this;
	}
	
	public static function create(tagGroup:TagGroup):TagGroup {
		TagGroups.collection.insert(tagGroup);
		return tagGroup;
	}
	
}
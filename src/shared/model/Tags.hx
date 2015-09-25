package model;
import meteor.Collection;

typedef Tag = {
	?_id:String,
	name:String,
}
/**
 * Categories
 * @author TiagoLr
 */
class Tags extends Collection {

	public static inline var NAME = 'tags';
	
	public static var collection(default, null):Tags;
	public function new() {
		super(NAME);
		collection = this;
	}
	
	public static function create(tag:Tag):Tag {
		collection.insert(tag);
		return tag;
	}
	
}
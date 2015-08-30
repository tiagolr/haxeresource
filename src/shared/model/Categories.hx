package model;
import meteor.Collection;

typedef Category = {
	name:String,
	description:String,
	icon:String,
	parentId:String
}
/**
 * Categories
 * @author TiagoLr
 */
class Categories extends Collection{

	public static var collection:Categories;
	public function new() {
		super('categories');
		collection = this;
	}
	
	public static function create(name:String, ?description:String, ?icon:String, ?parentId:String) {
		return {
			name:name,
			description:description,
			icon:icon,
			parentId:parentId
		}
	}
	
}
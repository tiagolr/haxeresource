package model;
import js.Lib;
import js.RegExp;
import meteor.Collection;
import meteor.packages.SimpleSchema;

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
	public static var regEx(default, null):RegExp;
	public static var schema(default, null):SimpleSchema;
	
	public static var collection(default, null):Tags;
	public function new() {
		super(NAME);
		collection = this;
		regEx = new RegExp('^[a-zA-Z0-9._-]+$');
		schema = new SimpleSchema({
			name: {
				type: String,
				unique:true,
				regEx:regEx,
				max:40,
				autoValue: function() { 
					if (SchemaCtx.field('name').isSet) {
						return cast(SchemaCtx.field('name').value, String).toLowerCase();
					}
					return Lib.undefined;
				}
				
			},
		});
	}
	
	public static function create(tag:Tag):String {
		tag.name = tag.name.toLowerCase();
		return collection.insert(tag);
	}
	
	static public function getOrCreate(name:String):Tag {
		name = name.toLowerCase();
		var exists = collection.findOne( { name:name } );
		if (exists == null) {
			var newTag = create( { name:name } );
			exists = collection.findOne( { _id:newTag } );
		}
		
		return exists == null ? null : { _id:exists._id, name:exists.name };
	}
	
}
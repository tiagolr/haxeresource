package model;
import js.Lib;
import js.RegExp;
import meteor.Collection;
import meteor.packages.SimpleSchema;

typedef Tag = {
	?_id:String,
	?articleCount:Int,
	name:String,
}
/**
 * Categories
 * @author TiagoLr
 */
class Tags extends Collection {

	public static inline var NAME = 'tags';
	public static inline var MAX_CHARS = 30;
	
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
				max:MAX_CHARS,
				autoValue: function() { 
					if (SchemaCtx.field('name').isSet) {
						return format(cast(SchemaCtx.field('name').value, String));
					}
					return Lib.undefined;
				}
			},
			articleCount: {
				type: 'Number',
				optional: true,
				autoValue: function () {
					if (SchemaCtx.isInsert) {
						return 0; // tags are created on new article
					}
					return Lib.undefined;
				}
			}
		});
	}
	
	static public function format(name:String):String {
		name = name.toLowerCase();
		if (!regEx.test(name)) {
			return null;
		}
		return name;
	}
	
	static public function getOrCreate(name:String):Tag {
		name = format(name);
		var exists = collection.findOne( { name:name } );
		if (exists == null) {
			var newTag = collection.insert( { name:name } );
			exists = collection.findOne( { _id:newTag } );
		}
		return exists;
	}
	
	#if server
	static public function incrementArticleCount(name:String) {
		collection.update( { name:name }, { '$inc': { articleCount: 1} });
	}
	
	static public function decrementArticleCount(name:String) {
		collection.update( { name:name }, { '$inc': { articleCount: -1 } } );
		if (collection.findOne( { name:name } ).articleCount == 0) {
			collection.remove( { name:name } ); // remove empty tags
		}
	}
	#end
	
	
}
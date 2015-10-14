package model;
import js.Lib;
import js.RegExp;
import meteor.Collection;
import meteor.packages.SimpleSchema;

typedef Tag = {
	?_id:String,
	?articles:Array<String>,
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
			articles: {
				type: [String],
				optional: true,
				autoValue: function () {
					if (SchemaCtx.isInsert) {
						return [];
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
	static public function addArticle(tagname:String, articleId:String) {
		if (collection.findOne( { name:tagname } ).articles == null) {
			collection.update( { name:tagname }, { '$push': { articles:articleId } });
		}
		collection.update( { name:tagname }, { '$addToSet': { articles:articleId }} );
	}
	
	static public function removeArticle(tagname:String, articleId:String) {
		collection.update( { name:tagname }, { '$pull': { articles:articleId }} );
		var tag = collection.findOne( { name:tagname } );
		if (tag.articles == null || tag.articles.length <= 0) {
			collection.remove( { name:tagname } );
		}
	}
	#end
	
	
}
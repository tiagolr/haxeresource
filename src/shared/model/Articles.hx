package model;
import js.Lib;
import meteor.Collection;
import meteor.packages.AutoForm;
import meteor.packages.SimpleSchema;

typedef Article = {
	?_id:String,
	title:String,
	description:String,
	?link:String,
	?content:String,
	?comments:Array<{message:String, user:String}>,
	?upvotes:Int,
	?downvotes:Int,
	user:String,
	?created:Date,
	?modified:Date,
	?tags:Array<String>,
}

/**
 * Articles
 * @author TiagoLr
 */
class Articles extends Collection {
	
	public static inline var NAME = 'articles';

	public static var schema(default, null):SimpleSchema;
	public static var collection(default, null):Articles;
	
	public function new() {
		super(NAME);
		collection = this;
		schema = new SimpleSchema({
			title: {
				type: String,
				max:100,
			},
			description: {
				type:String,
				max:512
			},
			link: {
				type:String,
				max:512,
				optional:true,
				regEx: SimpleSchema.RegEx.Url,
				autoform: {
					afFieldInput: {
						type: "url"
					}
				},
				custom: function() {
					if (!SchemaCtx.field('link').isSet && !SchemaCtx.field('content').isSet) {
						return "eitherArticleOrLink";
					}
					return Lib.undefined;
				}
			},
			content: {
				type:String,
				max:30000,
				optional:true,
				custom: function() {
					if (!SchemaCtx.field('link').isSet && !SchemaCtx.field('content').isSet) {
						return "eitherArticleOrLink";
					}
					return Lib.undefined;
				}
			},
			tags: {
				type:[String],
				optional:true,
				autoform: {
					type: 'tags',
					afFieldInput: {
						maxTags:10,
						maxChars:30,
					}
				},
				autoValue: function() {
					// if tag does not exist create it
					if (SchemaCtx.field('tags').isSet) {
						var tags:Array<Dynamic> = SchemaCtx.field('tags').value;
						var resolved = new Array<String>();
						for (t in tags) {
							var res = Tags.getOrCreate(t);
							if (res != null) {
								resolved.push(res.name);
							}
						}
						return resolved;
					}
					return Lib.undefined;
				}
			},
			user: {
				type: String,
				optional:true,
				autoValue: function () {
					return SchemaCtx.userId;
				}
			},
			upvotes: {
				type: untyped Number,
				defaultValue: 0,
			},
			created: {
				type:Date,
				optional:true,
				autoValue: function() {
					if (SchemaCtx.isInsert) {
						return Date.now();
					} else {
						SchemaCtx.unset();
						return Lib.undefined; // TODO - verify if created is not modified by returning null
					}
				}
			},
			modified: {
				type:Date,
				optional:true,
				autoValue: function() {
					return Date.now();
				},
			},
		});
	}
	
	#if server
	public static function create(article:Article):Article {
		if (article.comments == null)
			article.comments = [];
			
		if (article.upvotes == null) {
			article.upvotes = 0;
		}
		
		if (article.downvotes == null) {
			article.downvotes = 0;
		}
		
		article.created = Date.now();
		article.modified = Date.now();
		
		Articles.collection.insert(article);
		return article;
	}
	#end
	
}
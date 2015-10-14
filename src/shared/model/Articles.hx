package model;
import js.Lib;
import meteor.Accounts;
import meteor.Collection;
import meteor.Meteor;
import meteor.packages.AutoForm;
import meteor.packages.SimpleSchema;
import model.Articles.Article;

typedef Article = {
	?_id:String,
	title:String,
	description:String,
	?link:String,
	?content:String,
	user:String,
	?votes:Int,
	?username:String,
	?created:Date,
	?modified:Date,
	?editedBy:String,
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
						maxChars:Tags.MAX_CHARS,
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
					if (SchemaCtx.isInsert) {
						return Meteor.userId();
					} else {
						SchemaCtx.unset();
						return Lib.undefined;
					}
				}
			},
			username: {
				type: String,
				optional:true,
				autoValue: function () {
					if (SchemaCtx.isInsert && Meteor.user() != null) {
						return Meteor.user().username;
					} else {
						SchemaCtx.unset();
						return Lib.undefined;
					}
				}
			},
			votes: {
				type: untyped Number,
				optional:true,
				autoValue: function () {
					if (SchemaCtx.isInsert) {
						return 0;
					} else {
						SchemaCtx.unset();
						return Lib.undefined;
					}
				}
			},
			created: {
				type:Date,
				optional:true,
				autoValue: function() {
					if (SchemaCtx.isInsert) {
						return Date.now();
					} else {
						SchemaCtx.unset();
						return Lib.undefined;
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
			editedBy: { 
				type:String,
				optional:true,
				autoValue: function() {
					return Meteor.userId();
				},
			}
		});
	}
	
	#if server
	public static function create(article:Article):Article {
		Articles.collection.insert(article);
		return article;
	}
	#end
	
	static public function isOwner(document:Article) {
		return document.user != null && Meteor.userId() != null && document.user == cast Meteor.userId();
	}
	
	public static function queryFromTags(_tags:Array<String>): { } {
		return { tags: { '$in':_tags }}
	}
	
}
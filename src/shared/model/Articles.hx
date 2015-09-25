package model;
import meteor.Collection;
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
	tags:Array<String>,
}

/**
 * Articles
 * @author TiagoLr
 */
class Articles extends Collection {
	
	public static inline var NAME = 'articles';

	public static var collection(default, null):Articles;
	public function new() {
		super(NAME);
		collection = this;
	}
	
	public static function create(article:Article):Article {
		var resolvedTags = [];
		for (tag in article.tags) {
			var t = Tags.collection.findOne( { name:tag } );
			if (t != null) {
				resolvedTags.push(t._id);
			} else {
				var created = Tags.create({name:tag});
				if (created != null) {
					resolvedTags.push(created._id);
				}
			}
		}
		
		article.tags = resolvedTags;
		
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
	
}
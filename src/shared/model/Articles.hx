package model;
import meteor.Collection;
import meteor.packages.SimpleSchema;
typedef Article = {
	title:String,
	description:String,
	link:String,
	contents:String,
	categoryId:String,
	comments:Int,
	upvotes:Int,
	downvotes:Int,
	user:String,
	created:Date,
	modified:Date,
}

/**
 * Articles
 * @author TiagoLr
 */
class Articles extends Collection {

	public static var collection:Articles;
	public function new() {
		super('articles');
		collection = this;
	}
	
	public static function create(title:String, description:String, ?link:String, ?contents:String, categoryId:String, user:String) {
		return {
			title:title,
			description:description,
			link:link,
			contents:contents,
			categoryId:categoryId,
			upvotes:0,
			downvotes:0,
			comments:0,
			created:Date.now(),
			modified:Date.now(),
			user:user
		}
	}
	
}
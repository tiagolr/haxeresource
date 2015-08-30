import meteor.Meteor;
import model.Articles;
import model.Categories;

/**
 * Server
 * @author TiagoLr
 */
class Server {

	public static function main() {
		Shared.init();
		
		Meteor.publish("categories", function() {
			return Categories.collection.find();
		});
		
		Meteor.publish("articles", function() {
			return Articles.collection.find();
		});
		
		/**
		 * Create testing categories
		 */
		if (Categories.collection.find().count() == 0) {
			trace("Creating dummy categories");
			var id1 = Categories.collection.insert(Categories.create("testCat1"));
			var id2 = Categories.collection.insert(Categories.create("testCat2",null,null,id1));
			var id3 = Categories.collection.insert(Categories.create("testCat3"));
		}
		
		/**
		 * Create test articles
		 */
		if (Articles.collection.find().count() == 0) {
			trace("Creating dummy articles");
			Articles.collection.insert(Articles.create(
				"Test Article1",
				"This is the first article Description",
				"http://www.haxedomain.com",
				"This is the article content, nothing special of course", 
				Categories.collection.findOne( { name:"testCat2" } )._id,
				"tempUserId"
			));
			
			Articles.collection.insert(Articles.create(
				"Test Article2",
				"This is the second article Description",
				"http://www.haxedomain.com",
				"This is the article content, nothing special of course", 
				Categories.collection.findOne( { name:"testCat2" } )._id,
				"tempUserId"
			));
		}
	}
}

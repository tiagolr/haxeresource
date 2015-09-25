import meteor.Meteor;
import model.Articles;
import model.TagGroups;
import model.Tags;

/**
 * Server
 * @author TiagoLr
 */
class Server {

	public static function main() {
		Shared.init();
		
		Meteor.publish(TagGroups.NAME, function() {
			return TagGroups.collection.find();
		});
		
		Meteor.publish(Tags.NAME, function() {
			return Tags.collection.find();
		});
		
		Meteor.publish(Articles.NAME, function() {
			return Articles.collection.find();
		});
		
		// Test tags
		if (Tags.collection.find().count() == 0) {
			trace("Creating dummy tags");
			Tags.create({name:'haxe-fuck'});
			Tags.create({name:'haxe-tits'});
			Tags.create({name:'haxe-mom'});
		}
		
		// Test tag groups
		if (TagGroups.collection.find().count() == 0) {
			trace("Creating dummy tag groups");
			TagGroups.create({name:'haxe', tags: ['haxe', '~/haxe-.*/'] });
		}
		
		// Test articles
		if (Articles.collection.find().count() == 0) {
			trace("Creating dummy articles");
			Articles.create({
				title: "Test Article1",
				description: "This is the first article Description",
				link: "http://www.haxedomain.com",
				content: "This is the article content, nothing special of course", 
				user: "",
				tags: ["haxe-fuck"],
			});
			
			Articles.create({
				title: "Test Article2",
				description: "This is the second article Description",
				link: "http://www.haxedomain.com",
				content: "This is the article content, nothing special of course", 
				user: "",
				tags: ["haxe-tits"],
			});
		}
	}
}
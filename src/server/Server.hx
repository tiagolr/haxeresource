import js.Lib;
import meteor.Meteor;
import meteor.packages.PublishCounts;
import model.Articles;
import model.TagGroups;
import model.TagGroups.TagGroup;
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
		
		Meteor.publish(Articles.NAME, function(selector, options) {
			return Articles.collection.find(selector, options);
		});
		
		Meteor.publish('countArticles', function() {
			PublishCounts.publish(Lib.nativeThis, 'countArticles', Articles.collection.find());
		});
		
		Meteor.publish('countArticlesTag', function (tagName:String) {
			var tag = Tags.collection.findOne({name : tagName});
			if (tag != null) {
				PublishCounts.publish(Lib.nativeThis, 'countArticlesTag$tagName', Articles.collection.find( { tags: { '$in':[tagName] }} ));
			}
		});
		
		Meteor.publish('countArticlesGroup', function (name:String) {
			var group:TagGroup = TagGroups.collection.findOne( { name:name } );
			if (group != null) {
				var tags = Shared.resolveTags(group);
				tags.push(group.mainTag);
				PublishCounts.publish(Lib.nativeThis, 'countArticlesGroup${group.name}', Articles.collection.find( { tags: { '$in':tags }} ));
			}
		});
		
		// Test tag groups
		if (TagGroups.collection.find().count() == 0) {
			TagGroups.create({name:'Haxe', mainTag:'haxe', tags: ['~/haxe-.*/'] });
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

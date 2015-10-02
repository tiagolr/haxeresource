import js.Lib;
import meteor.Meteor;
import meteor.packages.PublishCounts;
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
		
		Meteor.publish(Articles.NAME, function(selector, options) {
			if (selector == null) selector = { }; // FIX - calling meteor.subscribe with a parameter set to null causes error
			if (options == null) options = { }; // FIX - calling meteor.subscribe with a parameter set to null causes error
			return Articles.collection.find(selector, options);
		});
		
		Meteor.publish('countArticles', function(id:String , selector: { } ) {
			if (selector == null) selector = { }// FIX - calling meteor.subscribe with a parameter set to null causes error
			PublishCounts.publish(Lib.nativeThis, 'countArticles$id', Articles.collection.find(selector));
		});
		
		
		Tags.collection.allow({
			insert: function (name) {
				return true;
			}, 
		});
		
		#if debug
		
		// Test tag groups
		if (TagGroups.collection.find().count() == 0) {
			TagGroups.create({name:'Haxe', mainTag:'haxe', tags: ["~/^haxe-..*$/"] });
			TagGroups.create({name:'Openfl', mainTag:'openfl', tags: ["~/^openfl-..*$/"] });
		}
		
		// Test articles
		if (Articles.collection.find().count() == 0) {
			Articles.create({
				title: "Test Haxe Article1",
				description: "Has no link, has content, tags to: haxe-syntax",
				link: "http://www.haxedomain.com",
				content: "This article has some content.", 
				user: "",
				tags: ["haxe-syntax"],
			});
			
			Articles.create({
				title: "Test Haxe Article2",
				description: "Has link, has content, tags to: haxe, haxe-macros",
				link: "http://www.google.com",
				content: "This article has some content.", 
				user: "",
				tags: ["haxe", "haxe-macros"],
			});
			
			Articles.create({
				title: "Test Haxe Article3",
				description: "Has link, has content, tags: none",
				link: "http://www.google.com",
				content: "This article has some content.", 
				user: "",
				tags: ["haxe", "haxe-macros"],
			});
			
			Articles.create({
				title: "Test Openfl Article1",
				description: "Has link, has content, tags: openfl, openfl-gamedev",
				link: "http://www.google.com",
				content: "This article has some content.", 
				user: "",
				tags: ["openfl", "openfl-gamedev"],
			});
			
			Articles.create({
				title: "Test Openfl Article2",
				description: "Has no link, has content, tags: openfl, opEnfl-gaMeDev",
				content: "This article has some content.", 
				user: "",
				tags: ["openfl", "opEnfl-gaMeDev"],
			});
			
			Articles.create({
				title: "Test Openfl Article3",
				description: "Has link, has no content, tags: openfl, openfl-gamedev",
				link: "http://www.google.com",
				user: "",
				tags: ["oPenFl", "openfl-gamedev"],
			});
		}
		
		#end
	}
}

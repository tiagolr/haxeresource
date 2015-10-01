import haxe.DynamicAccess;
import js.Browser;
import meteor.Meteor;
import meteor.packages.AutoForm;
import meteor.packages.FlowRouter;
import meteor.packages.SimpleSchema;
import model.Articles;
import model.TagGroups;
import model.Tags;
import templates.ListArticles;
import templates.Navbar;
import templates.NewArticle;
import templates.SideBar;
import templates.ViewArticle;

/**
 * Client
 * @author TiagoLr
 */
class Client {
	
	static public var utils = new ClientUtils();
	
	static var preloadReqs = {
		tagGroups:false,
	}
	
	public static function main() {
		Shared.init();

		untyped Browser.window.tags = untyped Tags.collection;
		untyped Browser.window.articles = untyped Articles.collection;
		untyped Browser.window.groups = untyped TagGroups.collection;

		Meteor.subscribe(Tags.NAME);
		Meteor.subscribe(TagGroups.NAME, { onReady : function() { preloadReqs.tagGroups = true; checkPreload(); }} );
		utils.subscribeCountArticles(); // subscribe to count all articles	
		
		Navbar.init();
		SideBar.init();
		ListArticles.init();
		NewArticle.init();
		ViewArticle.init();
		
		FlowRouter.wait();
		Router.init();
		
		// schema custom error messages
		SimpleSchema.messages_({eitherArticleOrLink: "An article must link to an external resource, or have embed contents, or both."});
		
		// initialize markdown
		untyped marked.setOptions({
			 highlight: function (code) {
				return hljs.highlightAuto(code).value;
			}
		});
		
		#if debug
		AutoForm.debug();
		#end
	}
	
	static function checkPreload() {
		var reqs : DynamicAccess<Bool> = preloadReqs;
		for (req in reqs.keys()) {
			if (reqs[req] != true) {
				return;
			}
		}
		
		// all requirements are ready
		FlowRouter.initialize();
	}

}

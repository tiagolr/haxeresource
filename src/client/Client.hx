import js.Browser;
import meteor.Meteor;
import meteor.packages.AutoForm;
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
	
	public static function main() {
		Shared.init();

		untyped Browser.window.tags = untyped Tags.collection;
		untyped Browser.window.articles = untyped Articles.collection;
		untyped Browser.window.groups = untyped TagGroups.collection;

		Meteor.subscribe(Tags.NAME);
		Meteor.subscribe(TagGroups.NAME);
		Meteor.subscribe(Articles.NAME, {sort: {created:-1}, limit: 5});
		
		Navbar.init();
		SideBar.init();
		ListArticles.init();
		NewArticle.init();
		ViewArticle.init();
		
		CRouter.init();
		
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

}

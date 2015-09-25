import js.Browser;
import meteor.Meteor;
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

		untyped Browser.window.tags = untyped Tags.collection._collection;
		untyped Browser.window.articles = untyped Articles.collection._collection;
		untyped Browser.window.groups = untyped TagGroups.collection._collection;

		Meteor.subscribe(Tags.NAME);
		Meteor.subscribe(TagGroups.NAME);
		Meteor.subscribe(Articles.NAME);
		
		Navbar.init();
		SideBar.init();
		ListArticles.init();
		NewArticle.init();
		ViewArticle.init();
		
		CRouter.init();
		
		// initialize markdown
		untyped marked.setOptions({
			 highlight: function (code) {
				return hljs.highlightAuto(code).value;
			}
		});
		
	}

}

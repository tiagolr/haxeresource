import js.Browser;
import js.JQuery;
import meteor.Meteor;
import meteor.packages.Router;
import meteor.Session;
import meteor.Template;
import model.Articles;
import model.Categories;
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

		untyped Browser.window.categories = untyped Categories.collection._collection;
		untyped Browser.window.articles = untyped Articles.collection._collection;

		Meteor.subscribe('categories');
		Meteor.subscribe('articles');
		
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

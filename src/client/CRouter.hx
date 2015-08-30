import js.Browser;
import meteor.packages.Router;
import meteor.Session;
import templates.ListArticles;
import templates.NewArticle;
import templates.ViewArticle;
/**
 * ...
 * @author TiagoLr
 */
class CRouter {

	static inline var FADE_DURATION = 500;
	
	static public function init() {
		
		Router.configure( {
			//layoutTemplate:'layout',
			loadingTemplate:'preload',
		});
		
		Router.route('/', function() {
			ListArticles.page.show(FADE_DURATION);
		}, {
			onStop: function () {
				ListArticles.page.hide(FADE_DURATION);
			}
		});
		
		Router.route("/new", function() {
			NewArticle.page.show(FADE_DURATION);
		}, {
			onStop: function () {
				NewArticle.page.hide(FADE_DURATION);
			},
		});
		
		Router.route("/view", function () {
			ViewArticle.page.show();
		}, {
			onStop: function () {
				ViewArticle.page.hide();
			}
		});
		
	}
	
}
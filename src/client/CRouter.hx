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

	static public inline var FADE_DURATION = 500;
	
	static public function init() {
		
		Router.configure( {
			//layoutTemplate:'layout',
			loadingTemplate:'preload',
		});
		
		Router.route('/', function() {
			ListArticles.show(null, null, {});
		}, {
			onStop: function () {
				ListArticles.hide();
			}
		});
		
		Router.route('/tag/:_name', function() {
			var tag = RouterCtx.params._name;
			ListArticles.show(null, null, { tags: { '$in':[tag] }} );
		}, {
			onStop: function() {
				ListArticles.hide();
			}
		});
		
		Router.route("/new", function() {
			NewArticle.page.show(FADE_DURATION);
		}, {
			onStop: function () {
				NewArticle.page.hide(FADE_DURATION);
			},
		});
		
		Router.route("/view/:_id", function () {
			var id = RouterCtx.params._id;
			ViewArticle.show(id);
		}, {
			onStop: function () {
				ViewArticle.page.hide();
			}
		});
		
	}
	
}
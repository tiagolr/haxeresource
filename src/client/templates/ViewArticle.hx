package templates;
import js.JQuery;
import meteor.Meteor;
import meteor.Session;
import meteor.Template;
import model.Articles;
import model.Articles.Article;

/**
 * ...
 * @author TiagoLr
 */
class ViewArticle {

	// Current article to display
	var currentArticle(get, set):Article;
	function get_currentArticle() {
		return Session.get('currentViewArticle');
	}
	function set_currentArticle(a:Article) {
		Session.set('currentViewArticle', a);
		return a;
	}
	
	// Html Page
	var page(get, null):JQuery;
	function get_page():JQuery {
		return new JQuery('#viewArticlePage');
	}
	
	public function new() {}
	public function init() {
		Template.get('viewArticle').helpers( {
			article : function () {
				return currentArticle;
			},
			parsedContent: function () {
				return currentArticle == null ? 
					"" :
					Client.utils.parseMarkdown(currentArticle.content);
			}
		});
	}
	
	public function show(articleId:String) {
		Meteor.subscribe(Articles.NAME, { _id:articleId }, null, {
			onReady: function () {
				currentArticle = Articles.collection.findOne( { _id:articleId } );
			}
			// TODO on error
		});
		page.show(Router.FADE_DURATION);
	}
	
	public function hide() {
		page.hide(Router.FADE_DURATION);
	}
	
}
package templates;
import js.JQuery;
import meteor.Meteor;
import meteor.packages.FlowRouter;
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
			},
			canUpdateArticle: function () {
				return Permissions.canUpdateArticles(currentArticle);
			},
			
			canRemoveArticle: function () {
				return Permissions.canRemoveArticles(currentArticle);
			}
		});
		
		Template.get('viewArticle').events( {
			'click #va-btnRemoveArticle': function (evt) {
				
				Client.utils.confirm(
					Configs.client.texts.prompt_ra_msg,
					Configs.client.texts.prompt_ra_cancel,
					Configs.client.texts.prompt_ra_confirm, 
					function () {
						Articles.collection.remove( { _id:currentArticle._id } );
						FlowRouter.go('/');
					}
				);
			}
		});
	}
	
	public function show(args:Dynamic) {
		var articleId = args != null ? args.articleId : null;
		
		if (articleId == null) {
			Client.utils.notifyError('Article not found');
		}
		
		Meteor.subscribe(Articles.NAME, { _id:articleId }, null, {
			onReady: function () {
				currentArticle = Articles.collection.findOne( { _id:articleId } );
			}
			// TODO on error
		});
		page.show(Configs.client.page_fadein_duration);
	}
	
	public function hide() {
		page.hide(Configs.client.page_fadeout_duration);
	}
	
}
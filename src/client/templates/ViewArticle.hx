package templates;
import js.Browser;
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
	function get_currentArticle() {return Session.get('currentViewArticle');}
	function set_currentArticle(a:Article) {Session.set('currentViewArticle', a);return a;}
	
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
				// current article not set, return empty content
				if (currentArticle == null) {
					return "";
				}
				
				// only link is set, return iframe
				if (currentArticle.content == "" || currentArticle.content == null) {
					return ClientUtils.articleLinkToIframe(currentArticle.link);
				}
				
				// contents are set, return parsed markdown
				return ClientUtils.parseMarkdown(currentArticle.content);
			},
			canUpdateArticle: function () {
				return Permissions.canUpdateArticles(currentArticle);
			},
			
			canRemoveArticle: function () {
				return Permissions.canRemoveArticles(currentArticle);
			}
		});
		
		Template.get('viewArticle').events( {
			
			'click #va-btn-edit-article': function (evt) {
				var id = currentArticle._id;
				var title = currentArticle.title;
				title = SharedUtils.formatUrlName(title);
				
				var path = FlowRouter.path('/articles/edit/:id/:name', { id:id, name:title } );
				FlowRouter.go(path);
			},
			
			'click #va-btn-remove-article': function (evt) {
				
				ClientUtils.confirm(
					Configs.client.texts.prompt_ra_msg,
					Configs.client.texts.prompt_ra_cancel,
					Configs.client.texts.prompt_ra_confirm, 
					function () {
						Articles.collection.remove( { _id:currentArticle._id } );
						FlowRouter.go('/');
					}
				);
			},
			
		});
		
	}
	
	public function show(args:Dynamic) {
		var articleId = args != null ? args.articleId : null;
		
		if (articleId == null) {
			ClientUtils.notifyError('Article not found');
		}
		
		Meteor.subscribe(Articles.NAME, { _id:articleId }, null, {
			onReady: function () {
				currentArticle = Articles.collection.findOne( { _id:articleId } );
			}
			// TODO on error
		});
		page.show(Configs.client.page_fadein_duration, resizeIframe);
		
	}
	
	function resizeIframe() {
		// calculate iframe height if it exists
		if (new JQuery('.va-article-frame') != null) {
			// viewport height
			var vh = Math.max(Browser.document.documentElement.clientHeight, Browser.window.innerHeight); 
			// page height
			var ph = new JQuery('#page-content-wrapper').outerHeight();
			// content height
			var ch = new JQuery('#va-content').height();
			
			//
			var freeSpace = vh;
			if (vh > 480 ) { 
				// if viewport height is high enough resize iframe
				// TODO - remove hardcoded 50 px for navbar, 5px for iframe bottom 
				freeSpace = vh - (ph - ch) - 50 - 5; 
			}
			
			trace(freeSpace + '  ' + vh);
			new JQuery('.va-article-frame').css('height', freeSpace + 'px');
			
			// TODO on resize - if frame <
		}
	}
	
	public function hide() {
		page.hide(Configs.client.page_fadeout_duration);
	}
	
}
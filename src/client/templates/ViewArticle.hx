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
					
					var src = currentArticle.link;
					
					// detect youtube links and embed them
					if (currentArticle.link.indexOf('www.youtube.com') != -1 || currentArticle.link.indexOf('www.youtu.be') != -1) {
						var ryoutube = ~/(?:watch\?v=)(.+)/gi;
						if (ryoutube.match(src)) {
							try {
								src = 'https://www.youtube.com/embed/' + ryoutube.matched(1);
							} catch(e:Dynamic) {}
						}
					} 
					else 
					
					// detect try_haxe link and embed them
					if (currentArticle.link.indexOf('//try.haxe.org') != -1) {
						var rtryhaxe = ~/(try.haxe.org\/)#(.+)/gi;
						if (rtryhaxe.match(src)) {
							try {
								src = 'http://try.haxe.org/embed/' + rtryhaxe.matched(2);
							} catch(e:Dynamic) {}
						}
					}
					
					return '<iframe class="va-article-frame" src="$src" allowfullscreen></iframe>';
				} 
				
				// contents are set, return parsed markdown
				return Client.utils.parseMarkdown(currentArticle.content);
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
				title = Shared.utils.formatUrlName(title);
				
				var path = FlowRouter.path('/articles/edit/:id/:name', { id:id, name:title } );
				FlowRouter.go(path);
			},
			
			'click #va-btn-remove-article': function (evt) {
				
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
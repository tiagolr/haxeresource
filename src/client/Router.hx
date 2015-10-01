import meteor.packages.FlowRouter;
import model.Articles;
import model.TagGroups;
import templates.ListArticles;
import templates.NewArticle;
import templates.ViewArticle;
/**
 * ...
 * @author TiagoLr
 */
class Router {

	static public inline var FADE_DURATION = 500;
	
	static public function init() {
		
		FlowRouter.route('/', {
			action: function() {
				ListArticles.show(null, null, {});
			},
			triggersExit: [function() {
				ListArticles.hide();
			}]
		});
		
		FlowRouter.route('/tag/:_name', {
			action: function () {
				var tag = FlowRouter.getParam('_name');
				
				var selector = Articles.queryFromTags([tag]);
				Client.utils.subscribeCountArticles(selector);
				
				ListArticles.show(null, null, selector);
			}, 
			triggersExit:[function() {
				ListArticles.hide();
			}]
		});
		
		FlowRouter.route('/tag/group/:_name', {
			action: function () {
				var g:TagGroup = TagGroups.collection.findOne({name:FlowRouter.getParam('_name')});
				if (g != null) {
					var tags = Shared.utils.resolveTags(g);
					tags.push(g.mainTag);
					
					ListArticles.show(null, null, Articles.queryFromTags(tags));
				} else {
					// TODO - goto index
				}
			}, 
			triggersExit:[function() {
				ListArticles.hide();
			}]
		});
		
		FlowRouter.route("/new", {
			action:function () {
				NewArticle.page.show(FADE_DURATION);
			},
			triggersExit: [function () {
				NewArticle.page.hide(FADE_DURATION);
			}]
		});
		
		FlowRouter.route("/view/:_id", {
			action: function () {
				var id = FlowRouter.getParam('_id');
				ViewArticle.show(id);
			}, 
			triggersExit: [function () {
				ViewArticle.page.hide();
			}]
		});
	}
}
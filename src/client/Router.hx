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
	
	public function new() {}
	public function init() {
		
		FlowRouter.route('/', {
			action: function() {
				Client.listArticles.show(null, null, {});
			},
			triggersExit: [function() {
				Client.listArticles.hide();
			}]
		});
		
		FlowRouter.route('/tag/:_name', {
			action: function () {
				var tag = FlowRouter.getParam('_name');
				
				var selector = Articles.queryFromTags([tag]);
				//Client.utils.subscribeCountArticles(selector);
				
				Client.listArticles.show(null, null, selector);
			}, 
			triggersExit:[function() {
				Client.listArticles.hide();
			}]
		});
		
		FlowRouter.route('/tag/group/:_name', {
			action: function () {
				var g:TagGroup = TagGroups.collection.findOne({name:FlowRouter.getParam('_name')});
				if (g != null) {
					var tags = Shared.utils.resolveTags(g);
					tags.push(g.mainTag);
					
					//Client.utils.subscribeCountArticles(selector);
					
					Client.listArticles.show(null, null, Articles.queryFromTags(tags));
				} else {
					// TODO - goto index
				}
			}, 
			triggersExit:[function() {
				Client.listArticles.hide();
			}]
		});
		
		FlowRouter.route("/new", {
			action:function () {
				Client.newArticle.show();
			},
			triggersExit: [function () {
				Client.newArticle.hide();
			}]
		});
		
		FlowRouter.route("/edit/:_id", {
			action:function () {
				var id = FlowRouter.getParam('_id');
				Client.newArticle.show(id);
			},
			triggersExit: [function () {
				Client.newArticle.hide();
			}]
		});
		
		FlowRouter.route("/view/:_id", {
			action: function () {
				var id = FlowRouter.getParam('_id');
				Client.viewArticle.show(id);
			}, 
			triggersExit: [function () {
				Client.viewArticle.hide();
			}]
		});
	}
}
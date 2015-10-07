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

	
	
	public function new() {}
	public function init() {
		
		FlowRouter.route('/', {
			action: function() {
				Client.listArticles.show(null, null, {}, Configs.client.MSG_SHOWING_ALL);
			},
			triggersExit: [function() {
				Client.listArticles.hide();
			}]
		});
		
		FlowRouter.route('/tag/:name', {
			action: function () {
				var tag = FlowRouter.getParam('name');
				
				var selector = Articles.queryFromTags([tag]);
				//Client.utils.subscribeCountArticles(selector);
				
				Client.listArticles.show(null, null, selector, Configs.client.MSG_SHOWING_TAG(tag));
			}, 
			triggersExit:[function() {
				Client.listArticles.hide();
			}]
		});
		
		FlowRouter.route('/tag/group/:name', {
			action: function () {
				var groupName = FlowRouter.getParam('name');
				var g:TagGroup = TagGroups.collection.findOne({name:groupName});
				if (g != null) {
					var tags = Shared.utils.resolveTags(g);
					tags.push(g.mainTag);
					
					//Client.utils.subscribeCountArticles(selector);
					
					Client.listArticles.show(null, null, Articles.queryFromTags(tags), Configs.client.MSG_SHOWING_GROUP(groupName));
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
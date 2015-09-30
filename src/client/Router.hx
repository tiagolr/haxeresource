import meteor.packages.FlowRouter;
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
				ListArticles.show(null, null, { tags: { '$in':[tag] }} );
			}, 
			triggersExit:[function() {
				ListArticles.hide();
			}]
		});
		
		FlowRouter.route('/tag/group/:_name', {
			action: function () {
				var g:TagGroup = TagGroups.collection.findOne({name:FlowRouter.getParam('_name')});
				if (g != null) {
					var tags = Shared.resolveTags(g);
					tags.push(g.mainTag);
					ListArticles.show(null, null, { tags: { '$in':tags }} );
				} else {
					// TODO - goto index
				}
			}
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
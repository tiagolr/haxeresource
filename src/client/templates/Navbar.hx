package templates;
import js.JQuery;
import meteor.packages.FlowRouter;
import meteor.Template;

/**
 * ...
 * @author TiagoLr
 */
class Navbar{

	public function new() {}
	public function init() {
		Template.get('navbar').events( {
			'click #btn-toggle-sidebar' : function (evt) {
				new JQuery('#wrapper').toggleClass('toggled');
			},
			
			'click #btn-new-article' : function (evt) {
				FlowRouter.go('/articles/new');
			},
			
			'submit #nav-search-form' : function(evt) {
				var query = new JQuery('#nav-search-form input').val();
				if (query != null && query != "") {
					FlowRouter.go('/articles/search',{}, {q:query});
				} else {
					FlowRouter.go('/'); // show all articles
				}
				
				return false;
			}
		});
	}
}
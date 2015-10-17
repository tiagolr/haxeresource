package templates;
import js.JQuery;
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
			}
		});
	}
	
}
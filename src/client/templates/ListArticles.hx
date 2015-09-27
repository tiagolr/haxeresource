package templates;
import js.Browser;
import js.JQuery;
import meteor.Template;
import model.Articles;

/**
 * ...
 * @author TiagoLr
 */
class ListArticles {

	static public var page(get, null):JQuery;
	static function get_page():JQuery {
		return new JQuery('#listArticlesPage');
	}
	
	static public function init() {
		
		Template.get('listArticles').helpers( {
			
			articles:function() {
				return Articles.collection.find({}, {sort: {created: -1}, limit: 5});
			},
			
		});
		
		Template.get('articleRow').helpers( {
			
			formatDate: function( date ) {
				return untyped vagueTime.get( {
					from:Date.now(),
					to:date
				});
			},
			
			formatLink: function( link:String ) {
				if (!StringTools.startsWith(link, "http://")) {
					link = "http://" + link;
				}
				return link;
			}
			
		});
		
		Template.get('articleRow').events( {
			
			// Expand / collapse row
			'click .articleRowToggle':function (event) {
				var target = new JQuery(event.target.getAttribute('data-target'));
				var rows = new JQuery('.articleRowBody');
				var isCollapsed = target.hasClass('collapsed');
				
				for (row in rows) {
					row == target ?
						untyped row.collapse(isCollapsed ? 'show' : 'hide'):
						untyped row.collapse('hide');
				}
			}
		});
		
	}
}
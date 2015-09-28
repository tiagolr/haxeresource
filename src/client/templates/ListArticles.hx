package templates;
import js.Browser;
import js.JQuery;
import meteor.Meteor;
import meteor.packages.PublishCounts;
import meteor.Session;
import meteor.Template;
import model.Articles;

/**
 * ...
 * @author TiagoLr
 */
@:expose("vaca")
class ListArticles {

	public static inline var PAGE_SIZE = 5;
	
	static var page(get, null):JQuery;
	static function get_page():JQuery {
		return new JQuery('#listArticlesPage');
	}
	
	// REACTIVE VARS --------------------------------------------------
	static var sort(get, set): { };
	static function set_sort(val) {
		Session.set('list_articles_sort',val);
		return val;
	}
	static function get_sort() {
		return Session.get('list_articles_sort');
	}
	
	static var limit(get, set):Int;
	static function set_limit(val:Int) {
		Session.set('list_articles_limit', val);
		return val;
	}
	static function get_limit() {
		return Session.get('list_articles_limit'); 
	}
	
	static var selector(get, set): { };
	static function set_selector(val) {
		Session.set('list_articles_selector', val);
		return val;
	}
	static function get_selector() {
		return Session.get('list_articles_selector');
	}
	//-----------------------------------------------------------------
	
	static public function show(?_sort:{}, ?_limit:Int = PAGE_SIZE, _selector:Dynamic) {
		page.show(Router.FADE_DURATION);
		
		if (_limit != null) {
			limit = _limit;
		}
		
		if (_selector != null) {
			selector = _selector;
		}
		
		if (_sort != null) {
			sort = _sort;
		}
		
		fetchFromServer();
	}
	
	static public function hide() {
		page.hide(Router.FADE_DURATION);
	}
	
	static function fetchFromServer() {
		Meteor.subscribe(Articles.NAME, selector, { sort:sort, limit:limit });
	}
	
	static public function init() {
		sort = { created: -1 };
		limit = PAGE_SIZE;
		selector = { };
		
		Template.get('listArticles').helpers( {
			
			articles:function() {
				return Articles.collection.find( selector, { sort:sort, limit:limit } );
			},
			
			currentCount:function () {
				return Articles.collection.find( selector, { limit:limit } ).count();
			},
			
			totalCount: function () {
				return PublishCounts.get('countArticles');
			},
			
			allEntriesLoaded: function() {
				return PublishCounts.get('countArticles') == Articles.collection.find(selector, { limit:limit } ).count();
			}
			
		});
		
		Template.get('listArticles').events( {
			'click #btnLoadMoreResults': function () {
				limit += 5;
				fetchFromServer();
			}
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
		
		Template.get('articleRow').onRendered(function () {
			new JQuery(TemplateCtx.find('.articleRowHeader')).show(500);
		});
		
	}
}
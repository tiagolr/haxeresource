package templates;
import js.Browser;
import js.JQuery;
import js.Lib;
import meteor.Meteor;
import meteor.packages.PublishCounts;
import meteor.Session;
import meteor.Template;
import model.Articles;

/**
 * ...
 * @author TiagoLr
 */
class ListArticles {

	public static inline var PAGE_SIZE = 5;
	
	var subscription:{};
	
	var page(get, null):JQuery;
	function get_page():JQuery {
		return new JQuery('#listArticlesPage');
	}
	
	// REACTIVE VARS --------------------------------------------------
	var sort(get, set): Dynamic;
	function set_sort(val) {
		Session.set('list_articles_sort',val);
		return val;
	}
	function get_sort() {
		return Session.get('list_articles_sort');
	}
	
	var limit(get, set):Int;
	function set_limit(val:Int) {
		Session.set('list_articles_limit', val);
		return val;
	}
	function get_limit() {
		return Session.get('list_articles_limit'); 
	}
	
	var selector(get, set): { };
	function set_selector(val) {
		Session.set('list_articles_selector', val);
		return val;
	}
	function get_selector() {
		return Session.get('list_articles_selector');
	}
	//-----------------------------------------------------------------
	
	
	public function show(?_sort:{}, ?_limit:Int = PAGE_SIZE, _selector:Dynamic) {
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
	}
	
	public function hide() {
		page.hide(Router.FADE_DURATION);
	}
	
	public function new() {}
	public function init() {
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
				return Client.utils.retrieveArticleCount(selector);
			},
			
			allEntriesLoaded: function() {
				return Client.utils.retrieveArticleCount(selector) == Articles.collection.find(selector, { limit:limit } ).count();
			},
			
			sortAgeUp: function() { return sort.created == 1;},
			sortAgeDown: function() { return sort.created == -1;},
			sortVotesUp: function() { return sort.upvotes == 1;},
			sortVotesDown: function() { return sort.upvotes == -1;},
			sortTitleUp: function() { return sort.title == 1; },
			sortTitleDown: function() { return sort.title == -1; },
		});
		
		Template.get('listArticles').onCreated(function() {
			TemplateCtx.autorun(function () {
				subscription = Meteor.subscribe(Articles.NAME, selector, { sort:sort, limit:limit });
			});
		});
		
		Template.get('listArticles').events( {
			
			'click #btnLoadMoreResults': function () {
				limit += 5;
			},
			
			'click #btnSortByAge' : function () {
				sort.created == null ? 
					sort = { created : 1 } :
					sort = { created : sort.created * -1 };	
			},
			
			'click #btnSortByTitle' : function () {
				sort.title == null ? 
					sort = { title : 1 } :
					sort = { title : sort.title * -1 };
			},
			
			'click #btnSortByVotes' : function() {
				sort.upvotes == null ? 
					sort = { upvotes : 1 } :
					sort = { upvotes : sort.upvotes * -1 };
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
		
		Template.get('articleRow').onRendered(function () {
			new JQuery(TemplateCtx.find('.articleRowHeader')).show(500);
		});
		
	}
}
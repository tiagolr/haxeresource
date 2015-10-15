package templates;
import js.Browser;
import js.html.Event;
import js.JQuery;
import js.JQuery.JqEvent;
import js.Lib;
import meteor.Cursor;
import meteor.Meteor;
import meteor.packages.FlowRouter;
import meteor.packages.PublishCounts;
import meteor.Session;
import meteor.Template;
import model.Articles;
import templates.ListArticles.ListArticlesSort;

/**
 * ...
 * @author TiagoLr
 */
typedef ListArticlesSort = {
	?created:Int,
	?votes:Int,
	?title:Int,
	?score:Int,
}
 
typedef ListArticlesOptions = {
	?isSearch:Bool,
	?sort: ListArticlesSort,
	?limit:Int, // set to -1 to use configs page size
	selector:Dynamic, 
	?query:String,
	caption:String,
}

class ListArticles {
	
	var subscription: { };
	
	var page(get, null):JQuery;
	function get_page():JQuery {
		return new JQuery('#listArticlesPage');
	}
	
	// REACTIVE VARS --------------------------------------------------
	var sort(get, set):ListArticlesSort;
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
	
	var captionMsg(get, set):String;
	function get_captionMsg():String {
		return Session.get('la_captionMsg');
	}
	function set_captionMsg(val:String):String {
		Session.set('la_captionMsg', val);
		return val;
	}
	
	var searchMode(get, set):Bool;
	function get_searchMode():Bool {
		return Session.get('search_mode');
	}
	function set_searchMode(val:Bool):Bool {
		Session.set('search_mode', val);
		return val;
	}
	
	var searchQuery(get, set):String;
	function get_searchQuery():String {
		return Session.get('search_query');
	}
	function set_searchQuery(val:String):String {
		Session.set('search_query', val);
		return val;
	}
	//-----------------------------------------------------------------
	
	
	public function show(args:ListArticlesOptions) {
		searchMode = args.isSearch == true ? true : false;
		
		if (searchMode) {
			searchQuery = args.query;
			selector = { score: { '$exists':true }} // selector is set to searched articles
			
			if (args.sort == null) {
				sort = {score: -1}; // search mode defaults sorting to score
			}
		} 
		else {
			if (args.limit != null) {
			limit = args.limit == -1 ? 
				Configs.client.page_size : args.limit;
			}
			
			if (args.selector != null) {
				selector = args.selector;
			}
			
			if (args.sort == null || (args.sort.created == null && args.sort.votes == null && args.sort.title == null)) {
				sort = { created: -1 }; // default sorting
			} else {
				sort = args.sort;
			}
		}
		
		captionMsg = args.caption;
		page.show(Configs.client.page_fadein_duration);
	}
	
	public function showSearch(_sort:{}, query:String, caption:String) {
		
	}
	
	public function hide() {
		page.hide(Configs.client.page_fadein_duration);
	}
	
	public function new() {}
	public function init() {
		sort = { created: -1 };
		limit = Configs.client.page_size;
		selector = { };
		searchMode = false;
		searchQuery = "";
		
		Template.get('listArticles').helpers( {
			
			captionMsg: function () {
				return captionMsg;
			},
			
			articles:function() {
				return Articles.collection.find( selector, { sort:sort, limit:limit } );
			},
			
			currentCount:function () {
				return Articles.collection.find( selector, { limit:limit } ).count();
			},
			
			totalCount: function () {
				var s = searchMode == true ?  { "$text": { "$search": searchQuery }} : selector;
				return Client.utils.retrieveArticleCount(s);
			},
			
			// return currentCount == totalCount
			allEntriesLoaded: function() {
				var s = searchMode == true ?  { "$text": { "$search": searchQuery }} : selector;
				return Articles.collection.find(selector, { limit:limit } ).count() == Client.utils.retrieveArticleCount(s);
			},
			
			sortAgeUp: function() { return sort.created == 1;},
			sortAgeDown: function() { return sort.created == -1;},
			sortVotesUp: function() { return sort.votes == 1;},
			sortVotesDown: function() { return sort.votes == -1;},
			sortTitleUp: function() { return sort.title == 1; },
			sortTitleDown: function() { return sort.title == -1; },
		});
		
		
		Template.get('listArticles').onCreated(function() {
			TemplateCtx.autorun(function () {
				subscription = searchMode == true ?
					subscription = Meteor.subscribe('searchArticles', searchQuery, { sort:sort, limit:limit }):
					subscription = Meteor.subscribe(Articles.NAME, selector, { sort:sort, limit:limit } );
			});
		});
		
		
		Template.get('listArticles').events( {
			
			'click #btnLoadMoreResults': function (_) {
				limit += Configs.client.page_size;
			},
			
			'click #btnSortByAge' : function (_) {
				sort = sort.created == null ? 
					{ created : 1 } :
					{ created : sort.created * -1 };	
			},
			
			'click #btnSortByTitle' : function (_) {
				sort = sort.title == null ? 
					{ title : 1 } :
					{ title : sort.title * -1 };
			},
			
			'click #btnSortByVotes' : function(_) {
				sort = sort.votes == null ? 
					{ votes : 1 } :
					{ votes : sort.votes * -1 };
			},
			
			'submit #la-search-form' : function(evt:JqEvent) {
				var query = new JQuery('#la-search-form input').val();
				
				if (query != null && query != "") {
					FlowRouter.go('/articles/search',{}, {q:query});
				} else {
					FlowRouter.go('/'); // show all articles
				}
				
				return false;
			}
			
		});
		
		Template.get('articleRow').helpers( {
			
			hasUserVote: function(id) {
				if (Meteor.userId() == null) return false;
				
				var votes = Meteor.user().profile.votes;
				return votes != null && votes.indexOf(id) != -1;
			},
			
			formatDate: function( date ) {
				var s = untyped vagueTime.get( {
					from:Date.now(),
					to:date
				});
				
				s = StringTools.replace(s, ' ago', '');
				return s;
			},
			
			formatLink: function( link:String ) {
				if (!StringTools.startsWith(link, "http://")) {
					link = "http://" + link;
				}
				return link;
			},
			
			canEditArticle: function (article) {
				return Permissions.canUpdateArticles(article);
			},
			
			canRemoveArticle: function (article) {
				return Permissions.canRemoveArticles(article);
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
			},
			
			'click .articleVoteLink':function (event:JqEvent) {
				var articleId = event.currentTarget.getAttribute('data-article');
				event.stopImmediatePropagation();
				
				Meteor.call('toggleArticleVote', articleId, function (error) {
					if (error != null) {
						Client.utils.handleServerError(error);
					}
				});
			},
			
			'click #la-btn-view-article':function (event:JqEvent) {
				var articleId = event.currentTarget.getAttribute('data-article');
				var title = event.currentTarget.getAttribute('data-title');
				title = Shared.utils.formatUrlName(title);
				
				var path = FlowRouter.path('/articles/view/:id/:name', { id:articleId, name:title } );
				FlowRouter.go(path);
			},

			'click #la-btn-edit-article':function (event:JqEvent) {
				var articleId = event.currentTarget.getAttribute('data-article');
				var title = event.currentTarget.getAttribute('data-title');
				title = Shared.utils.formatUrlName(title);
				
				var path = FlowRouter.path('/articles/edit/:id/:name', { id:articleId, name:title } );
				FlowRouter.go(path);
			},
			
			'click #la-btn-remove-article':function (event:JqEvent) {
				var articleId = event.currentTarget.getAttribute('data-article');
				
				Client.utils.confirm(
					Configs.client.texts.prompt_ra_msg,
					Configs.client.texts.prompt_ra_cancel,
					Configs.client.texts.prompt_ra_confirm, 
					function () {
						Articles.collection.remove( { _id:articleId } );
					}
				);
				
			},
		});
		
		Template.get('articleRow').onRendered(function () {
			new JQuery(TemplateCtx.find('.articleRowHeader')).show(500);
		});
		
	}
	
	
}
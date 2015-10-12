package templates;
import js.Browser;
import js.html.Event;
import js.JQuery;
import js.JQuery.JqEvent;
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
	
	
	var captionMsg(get, set):String;
	function get_captionMsg():String {
		return Session.get('la_captionMsg');
	}
	function set_captionMsg(val:String):String {
		Session.set('la_captionMsg', val);
		return val;
	}
	//-----------------------------------------------------------------
	
	
	public function show(?_sort: { }, ?_limit:Int = -1, _selector:Dynamic, captionMsg:String) {
		if (_limit == -1) {
			_limit = Configs.client.page_size;
		}
		page.show(Configs.client.page_fadein_duration);
		
		if (_limit != null) {
			limit = _limit;
		}
		
		if (_selector != null) {
			selector = _selector;
		}
		
		if (_sort != null) {
			sort = _sort;
		}
		
		this.captionMsg = captionMsg;
	}
	
	public function hide() {
		page.hide(Configs.client.page_fadeout_duration);
	}
	
	public function new() {}
	public function init() {
		sort = { created: -1 };
		limit = Configs.client.page_size;
		selector = { };
		
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
				return Client.utils.retrieveArticleCount(selector);
			},
			
			allEntriesLoaded: function() {
				return Client.utils.retrieveArticleCount(selector) == Articles.collection.find(selector, { limit:limit } ).count();
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
				subscription = Meteor.subscribe(Articles.NAME, selector, { sort:sort, limit:limit });
			});
		});
		
		Template.get('listArticles').events( {
			
			'click #btnLoadMoreResults': function (_) {
				limit += Configs.client.page_size;
			},
			
			'click #btnSortByAge' : function (_) {
				sort.created == null ? 
					sort = { created : 1 } :
					sort = { created : sort.created * -1 };	
			},
			
			'click #btnSortByTitle' : function (_) {
				sort.title == null ? 
					sort = { title : 1 } :
					sort = { title : sort.title * -1 };
			},
			
			'click #btnSortByVotes' : function(_) {
				sort.votes == null ? 
					sort = { votes : 1 } :
					sort = { votes : sort.votes * -1 };
			},
			
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
			
			'click #la-btnRemoveArticle':function (event:JqEvent) {
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
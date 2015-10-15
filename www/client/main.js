(function (console, $hx_exports) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var templates_ListArticles = function() {
};
templates_ListArticles.__name__ = true;
templates_ListArticles.prototype = {
	get_page: function() {
		return js.JQuery("#listArticlesPage");
	}
	,set_sort: function(val) {
		Session.set("list_articles_sort",val);
		return val;
	}
	,get_sort: function() {
		return Session.get("list_articles_sort");
	}
	,set_limit: function(val) {
		Session.set("list_articles_limit",val);
		return val;
	}
	,get_limit: function() {
		return Session.get("list_articles_limit");
	}
	,set_selector: function(val) {
		Session.set("list_articles_selector",val);
		return val;
	}
	,get_selector: function() {
		return Session.get("list_articles_selector");
	}
	,get_captionMsg: function() {
		return Session.get("la_captionMsg");
	}
	,set_captionMsg: function(val) {
		Session.set("la_captionMsg",val);
		return val;
	}
	,get_searchMode: function() {
		return Session.get("search_mode");
	}
	,set_searchMode: function(val) {
		Session.set("search_mode",val);
		return val;
	}
	,get_searchQuery: function() {
		return Session.get("search_query");
	}
	,set_searchQuery: function(val) {
		Session.set("search_query",val);
		return val;
	}
	,show: function(args) {
		this.set_searchMode(args.isSearch == true?true:false);
		if(this.get_searchMode()) {
			this.set_searchQuery(args.query);
			this.set_selector({ score : { '$exists' : true}});
			if(args.sort == null) this.set_sort({ score : -1});
		} else {
			if(args.limit != null) this.set_limit(args.limit == -1?Configs.client.page_size:args.limit);
			if(args.selector != null) this.set_selector(args.selector);
			if(args.sort == null || args.sort.created == null && args.sort.votes == null && args.sort.title == null) this.set_sort({ created : -1}); else this.set_sort(args.sort);
		}
		this.set_captionMsg(args.caption);
		this.get_page().show(Configs.client.page_fadein_duration);
	}
	,showSearch: function(_sort,query,caption) {
	}
	,hide: function() {
		this.get_page().hide(Configs.client.page_fadein_duration);
	}
	,init: function() {
		var _g = this;
		this.set_sort({ created : -1});
		this.set_limit(Configs.client.page_size);
		this.set_selector({ });
		this.set_searchMode(false);
		this.set_searchQuery("");
		Template.listArticles.helpers({ captionMsg : function() {
			return _g.get_captionMsg();
		}, articles : function() {
			return model_Articles.collection.find(_g.get_selector(),{ sort : _g.get_sort(), limit : _g.get_limit()});
		}, currentCount : function() {
			return model_Articles.collection.find(_g.get_selector(),{ limit : _g.get_limit()}).count();
		}, totalCount : function() {
			var s;
			if(_g.get_searchMode() == true) s = { '$text' : { '$search' : _g.get_searchQuery()}}; else s = _g.get_selector();
			return Client.utils.retrieveArticleCount(s);
		}, allEntriesLoaded : function() {
			var s1;
			if(_g.get_searchMode() == true) s1 = { '$text' : { '$search' : _g.get_searchQuery()}}; else s1 = _g.get_selector();
			return model_Articles.collection.find(_g.get_selector(),{ limit : _g.get_limit()}).count() == Client.utils.retrieveArticleCount(s1);
		}, sortAgeUp : function() {
			return _g.get_sort().created == 1;
		}, sortAgeDown : function() {
			return _g.get_sort().created == -1;
		}, sortVotesUp : function() {
			return _g.get_sort().votes == 1;
		}, sortVotesDown : function() {
			return _g.get_sort().votes == -1;
		}, sortTitleUp : function() {
			return _g.get_sort().title == 1;
		}, sortTitleDown : function() {
			return _g.get_sort().title == -1;
		}});
		Template.listArticles.onCreated(function() {
			this.autorun(function() {
				if(_g.get_searchMode() == true) _g.subscription = _g.subscription = Meteor.subscribe("searchArticles",_g.get_searchQuery(),{ sort : _g.get_sort(), limit : _g.get_limit()}); else _g.subscription = _g.subscription = Meteor.subscribe("articles",_g.get_selector(),{ sort : _g.get_sort(), limit : _g.get_limit()});
			});
		});
		Template.listArticles.events({ 'click #btnLoadMoreResults' : function(_) {
			var _g1 = _g;
			_g1.set_limit(_g1.get_limit() + Configs.client.page_size);
		}, 'click #btnSortByAge' : function(_1) {
			_g.set_sort(_g.get_sort().created == null?{ created : 1}:{ created : _g.get_sort().created * -1});
		}, 'click #btnSortByTitle' : function(_2) {
			_g.set_sort(_g.get_sort().title == null?{ title : 1}:{ title : _g.get_sort().title * -1});
		}, 'click #btnSortByVotes' : function(_3) {
			_g.set_sort(_g.get_sort().votes == null?{ votes : 1}:{ votes : _g.get_sort().votes * -1});
		}, 'submit #la-search-form' : function(evt) {
			var query = js.JQuery("#la-search-form input").val();
			if(query != null && query != "") FlowRouter.go("/search",{ },{ q : query}); else FlowRouter.go("/");
			return false;
		}});
		Template.articleRow.helpers({ hasUserVote : function(id) {
			if(Meteor.userId() == null) return false;
			var votes = Meteor.user().profile.votes;
			return votes != null && votes.indexOf(id) != -1;
		}, formatDate : function(date) {
			var s2 = vagueTime.get({ from : new Date(), to : date});
			s2 = StringTools.replace(s2," ago","");
			return s2;
		}, formatLink : function(link) {
			if(!StringTools.startsWith(link,"http://")) link = "http://" + link;
			return link;
		}, canEditArticle : function(article) {
			return Permissions.canUpdateArticles(article);
		}, canRemoveArticle : function(article1) {
			return Permissions.canRemoveArticles(article1);
		}});
		Template.articleRow.events({ 'click .articleRowToggle' : function(event) {
			var target = js.JQuery(event.target.getAttribute("data-target"));
			var rows = js.JQuery(".articleRowBody");
			var isCollapsed = target.hasClass("collapsed");
			var $it0 = (rows.iterator)();
			while( $it0.hasNext() ) {
				var row = $it0.next();
				if(row == target) row.collapse(isCollapsed?"show":"hide"); else row.collapse("hide");
			}
		}, 'click .articleVoteLink' : function(event1) {
			var articleId = event1.currentTarget.getAttribute("data-article");
			event1.stopImmediatePropagation();
			Meteor.call("toggleArticleVote",articleId,function(error) {
				if(error != null) Client.utils.handleServerError(error);
			});
		}, 'click #la-btnRemoveArticle' : function(event2) {
			var articleId1 = event2.currentTarget.getAttribute("data-article");
			Client.utils.confirm(Configs.client.texts.prompt_ra_msg,Configs.client.texts.prompt_ra_cancel,Configs.client.texts.prompt_ra_confirm,function() {
				model_Articles.collection.remove({ _id : articleId1});
			});
		}});
		Template.articleRow.onRendered(function() {
			js.JQuery(this.find(".articleRowHeader")).show(500);
		});
	}
	,__class__: templates_ListArticles
};
var templates_Navbar = function() {
};
templates_Navbar.__name__ = true;
templates_Navbar.prototype = {
	init: function() {
	}
	,__class__: templates_Navbar
};
var templates_NewArticle = function() {
};
templates_NewArticle.__name__ = true;
templates_NewArticle.prototype = {
	get_page: function() {
		return js.JQuery("#newArticlePage");
	}
	,get_editArticle: function() {
		return Session.get("editArticle");
	}
	,set_editArticle: function(val) {
		Session.set("editArticle",val);
		return val;
	}
	,init: function() {
		var _g = this;
		Template.newArticle.helpers({ editArticle : function() {
			return Session.get("editArticle");
		}, featuredTags : function() {
			var $final = [];
			var groups = templates_SideBar.get_tagGroups();
			if(groups == null) return [];
			var _g1 = 0;
			while(_g1 < groups.length) {
				var g = groups[_g1];
				++_g1;
				$final.push(g.mainTag);
				var tags = g.resolvedTags;
				if(tags == null) continue;
				var _g11 = 0;
				while(_g11 < tags.length) {
					var t = tags[_g11];
					++_g11;
					$final.push(t.name);
				}
			}
			return $final;
		}, titlePlaceholder : Configs.client.texts.na_placeh_title, descriptionPlaceholder : Configs.client.texts.na_placeh_desc, linkPlaceholder : Configs.client.texts.na_placeh_link, contentPlaceholder : Configs.client.texts.na_placeh_content, tagsPlaceholder : Configs.client.texts.na_placeh_tags});
		Template.newArticle.events({ 'click #btnPreviewContents' : function(evt) {
			var previewPanel = js.JQuery("#na-previewPanel");
			var editPanel = js.JQuery("#na-editPanel");
			previewPanel.outerHeight(editPanel.outerHeight());
			var title = js.JQuery("#naf-articleTitle").val();
			var content = js.JQuery("#naf-articleContent").val();
			var link = js.JQuery("#naf-articleLink").val();
			var desc = js.JQuery("#naf-articleDescription").val();
			js.JQuery("#na-previewTitle").html(title);
			js.JQuery("#na-articleDescription").html(desc);
			js.JQuery("#na-previewLink").html("<a href=\"" + link + "\" target=\"_blank\">" + link + "</a>");
			js.JQuery("#na-previewContent").html(Client.utils.parseMarkdown(content));
		}, 'beforeItemAdd input' : function(evt1) {
			if(!model_Tags.regEx.test(evt1.item)) evt1.cancel = true;
		}, 'change #na-featuredTagsList' : function(evt2) {
			js.JQuery("#na-featuredTagsAccept").toggleClass("disabled",js.JQuery("#na-featuredTagsList").val() == null);
		}, 'click #na-featuredTagsAccept' : function(evt3) {
			var selected = js.JQuery("#na-featuredTagsList").val();
			if(selected != null) {
				var _g2 = 0;
				while(_g2 < selected.length) {
					var tag = selected[_g2];
					++_g2;
					js.JQuery("#naf-articleTags").tagsinput("add",tag);
				}
			}
			js.JQuery("#na-modalFeaturedTags").modal("hide");
		}});
		AutoForm.addHooks("newArticleForm",{ onSubmit : function(insertDoc,updateDoc,_) {
			this.event.preventDefault();
			var ctx = this;
			var id = null;
			if(Session.get("editArticle") == null) id = model_Articles.collection.insert(insertDoc,null,function(error) {
				if(error == null) {
					FlowRouter.go("/view/" + id + "/" + Shared.utils.formatUrlName(insertDoc.title));
					ctx.done();
				} else {
					Client.utils.handleServerError(error);
					ctx.done(error);
				}
			}); else {
				id = _g.get_editArticle()._id;
				model_Articles.collection.update({ _id : id},updateDoc,null,function(error1,doc) {
					if(error1 == null) {
						FlowRouter.go("/view/" + _g.get_editArticle()._id + "/" + Shared.utils.formatUrlName(_g.get_editArticle().title));
						ctx.done();
					} else {
						Client.utils.handleServerError(error1);
						ctx.done(error1);
					}
				});
			}
		}});
	}
	,show: function(args) {
		var _g = this;
		var articleId;
		if(args != null) articleId = args.articleId; else articleId = null;
		if(articleId != null) Meteor.subscribe("articles",{ _id : articleId},null,{ onReady : function() {
			var article = model_Articles.collection.findOne({ _id : articleId});
			if(article != null) {
				_g.set_editArticle(article);
				_g.get_page().show(Configs.client.page_fadein_duration);
				var tags = _g.get_editArticle().tags;
				if(tags != null) {
					var _g1 = 0;
					var _g2 = _g.get_editArticle().tags;
					while(_g1 < _g2.length) {
						var t = _g2[_g1];
						++_g1;
						js.JQuery("#naf-articleTags").tagsinput("add",t);
					}
				}
			} else {
				console.log("NewArticle.show: Could not find article " + articleId + " to edit");
				FlowRouter.go("/");
			}
		}, onError : function(e) {
			console.log("Error: " + e);
		}}); else this.get_page().show(Configs.client.page_fadein_duration);
	}
	,hide: function() {
		if(Session.get("editArticle") != null) Session.set("editArticle",null);
		this.get_page().hide(Configs.client.page_fadeout_duration);
	}
	,__class__: templates_NewArticle
};
var Router = function() {
};
Router.__name__ = true;
Router.prototype = {
	showPage: function(page,args) {
		switch(page) {
		case "listArticles":
			Client.listArticles.show(args);
			break;
		case "newArticle":
			Client.newArticle.show(args);
			break;
		case "viewArticle":
			Client.viewArticle.show(args);
			break;
		}
		if(this.currentPage != page) this.hidePage(this.currentPage);
		this.currentPage = page;
	}
	,hidePage: function(page) {
		switch(page) {
		case "listArticles":
			Client.listArticles.hide();
			break;
		case "newArticle":
			Client.newArticle.hide();
			break;
		case "viewArticle":
			Client.viewArticle.hide();
			break;
		}
	}
	,showListArticles: function(args) {
		this.showPage("listArticles",args);
	}
	,init: function() {
		var _g = this;
		FlowRouter.route("/",{ action : function() {
			_g.showListArticles({ selector : { }, caption : Configs.client.texts.la_showing_all});
		}});
		FlowRouter.route("/tag/:name",{ action : function() {
			var tag = FlowRouter.getParam("name");
			var selector = { tags : { '$nin' : [tag]}};
			_g.showListArticles({ selector : selector, caption : Configs.client.texts.la_showing_tag(tag)});
		}});
		FlowRouter.route("/tag/group/:name",{ action : function() {
			var groupName = FlowRouter.getParam("name");
			var g = model_TagGroups.collection.findOne({ name : groupName});
			if(g != null) {
				var tags = Shared.utils.resolveTags(g);
				tags.push(g.mainTag);
				var selector1 = { tags : { '$in' : tags}};
				_g.showListArticles({ selector : selector1, caption : Configs.client.texts.la_showing_group(groupName)});
			} else if(groupName == "ungrouped") {
				var tagNames = [];
				var groups = templates_SideBar.get_tagGroups();
				var _g1 = 0;
				while(_g1 < groups.length) {
					var g1 = groups[_g1];
					++_g1;
					tagNames.push(g1.mainTag);
					var _g11 = 0;
					var _g2 = g1.resolvedTags;
					while(_g11 < _g2.length) {
						var t = _g2[_g11];
						++_g11;
						tagNames.push(t.name);
					}
				}
				var selector2 = { tags : { '$nin' : tagNames}};
				_g.showListArticles({ selector : selector2, caption : Configs.client.texts.la_showing_ungrouped});
			} else FlowRouter.go("/");
		}});
		FlowRouter.route("/search",{ action : function() {
			var query = FlowRouter.getQueryParam("q");
			if(query != null && query != "") _g.showListArticles({ isSearch : true, selector : null, query : query, caption : Configs.client.texts.la_showing_query(query)}); else FlowRouter.go("/");
		}});
		FlowRouter.route("/new",{ action : function() {
			_g.showPage("newArticle");
		}});
		FlowRouter.route("/edit/:_id/:name",{ action : function() {
			var id = FlowRouter.getParam("_id");
			_g.showPage("newArticle",{ articleId : id});
		}});
		FlowRouter.route("/view/:_id/:name",{ action : function() {
			var id1 = FlowRouter.getParam("_id");
			_g.showPage("viewArticle",{ articleId : id1});
		}});
		FlowRouter.notFound = { action : function() {
			Client.utils.notifyInfo("Url not found, redirecting to homepage");
			FlowRouter.go("/");
		}};
	}
	,__class__: Router
};
var templates_SideBar = function() {
	this.ignoreDivClick = false;
};
templates_SideBar.__name__ = true;
templates_SideBar.get_tagGroups = function() {
	return Session.get("sb_tag_groups");
};
templates_SideBar.set_tagGroups = function(val) {
	Session.set("sb_tag_groups",val);
	return val;
};
templates_SideBar.formatTagName = function(tag) {
	var split = tag.split("-");
	if(split.length > 1) {
		split.shift();
		tag = split.join("-");
	}
	return tag;
};
templates_SideBar.prototype = {
	init: function() {
		var _g = this;
		Template.sidebar.helpers({ tagGroups : function() {
			var tags = model_Tags.collection.find().fetch();
			var groups = model_TagGroups.collection.find().fetch();
			var _g1 = 0;
			while(_g1 < groups.length) {
				var g = groups[_g1];
				++_g1;
				var resolved = Shared.utils.resolveTags(g);
				var $final = [];
				var _g11 = 0;
				while(_g11 < resolved.length) {
					var name = resolved[_g11];
					++_g11;
					$final.push({ name : name, formattedName : templates_SideBar.formatTagName(name)});
				}
				resolved.push(g.mainTag);
				g.resolvedTags = $final;
			}
			templates_SideBar.set_tagGroups(groups);
			return groups;
		}, countUngrouped : function() {
			var tagNames = [];
			var _g2 = 0;
			var _g12 = templates_SideBar.get_tagGroups();
			while(_g2 < _g12.length) {
				var g1 = _g12[_g2];
				++_g2;
				tagNames.push(g1.mainTag);
				var _g21 = 0;
				var _g3 = g1.resolvedTags;
				while(_g21 < _g3.length) {
					var t = _g3[_g21];
					++_g21;
					tagNames.push(t.name);
				}
			}
			return Client.utils.retrieveArticleCount({ tags : { '$nin' : tagNames}});
		}});
		Template.tagGroup.helpers({ countArticlesTag : function(tag) {
			var t1 = model_Tags.collection.findOne({ name : tag});
			if(t1 == null || t1.articles == null) return -1; else return t1.articles.length;
		}, countArticlesGroup : function(mainTag,tags1) {
			tags1 = tags1.concat([{ name : mainTag}]);
			var articles = [];
			var _g4 = 0;
			while(_g4 < tags1.length) {
				var tag1 = tags1[_g4];
				++_g4;
				var t2 = model_Tags.collection.findOne({ name : tag1.name});
				if(t2 != null && t2.articles != null) {
					var _g13 = 0;
					var _g22 = t2.articles;
					while(_g13 < _g22.length) {
						var a = _g22[_g13];
						++_g13;
						if(HxOverrides.indexOf(articles,a,0) == -1) articles.push(a);
					}
				}
			}
			return articles.length;
		}});
		Template.tagGroup.events({ 'click .group-toggler' : function(evt) {
			if(_g.ignoreDivClick) {
				_g.ignoreDivClick = false;
				return;
			}
			var trigger = js.JQuery(evt.target);
			var collapsables = js.JQuery(".sidebar-groups .collapse");
			var isCollapsed = trigger.hasClass("collapsed");
			var $it0 = (collapsables.iterator)();
			while( $it0.hasNext() ) {
				var el = $it0.next();
				if(el.attr("id") == trigger.data("trigger") && el.hasClass("collapsed")) {
					el.collapse("show");
					el.removeClass("collapsed");
				} else {
					el.collapse("hide");
					el.addClass("collapsed");
				}
			}
		}, 'click .nav-tag-group > div > a' : function(evt1) {
			_g.ignoreDivClick = true;
		}});
	}
	,__class__: templates_SideBar
};
var ClientUtils = function() {
	this.articleCountSubs = [];
};
ClientUtils.__name__ = true;
ClientUtils.prototype = {
	retrieveArticleCount: function(selector) {
		if(selector == null) selector = { };
		var id = Shared.utils.objectToHash(selector);
		Meteor.subscribe("countArticles",id,selector);
		return Counts.get("countArticles" + id);
	}
	,parseMarkdown: function(raw) {
		if(raw == null) return null; else return marked(raw);
	}
	,handleServerError: function(error) {
		if(js_Boot.__instanceof(error.error,Int)) toastr.error(error.details,error.reason);
	}
	,notifyInfo: function(msg,title) {
		toastr.info(msg,title);
	}
	,notifyError: function(msg,title) {
		toastr.error(msg,title);
	}
	,notifySuccess: function(msg,title) {
		toastr.success(msg,title);
	}
	,notifyWarning: function(msg,title) {
		toastr.warning(msg,title);
	}
	,alert: function(msg,label,callback) {
		bootbox.alert(msg,label,callback);
	}
	,prompt: function(msg,cancel,confirm,callback) {
		bootbox.prompt(msg,cancel,confirm,callback);
	}
	,confirm: function(msg,cancel,confirm,callback) {
		bootbox.dialog({ message : msg, buttons : { cancel : { label : cancel, className : "btn-default"}, confirm : { label : confirm, className : "btn-primary", callback : callback}}});
	}
	,__class__: ClientUtils
};
var templates_ViewArticle = function() {
};
templates_ViewArticle.__name__ = true;
templates_ViewArticle.prototype = {
	get_currentArticle: function() {
		return Session.get("currentViewArticle");
	}
	,set_currentArticle: function(a) {
		Session.set("currentViewArticle",a);
		return a;
	}
	,get_page: function() {
		return js.JQuery("#viewArticlePage");
	}
	,init: function() {
		var _g = this;
		Template.viewArticle.helpers({ article : function() {
			return _g.get_currentArticle();
		}, parsedContent : function() {
			if(_g.get_currentArticle() == null) return ""; else return Client.utils.parseMarkdown(_g.get_currentArticle().content);
		}, canUpdateArticle : function() {
			return Permissions.canUpdateArticles(_g.get_currentArticle());
		}, canRemoveArticle : function() {
			return Permissions.canRemoveArticles(_g.get_currentArticle());
		}});
		Template.viewArticle.events({ 'click #va-btnRemoveArticle' : function(evt) {
			Client.utils.confirm(Configs.client.texts.prompt_ra_msg,Configs.client.texts.prompt_ra_cancel,Configs.client.texts.prompt_ra_confirm,function() {
				model_Articles.collection.remove({ _id : _g.get_currentArticle()._id});
				FlowRouter.go("/");
			});
		}});
	}
	,show: function(args) {
		var _g = this;
		var articleId;
		if(args != null) articleId = args.articleId; else articleId = null;
		if(articleId == null) Client.utils.notifyError("Article not found");
		Meteor.subscribe("articles",{ _id : articleId},null,{ onReady : function() {
			_g.set_currentArticle(model_Articles.collection.findOne({ _id : articleId}));
		}});
		this.get_page().show(Configs.client.page_fadein_duration);
	}
	,hide: function() {
		this.get_page().hide(Configs.client.page_fadeout_duration);
	}
	,__class__: templates_ViewArticle
};
var Client = $hx_exports.Client = function() { };
Client.__name__ = true;
Client.main = function() {
	Shared.init();
	window.tags = model_Tags.collection;
	window.articles = model_Articles.collection;
	window.tag_groups = model_TagGroups.collection;
	Meteor.subscribe("tags");
	Meteor.subscribe("tag_groups",{ onReady : function() {
		Client.preloadReqs.tagGroups = true;
		Client.checkPreload();
	}});
	Client.navbar.init();
	Client.sidebar.init();
	Client.listArticles.init();
	Client.newArticle.init();
	Client.viewArticle.init();
	FlowRouter.wait();
	Client.router.init();
	SimpleSchema.messages({ eitherArticleOrLink : "An article must link to an external resource, or have embed contents, or both."});
	marked.setOptions({ highlight : function(code) {
		return hljs.highlightAuto(code).value;
	}});
	Accounts.ui.config({ passwordSignupFields : "USERNAME_AND_EMAIL"});
	toastr.options = { closeButton : true, progressBar : true};
	js.JQuery("document").ready(function(_) {
		js.JQuery("[data-toggle=\"tooltip\"]").tooltip();
	});
	Template.registerHelper("getText",function(text) {
		if(text == null) {
			console.log("warning: calling getText() with null arg0");
			return null;
		}
		var resolved = Reflect.field(Configs.client.texts,text);
		if(resolved == null) console.log("warning: text \"" + text + "\" not found");
		return resolved;
	});
	Template.registerHelper("getIconTooltip",function(tooltip,placement) {
		if(tooltip == null) {
			console.log("warning: calling getIconTooltip() with null arg0 ");
			return null;
		}
		var tip = Reflect.field(Configs.client.texts,tooltip);
		if(tip == null) {
			console.log("warning: tooltip \"" + tooltip + "\" not found");
			return null;
		}
		if(placement != "top" && placement != "bottom" && placement != "left" && placement != "right") placement = "right";
		return "<div class=\"icon-tooltip\" data-toggle=\"tooltip\" data-placement=\"" + placement + "\" title=\"" + tip + "\">\r\n\t\t\t\t<span class=\"glyphicon glyphicon-question-sign\"></span>\r\n\t\t\t</div>";
	});
	Template.registerHelper("formatUrlName",function(name) {
		return Shared.utils.formatUrlName(name);
	});
	AutoForm.debug();
};
Client.checkPreload = function() {
	var reqs = Client.preloadReqs;
	var _g = 0;
	var _g1 = Reflect.fields(reqs);
	while(_g < _g1.length) {
		var req = _g1[_g];
		++_g;
		if(reqs[req] != true) return;
	}
	FlowRouter.initialize();
};
var Configs = function() { };
Configs.__name__ = true;
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.__name__ = true;
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,__class__: EReg
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Lambda = function() { };
Lambda.__name__ = true;
Lambda.has = function(it,elt) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(x == elt) return true;
	}
	return false;
};
Math.__name__ = true;
var Permissions = $hx_exports.Permissions = function() { };
Permissions.__name__ = true;
Permissions.requireLogin = function() {
	if(!Permissions.isLogged()) {
		var err = Configs.shared.error.not_authorized;
		var error = new Meteor.Error(err.code,err.reason,err.details);
		throw(error);
	}
	return true;
};
Permissions.requirePermission = function(hasPermission) {
	if(!hasPermission) {
		var err = Configs.shared.error.no_permission;
		var error = new Meteor.Error(err.code,err.reason,err.details);
		throw(error);
	}
	return true;
};
Permissions.isLogged = function() {
	return Meteor.userId() != null;
};
Permissions.isAdmin = function() {
	return Roles.userIsInRole(Meteor.userId(),[Permissions.roles.ADMIN]);
};
Permissions.isModerator = function() {
	return Roles.userIsInRole(Meteor.userId(),[Permissions.roles.ADMIN,Permissions.roles.MODERATOR]);
};
Permissions.canInsertTags = function() {
	return Permissions.isModerator();
};
Permissions.canUpdateTags = function() {
	return Permissions.isModerator();
};
Permissions.canRemoveTags = function() {
	return Permissions.isModerator();
};
Permissions.canInsertTagGroups = function() {
	return Permissions.isModerator();
};
Permissions.canUpdateTagGroups = function() {
	return Permissions.isModerator();
};
Permissions.canRemoveTagGroups = function() {
	return Permissions.isModerator();
};
Permissions.canInsertArticles = function() {
	return Permissions.isLogged();
};
Permissions.canUpdateArticles = function(document) {
	return Permissions.isModerator() || model_Articles.isOwner(document);
};
Permissions.canRemoveArticles = function(document) {
	return Permissions.isModerator() || model_Articles.isOwner(document);
};
Permissions.canUpdateUsers = function(document,fields) {
	return Permissions.isAdmin();
};
Permissions.canRemoveUser = function(document) {
	return Permissions.isAdmin();
};
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		if (e instanceof js__$Boot_HaxeError) e = e.val;
		return null;
	}
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
var SharedUtils = $hx_exports.sharedUtils = function() {
};
SharedUtils.__name__ = true;
SharedUtils.prototype = {
	objectToHash: function(o) {
		var str = Std.string(o);
		return haxe_crypto_Md5.encode(str);
	}
	,resolveTags: function(g) {
		var tags = model_Tags.collection.find().fetch();
		var resolved = [];
		var _g = 0;
		var _g1 = g.tags;
		while(_g < _g1.length) {
			var entry = _g1[_g];
			++_g;
			if(StringTools.startsWith(entry,"~")) {
				var split = entry.split("/");
				var reg = new EReg(split[1],split[2]);
				var _g2 = 0;
				while(_g2 < tags.length) {
					var t = tags[_g2];
					++_g2;
					if(reg.match(t.name) && !Lambda.has(resolved,t.name) && t != g.mainTag) resolved.push(t.name);
				}
			} else {
				var _g21 = 0;
				while(_g21 < tags.length) {
					var t1 = tags[_g21];
					++_g21;
					if(t1.name == entry && !Lambda.has(resolved,t1.name) && t1 != g.mainTag) {
						resolved = [t1.name];
						break;
					}
				}
			}
		}
		resolved.sort(function(a,b) {
			if(a < b) return -1;
			if(a > b) return 1;
			return 0;
		});
		return resolved;
	}
	,formatUrlName: function(name) {
		name = StringTools.trim(name);
		name = StringTools.replace(name," ","-");
		return name;
	}
	,__class__: SharedUtils
};
var Shared = $hx_exports.Shared = function() { };
Shared.__name__ = true;
Shared.init = function() {
	new model_TagGroups();
	new model_Articles();
	new model_Tags();
	model_Articles.collection.attachSchema(model_Articles.schema);
	model_Tags.collection.attachSchema(model_Tags.schema);
	model_TagGroups.collection.attachSchema(model_TagGroups.schema);
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var StringTools = function() { };
StringTools.__name__ = true;
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && HxOverrides.substr(s,0,start.length) == start;
};
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	return c > 8 && c < 14 || c == 32;
};
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return HxOverrides.substr(s,r,l - r); else return s;
};
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) return HxOverrides.substr(s,0,l - r); else return s;
};
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
};
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
};
var haxe__$Int64__$_$_$Int64 = function(high,low) {
	this.high = high;
	this.low = low;
};
haxe__$Int64__$_$_$Int64.__name__ = true;
haxe__$Int64__$_$_$Int64.prototype = {
	__class__: haxe__$Int64__$_$_$Int64
};
var haxe_crypto_Md5 = function() {
};
haxe_crypto_Md5.__name__ = true;
haxe_crypto_Md5.encode = function(s) {
	var m = new haxe_crypto_Md5();
	var h = m.doEncode(haxe_crypto_Md5.str2blks(s));
	return m.hex(h);
};
haxe_crypto_Md5.str2blks = function(str) {
	var nblk = (str.length + 8 >> 6) + 1;
	var blks = [];
	var blksSize = nblk * 16;
	var _g = 0;
	while(_g < blksSize) {
		var i1 = _g++;
		blks[i1] = 0;
	}
	var i = 0;
	while(i < str.length) {
		blks[i >> 2] |= HxOverrides.cca(str,i) << (str.length * 8 + i) % 4 * 8;
		i++;
	}
	blks[i >> 2] |= 128 << (str.length * 8 + i) % 4 * 8;
	var l = str.length * 8;
	var k = nblk * 16 - 2;
	blks[k] = l & 255;
	blks[k] |= (l >>> 8 & 255) << 8;
	blks[k] |= (l >>> 16 & 255) << 16;
	blks[k] |= (l >>> 24 & 255) << 24;
	return blks;
};
haxe_crypto_Md5.prototype = {
	bitOR: function(a,b) {
		var lsb = a & 1 | b & 1;
		var msb31 = a >>> 1 | b >>> 1;
		return msb31 << 1 | lsb;
	}
	,bitXOR: function(a,b) {
		var lsb = a & 1 ^ b & 1;
		var msb31 = a >>> 1 ^ b >>> 1;
		return msb31 << 1 | lsb;
	}
	,bitAND: function(a,b) {
		var lsb = a & 1 & (b & 1);
		var msb31 = a >>> 1 & b >>> 1;
		return msb31 << 1 | lsb;
	}
	,addme: function(x,y) {
		var lsw = (x & 65535) + (y & 65535);
		var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
		return msw << 16 | lsw & 65535;
	}
	,hex: function(a) {
		var str = "";
		var hex_chr = "0123456789abcdef";
		var _g = 0;
		while(_g < a.length) {
			var num = a[_g];
			++_g;
			var _g1 = 0;
			while(_g1 < 4) {
				var j = _g1++;
				str += hex_chr.charAt(num >> j * 8 + 4 & 15) + hex_chr.charAt(num >> j * 8 & 15);
			}
		}
		return str;
	}
	,rol: function(num,cnt) {
		return num << cnt | num >>> 32 - cnt;
	}
	,cmn: function(q,a,b,x,s,t) {
		return this.addme(this.rol(this.addme(this.addme(a,q),this.addme(x,t)),s),b);
	}
	,ff: function(a,b,c,d,x,s,t) {
		return this.cmn(this.bitOR(this.bitAND(b,c),this.bitAND(~b,d)),a,b,x,s,t);
	}
	,gg: function(a,b,c,d,x,s,t) {
		return this.cmn(this.bitOR(this.bitAND(b,d),this.bitAND(c,~d)),a,b,x,s,t);
	}
	,hh: function(a,b,c,d,x,s,t) {
		return this.cmn(this.bitXOR(this.bitXOR(b,c),d),a,b,x,s,t);
	}
	,ii: function(a,b,c,d,x,s,t) {
		return this.cmn(this.bitXOR(c,this.bitOR(b,~d)),a,b,x,s,t);
	}
	,doEncode: function(x) {
		var a = 1732584193;
		var b = -271733879;
		var c = -1732584194;
		var d = 271733878;
		var step;
		var i = 0;
		while(i < x.length) {
			var olda = a;
			var oldb = b;
			var oldc = c;
			var oldd = d;
			step = 0;
			a = this.ff(a,b,c,d,x[i],7,-680876936);
			d = this.ff(d,a,b,c,x[i + 1],12,-389564586);
			c = this.ff(c,d,a,b,x[i + 2],17,606105819);
			b = this.ff(b,c,d,a,x[i + 3],22,-1044525330);
			a = this.ff(a,b,c,d,x[i + 4],7,-176418897);
			d = this.ff(d,a,b,c,x[i + 5],12,1200080426);
			c = this.ff(c,d,a,b,x[i + 6],17,-1473231341);
			b = this.ff(b,c,d,a,x[i + 7],22,-45705983);
			a = this.ff(a,b,c,d,x[i + 8],7,1770035416);
			d = this.ff(d,a,b,c,x[i + 9],12,-1958414417);
			c = this.ff(c,d,a,b,x[i + 10],17,-42063);
			b = this.ff(b,c,d,a,x[i + 11],22,-1990404162);
			a = this.ff(a,b,c,d,x[i + 12],7,1804603682);
			d = this.ff(d,a,b,c,x[i + 13],12,-40341101);
			c = this.ff(c,d,a,b,x[i + 14],17,-1502002290);
			b = this.ff(b,c,d,a,x[i + 15],22,1236535329);
			a = this.gg(a,b,c,d,x[i + 1],5,-165796510);
			d = this.gg(d,a,b,c,x[i + 6],9,-1069501632);
			c = this.gg(c,d,a,b,x[i + 11],14,643717713);
			b = this.gg(b,c,d,a,x[i],20,-373897302);
			a = this.gg(a,b,c,d,x[i + 5],5,-701558691);
			d = this.gg(d,a,b,c,x[i + 10],9,38016083);
			c = this.gg(c,d,a,b,x[i + 15],14,-660478335);
			b = this.gg(b,c,d,a,x[i + 4],20,-405537848);
			a = this.gg(a,b,c,d,x[i + 9],5,568446438);
			d = this.gg(d,a,b,c,x[i + 14],9,-1019803690);
			c = this.gg(c,d,a,b,x[i + 3],14,-187363961);
			b = this.gg(b,c,d,a,x[i + 8],20,1163531501);
			a = this.gg(a,b,c,d,x[i + 13],5,-1444681467);
			d = this.gg(d,a,b,c,x[i + 2],9,-51403784);
			c = this.gg(c,d,a,b,x[i + 7],14,1735328473);
			b = this.gg(b,c,d,a,x[i + 12],20,-1926607734);
			a = this.hh(a,b,c,d,x[i + 5],4,-378558);
			d = this.hh(d,a,b,c,x[i + 8],11,-2022574463);
			c = this.hh(c,d,a,b,x[i + 11],16,1839030562);
			b = this.hh(b,c,d,a,x[i + 14],23,-35309556);
			a = this.hh(a,b,c,d,x[i + 1],4,-1530992060);
			d = this.hh(d,a,b,c,x[i + 4],11,1272893353);
			c = this.hh(c,d,a,b,x[i + 7],16,-155497632);
			b = this.hh(b,c,d,a,x[i + 10],23,-1094730640);
			a = this.hh(a,b,c,d,x[i + 13],4,681279174);
			d = this.hh(d,a,b,c,x[i],11,-358537222);
			c = this.hh(c,d,a,b,x[i + 3],16,-722521979);
			b = this.hh(b,c,d,a,x[i + 6],23,76029189);
			a = this.hh(a,b,c,d,x[i + 9],4,-640364487);
			d = this.hh(d,a,b,c,x[i + 12],11,-421815835);
			c = this.hh(c,d,a,b,x[i + 15],16,530742520);
			b = this.hh(b,c,d,a,x[i + 2],23,-995338651);
			a = this.ii(a,b,c,d,x[i],6,-198630844);
			d = this.ii(d,a,b,c,x[i + 7],10,1126891415);
			c = this.ii(c,d,a,b,x[i + 14],15,-1416354905);
			b = this.ii(b,c,d,a,x[i + 5],21,-57434055);
			a = this.ii(a,b,c,d,x[i + 12],6,1700485571);
			d = this.ii(d,a,b,c,x[i + 3],10,-1894986606);
			c = this.ii(c,d,a,b,x[i + 10],15,-1051523);
			b = this.ii(b,c,d,a,x[i + 1],21,-2054922799);
			a = this.ii(a,b,c,d,x[i + 8],6,1873313359);
			d = this.ii(d,a,b,c,x[i + 15],10,-30611744);
			c = this.ii(c,d,a,b,x[i + 6],15,-1560198380);
			b = this.ii(b,c,d,a,x[i + 13],21,1309151649);
			a = this.ii(a,b,c,d,x[i + 4],6,-145523070);
			d = this.ii(d,a,b,c,x[i + 11],10,-1120210379);
			c = this.ii(c,d,a,b,x[i + 2],15,718787259);
			b = this.ii(b,c,d,a,x[i + 9],21,-343485551);
			a = this.addme(a,olda);
			b = this.addme(b,oldb);
			c = this.addme(c,oldc);
			d = this.addme(d,oldd);
			i += 16;
		}
		return [a,b,c,d];
	}
	,__class__: haxe_crypto_Md5
};
var haxe_io_Error = { __ename__ : true, __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] };
haxe_io_Error.Blocked = ["Blocked",0];
haxe_io_Error.Blocked.toString = $estr;
haxe_io_Error.Blocked.__enum__ = haxe_io_Error;
haxe_io_Error.Overflow = ["Overflow",1];
haxe_io_Error.Overflow.toString = $estr;
haxe_io_Error.Overflow.__enum__ = haxe_io_Error;
haxe_io_Error.OutsideBounds = ["OutsideBounds",2];
haxe_io_Error.OutsideBounds.toString = $estr;
haxe_io_Error.OutsideBounds.__enum__ = haxe_io_Error;
haxe_io_Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe_io_Error; $x.toString = $estr; return $x; };
var haxe_io_FPHelper = function() { };
haxe_io_FPHelper.__name__ = true;
haxe_io_FPHelper.i32ToFloat = function(i) {
	var sign = 1 - (i >>> 31 << 1);
	var exp = i >>> 23 & 255;
	var sig = i & 8388607;
	if(sig == 0 && exp == 0) return 0.0;
	return sign * (1 + Math.pow(2,-23) * sig) * Math.pow(2,exp - 127);
};
haxe_io_FPHelper.floatToI32 = function(f) {
	if(f == 0) return 0;
	var af;
	if(f < 0) af = -f; else af = f;
	var exp = Math.floor(Math.log(af) / 0.6931471805599453);
	if(exp < -127) exp = -127; else if(exp > 128) exp = 128;
	var sig = Math.round((af / Math.pow(2,exp) - 1) * 8388608) & 8388607;
	return (f < 0?-2147483648:0) | exp + 127 << 23 | sig;
};
haxe_io_FPHelper.i64ToDouble = function(low,high) {
	var sign = 1 - (high >>> 31 << 1);
	var exp = (high >> 20 & 2047) - 1023;
	var sig = (high & 1048575) * 4294967296. + (low >>> 31) * 2147483648. + (low & 2147483647);
	if(sig == 0 && exp == -1023) return 0.0;
	return sign * (1.0 + Math.pow(2,-52) * sig) * Math.pow(2,exp);
};
haxe_io_FPHelper.doubleToI64 = function(v) {
	var i64 = haxe_io_FPHelper.i64tmp;
	if(v == 0) {
		i64.low = 0;
		i64.high = 0;
	} else {
		var av;
		if(v < 0) av = -v; else av = v;
		var exp = Math.floor(Math.log(av) / 0.6931471805599453);
		var sig;
		var v1 = (av / Math.pow(2,exp) - 1) * 4503599627370496.;
		sig = Math.round(v1);
		var sig_l = sig | 0;
		var sig_h = sig / 4294967296.0 | 0;
		i64.low = sig_l;
		i64.high = (v < 0?-2147483648:0) | exp + 1023 << 20 | sig_h;
	}
	return i64;
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__name__ = true;
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	__class__: js__$Boot_HaxeError
});
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js_Boot.__nativeClassName(o);
		if(name != null) return js_Boot.__resolveNativeClass(name);
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js_Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js_Boot.__interfLoop(cc.__super__,cl);
};
js_Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js_Boot.__interfLoop(js_Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js_Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js_Boot.__cast = function(o,t) {
	if(js_Boot.__instanceof(o,t)) return o; else throw new js__$Boot_HaxeError("Cannot cast " + Std.string(o) + " to " + Std.string(t));
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js_Boot.__isNativeObj = function(o) {
	return js_Boot.__nativeClassName(o) != null;
};
js_Boot.__resolveNativeClass = function(name) {
	return (Function("return typeof " + name + " != \"undefined\" ? " + name + " : null"))();
};
var js_html_compat_ArrayBuffer = function(a) {
	if((a instanceof Array) && a.__enum__ == null) {
		this.a = a;
		this.byteLength = a.length;
	} else {
		var len = a;
		this.a = [];
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			this.a[i] = 0;
		}
		this.byteLength = len;
	}
};
js_html_compat_ArrayBuffer.__name__ = true;
js_html_compat_ArrayBuffer.sliceImpl = function(begin,end) {
	var u = new Uint8Array(this,begin,end == null?null:end - begin);
	var result = new ArrayBuffer(u.byteLength);
	var resultArray = new Uint8Array(result);
	resultArray.set(u);
	return result;
};
js_html_compat_ArrayBuffer.prototype = {
	slice: function(begin,end) {
		return new js_html_compat_ArrayBuffer(this.a.slice(begin,end));
	}
	,__class__: js_html_compat_ArrayBuffer
};
var js_html_compat_DataView = function(buffer,byteOffset,byteLength) {
	this.buf = buffer;
	if(byteOffset == null) this.offset = 0; else this.offset = byteOffset;
	if(byteLength == null) this.length = buffer.byteLength - this.offset; else this.length = byteLength;
	if(this.offset < 0 || this.length < 0 || this.offset + this.length > buffer.byteLength) throw new js__$Boot_HaxeError(haxe_io_Error.OutsideBounds);
};
js_html_compat_DataView.__name__ = true;
js_html_compat_DataView.prototype = {
	getInt8: function(byteOffset) {
		var v = this.buf.a[this.offset + byteOffset];
		if(v >= 128) return v - 256; else return v;
	}
	,getUint8: function(byteOffset) {
		return this.buf.a[this.offset + byteOffset];
	}
	,getInt16: function(byteOffset,littleEndian) {
		var v = this.getUint16(byteOffset,littleEndian);
		if(v >= 32768) return v - 65536; else return v;
	}
	,getUint16: function(byteOffset,littleEndian) {
		if(littleEndian) return this.buf.a[this.offset + byteOffset] | this.buf.a[this.offset + byteOffset + 1] << 8; else return this.buf.a[this.offset + byteOffset] << 8 | this.buf.a[this.offset + byteOffset + 1];
	}
	,getInt32: function(byteOffset,littleEndian) {
		var p = this.offset + byteOffset;
		var a = this.buf.a[p++];
		var b = this.buf.a[p++];
		var c = this.buf.a[p++];
		var d = this.buf.a[p++];
		if(littleEndian) return a | b << 8 | c << 16 | d << 24; else return d | c << 8 | b << 16 | a << 24;
	}
	,getUint32: function(byteOffset,littleEndian) {
		var v = this.getInt32(byteOffset,littleEndian);
		if(v < 0) return v + 4294967296.; else return v;
	}
	,getFloat32: function(byteOffset,littleEndian) {
		return haxe_io_FPHelper.i32ToFloat(this.getInt32(byteOffset,littleEndian));
	}
	,getFloat64: function(byteOffset,littleEndian) {
		var a = this.getInt32(byteOffset,littleEndian);
		var b = this.getInt32(byteOffset + 4,littleEndian);
		return haxe_io_FPHelper.i64ToDouble(littleEndian?a:b,littleEndian?b:a);
	}
	,setInt8: function(byteOffset,value) {
		if(value < 0) this.buf.a[byteOffset + this.offset] = value + 128 & 255; else this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setUint8: function(byteOffset,value) {
		this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setInt16: function(byteOffset,value,littleEndian) {
		this.setUint16(byteOffset,value < 0?value + 65536:value,littleEndian);
	}
	,setUint16: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
		} else {
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p] = value & 255;
		}
	}
	,setInt32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,value,littleEndian);
	}
	,setUint32: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p++] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >>> 24;
		} else {
			this.buf.a[p++] = value >>> 24;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value & 255;
		}
	}
	,setFloat32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,haxe_io_FPHelper.floatToI32(value),littleEndian);
	}
	,setFloat64: function(byteOffset,value,littleEndian) {
		var i64 = haxe_io_FPHelper.doubleToI64(value);
		if(littleEndian) {
			this.setUint32(byteOffset,i64.low);
			this.setUint32(byteOffset,i64.high);
		} else {
			this.setUint32(byteOffset,i64.high);
			this.setUint32(byteOffset,i64.low);
		}
	}
	,__class__: js_html_compat_DataView
};
var js_html_compat_Uint8Array = function() { };
js_html_compat_Uint8Array.__name__ = true;
js_html_compat_Uint8Array._new = function(arg1,offset,length) {
	var arr;
	if(typeof(arg1) == "number") {
		arr = [];
		var _g = 0;
		while(_g < arg1) {
			var i = _g++;
			arr[i] = 0;
		}
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js_html_compat_ArrayBuffer(arr);
	} else if(js_Boot.__instanceof(arg1,js_html_compat_ArrayBuffer)) {
		var buffer = arg1;
		if(offset == null) offset = 0;
		if(length == null) length = buffer.byteLength - offset;
		if(offset == 0) arr = buffer.a; else arr = buffer.a.slice(offset,offset + length);
		arr.byteLength = arr.length;
		arr.byteOffset = offset;
		arr.buffer = buffer;
	} else if((arg1 instanceof Array) && arg1.__enum__ == null) {
		arr = arg1.slice();
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js_html_compat_ArrayBuffer(arr);
	} else throw new js__$Boot_HaxeError("TODO " + Std.string(arg1));
	arr.subarray = js_html_compat_Uint8Array._subarray;
	arr.set = js_html_compat_Uint8Array._set;
	return arr;
};
js_html_compat_Uint8Array._set = function(arg,offset) {
	var t = this;
	if(js_Boot.__instanceof(arg.buffer,js_html_compat_ArrayBuffer)) {
		var a = arg;
		if(arg.byteLength + offset > t.byteLength) throw new js__$Boot_HaxeError("set() outside of range");
		var _g1 = 0;
		var _g = arg.byteLength;
		while(_g1 < _g) {
			var i = _g1++;
			t[i + offset] = a[i];
		}
	} else if((arg instanceof Array) && arg.__enum__ == null) {
		var a1 = arg;
		if(a1.length + offset > t.byteLength) throw new js__$Boot_HaxeError("set() outside of range");
		var _g11 = 0;
		var _g2 = a1.length;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t[i1 + offset] = a1[i1];
		}
	} else throw new js__$Boot_HaxeError("TODO");
};
js_html_compat_Uint8Array._subarray = function(start,end) {
	var t = this;
	var a = js_html_compat_Uint8Array._new(t.slice(start,end));
	a.byteOffset = start;
	return a;
};
var model_Articles = function() {
	Mongo.Collection.call(this,"articles");
	model_Articles.collection = this;
	model_Articles.schema = new SimpleSchema({ title : { type : String, max : 100}, description : { type : String, max : 512}, link : { type : String, max : 512, optional : true, regEx : SimpleSchema.RegEx.Url, autoform : { afFieldInput : { type : "url"}}, custom : function() {
		if(!this.field("link").isSet && !this.field("content").isSet) return "eitherArticleOrLink";
		return undefined;
	}}, content : { type : String, max : 30000, optional : true, custom : function() {
		if(!this.field("link").isSet && !this.field("content").isSet) return "eitherArticleOrLink";
		return undefined;
	}}, tags : { type : [String], optional : true, autoform : { type : "tags", afFieldInput : { maxTags : 10, maxChars : 30}}, autoValue : function() {
		if(this.field("tags").isSet) {
			var tags = this.field("tags").value;
			var resolved = [];
			var _g = 0;
			while(_g < tags.length) {
				var t = tags[_g];
				++_g;
				var res = model_Tags.getOrCreate(t);
				if(res != null) resolved.push(res.name);
			}
			return resolved;
		}
		return undefined;
	}}, user : { type : String, optional : true, autoValue : function() {
		if(this.isInsert) return Meteor.userId(); else {
			this.unset();
			return undefined;
		}
	}}, username : { type : String, optional : true, autoValue : function() {
		if(this.isInsert && Meteor.user() != null) return Meteor.user().username; else {
			this.unset();
			return undefined;
		}
	}}, votes : { type : Number, optional : true, autoValue : function() {
		if(this.isInsert) return 0; else {
			this.unset();
			return undefined;
		}
	}}, created : { type : Date, optional : true, autoValue : function() {
		if(this.isInsert) return new Date(); else {
			this.unset();
			return undefined;
		}
	}}, modified : { type : Date, optional : true, autoValue : function() {
		return new Date();
	}}, editedBy : { type : String, optional : true, autoValue : function() {
		return Meteor.userId();
	}}});
};
model_Articles.__name__ = true;
model_Articles.isOwner = function(document) {
	return document.user != null && Meteor.userId() != null && document.user == Meteor.userId();
};
model_Articles.queryFromTags = function(_tags) {
	return { tags : { '$in' : _tags}};
};
model_Articles.__super__ = Mongo.Collection;
model_Articles.prototype = $extend(Mongo.Collection.prototype,{
	__class__: model_Articles
});
var model_TagGroups = function() {
	Mongo.Collection.call(this,"tag_groups");
	model_TagGroups.collection = this;
	model_TagGroups.schema = new SimpleSchema({ name : { type : String, unique : true}, mainTag : { type : String, max : 30}, weight : { type : Number, defaultValue : 10}, icon : { type : String}, tags : { optional : true, type : [String]}});
};
model_TagGroups.__name__ = true;
model_TagGroups.__super__ = Mongo.Collection;
model_TagGroups.prototype = $extend(Mongo.Collection.prototype,{
	__class__: model_TagGroups
});
var model_Tags = function() {
	Mongo.Collection.call(this,"tags");
	model_Tags.collection = this;
	model_Tags.regEx = new RegExp("^[a-zA-Z0-9._-]+$");
	model_Tags.schema = new SimpleSchema({ name : { type : String, unique : true, regEx : model_Tags.regEx, max : 30, autoValue : function() {
		if(this.field("name").isSet) return model_Tags.format(js_Boot.__cast(this.field("name").value , String));
		return undefined;
	}}, articles : { type : [String], optional : true, autoValue : function() {
		if(this.isInsert) return [];
		return undefined;
	}}});
};
model_Tags.__name__ = true;
model_Tags.format = function(name) {
	name = name.toLowerCase();
	if(!model_Tags.regEx.test(name)) return null;
	return name;
};
model_Tags.getOrCreate = function(name) {
	name = model_Tags.format(name);
	var exists = model_Tags.collection.findOne({ name : name});
	if(exists == null) {
		var newTag = model_Tags.collection.insert({ name : name});
		exists = model_Tags.collection.findOne({ _id : newTag});
	}
	return exists;
};
model_Tags.__super__ = Mongo.Collection;
model_Tags.prototype = $extend(Mongo.Collection.prototype,{
	__class__: model_Tags
});
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
var q = window.jQuery;
var js = js || {}
js.JQuery = q;
q.fn.iterator = function() {
	return { pos : 0, j : this, hasNext : function() {
		return this.pos < this.j.length;
	}, next : function() {
		return $(this.j[this.pos++]);
	}};
};
var ArrayBuffer = (Function("return typeof ArrayBuffer != 'undefined' ? ArrayBuffer : null"))() || js_html_compat_ArrayBuffer;
if(ArrayBuffer.prototype.slice == null) ArrayBuffer.prototype.slice = js_html_compat_ArrayBuffer.sliceImpl;
var DataView = (Function("return typeof DataView != 'undefined' ? DataView : null"))() || js_html_compat_DataView;
var Uint8Array = (Function("return typeof Uint8Array != 'undefined' ? Uint8Array : null"))() || js_html_compat_Uint8Array._new;
Client.utils = new ClientUtils();
Client.navbar = new templates_Navbar();
Client.sidebar = new templates_SideBar();
Client.listArticles = new templates_ListArticles();
Client.newArticle = new templates_NewArticle();
Client.viewArticle = new templates_ViewArticle();
Client.router = new Router();
Client.preloadReqs = { tagGroups : false};
Configs.shared = { error : { not_authorized : { code : 401, reason : "Not authorized", details : "User must be logged."}, no_permission : { code : 403, reason : "No permission", details : "User does not have the required permissions."}, args_article_not_found : { code : 412, reason : "Invalid argument : article", details : "Article not found."}, args_user_not_found : { code : 412, reason : "Invalid argument : user", details : "User not found."}, args_bad_permissions : { code : 412, reason : "Invalid argument : permissions", details : "Invalid permission types"}}};
Configs.client = { page_size : 10, page_fadein_duration : 500, page_fadeout_duration : 0, texts : { la_showing_all : "Showing <em>all</em> articles", la_showing_tag : function(tag) {
	return "Showing <em>" + tag + "</em> tag";
}, la_showing_group : function(group) {
	return "Showing <em>" + group + "</em> group";
}, la_showing_query : function(query) {
	return "Showing results for <em>" + query + "</em> query";
}, la_showing_ungrouped : "Showing ungrouped articles", na_placeh_title : "Title goes here", na_placeh_desc : "Brief description about the subject", na_placeh_link : "Url to the original article, ex: http://www.site.com/article", na_placeh_content : "Text contents using github flavored markdown", na_placeh_tags : "", na_label_title : "Title*", na_label_desc : "Description*", na_label_link : "Link ", na_label_content : "Contents ", na_label_tags : "Tags ", na_tt_links : "An url for the original post (if any), required if not posting the contents directly here.", na_tt_contents : "The article contents are written using markdown notation, articles may contain only links to external posts like blogs or other webpages, in that case contents are not required.", na_tt_tags : "Tags may be inserted by pressing `comma` or `enter` keys. Depending on the tags choosen, the article may be added to different groups, for eg. using `haxe-macros` the article will be added to `Haxe` group inside `macros` subgroup", na_a_featured : "Select from existing grouped tags.", na_fmodal_title : "Select Featured Tags", na_fmodal_desc : "Select one or more existing tags to make your article visible.", prompt_ra_msg : "The article will be permanently deleted, are you sure?", prompt_ra_confirm : "Yes", prompt_ra_cancel : "No"}};
Permissions.roles = { ADMIN : "ADMIN", MODERATOR : "MODERATOR"};
Shared.utils = new SharedUtils();
haxe_io_FPHelper.i64tmp = (function($this) {
	var $r;
	var x = new haxe__$Int64__$_$_$Int64(0,0);
	$r = x;
	return $r;
}(this));
js_Boot.__toStr = {}.toString;
js_html_compat_Uint8Array.BYTES_PER_ELEMENT = 1;
model_Articles.NAME = "articles";
model_TagGroups.NAME = "tag_groups";
model_Tags.NAME = "tags";
model_Tags.MAX_CHARS = 30;
Client.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : exports);

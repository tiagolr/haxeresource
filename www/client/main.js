(function (console) { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var CRouter = function() { };
CRouter.init = function() {
	Router.configure({ loadingTemplate : "preload"});
	Router.route("/",function() {
		templates_ListArticles.get_page().show(500);
	},{ onStop : function() {
		templates_ListArticles.get_page().hide(500);
	}});
	Router.route("/new",function() {
		templates_NewArticle.get_page().show(500);
	},{ onStop : function() {
		templates_NewArticle.get_page().hide(500);
	}});
	Router.route("/view",function() {
		templates_ViewArticle.get_page().show();
	},{ onStop : function() {
		templates_ViewArticle.get_page().hide();
	}});
};
var Client = function() { };
Client.main = function() {
	Shared.init();
	window.tags = model_Tags.collection._collection;
	window.articles = model_Articles.collection._collection;
	window.groups = model_TagGroups.collection._collection;
	Meteor.subscribe("tags");
	Meteor.subscribe("tag_groups");
	Meteor.subscribe("articles");
	templates_Navbar.init();
	templates_SideBar.init();
	templates_ListArticles.init();
	templates_NewArticle.init();
	templates_ViewArticle.init();
	CRouter.init();
	marked.setOptions({ highlight : function(code) {
		return hljs.highlightAuto(code).value;
	}});
};
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
};
var HxOverrides = function() { };
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
var Shared = function() { };
Shared.init = function() {
	new model_TagGroups();
	new model_Articles();
	new model_Tags();
};
var StringTools = function() { };
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && HxOverrides.substr(s,0,start.length) == start;
};
var model_Articles = function() {
	Mongo.Collection.call(this,"articles");
	model_Articles.collection = this;
};
model_Articles.create = function(article) {
	var resolvedTags = [];
	var _g = 0;
	var _g1 = article.tags;
	while(_g < _g1.length) {
		var tag = _g1[_g];
		++_g;
		var t = model_Tags.collection.findOne({ name : tag});
		if(t != null) resolvedTags.push(t._id); else {
			var created = model_Tags.create({ name : tag});
			if(created != null) resolvedTags.push(created._id);
		}
	}
	article.tags = resolvedTags;
	if(article.comments == null) article.comments = [];
	if(article.upvotes == null) article.upvotes = 0;
	if(article.downvotes == null) article.downvotes = 0;
	article.created = new Date();
	article.modified = new Date();
	model_Articles.collection.insert(article);
	return article;
};
model_Articles.__super__ = Mongo.Collection;
model_Articles.prototype = $extend(Mongo.Collection.prototype,{
});
var model_TagGroups = function() {
	Mongo.Collection.call(this,"tag_groups");
	model_TagGroups.collection = this;
};
model_TagGroups.create = function(tagGroup) {
	model_TagGroups.collection.insert(tagGroup);
	return tagGroup;
};
model_TagGroups.__super__ = Mongo.Collection;
model_TagGroups.prototype = $extend(Mongo.Collection.prototype,{
});
var model_Tags = function() {
	Mongo.Collection.call(this,"tags");
	model_Tags.collection = this;
};
model_Tags.create = function(tag) {
	model_Tags.collection.insert(tag);
	return tag;
};
model_Tags.__super__ = Mongo.Collection;
model_Tags.prototype = $extend(Mongo.Collection.prototype,{
});
var templates_ListArticles = function() { };
templates_ListArticles.get_page = function() {
	return js.JQuery("#listArticlesPage");
};
templates_ListArticles.init = function() {
	Template.listArticles.helpers({ articles : function() {
		return model_Articles.collection.find();
	}});
	Template.articleRow.helpers({ formatDate : function(date) {
		return vagueTime.get({ from : new Date(), to : date});
	}, formatLink : function(link) {
		if(!StringTools.startsWith(link,"http://")) link = "http://" + link;
		return link;
	}});
	var t = js.JQuery(window.document).on("click",".articleRowToggle",function(event) {
		var target = js.JQuery(event.target.getAttribute("data-target"));
		var rows = js.JQuery(".articleRowBody");
		var isCollapsed = target.hasClass("collapsed");
		var $it0 = (rows.iterator)();
		while( $it0.hasNext() ) {
			var row = $it0.next();
			if(row == target) row.collapse(isCollapsed?"show":"hide"); else row.collapse("hide");
		}
	});
};
var templates_Navbar = function() { };
templates_Navbar.init = function() {
};
var templates_NewArticle = function() { };
templates_NewArticle.get_page = function() {
	return js.JQuery("#newArticlePage");
};
templates_NewArticle.init = function() {
	Template.newArticle.events({ 'click #btnPreviewArticle' : function(evt) {
		var title = js.JQuery("#naf-articleTitle").val();
		var content = js.JQuery("#naf-articleContent").val();
		js.JQuery("#previewTitle").html(title);
		js.JQuery("#previewContent").html(marked(content));
	}});
	Template.newArticle.helpers({ schema : function() {
		return new SimpleSchema({ title : { type : String, max : 100}, description : { type : String, max : 512}, link : { type : String, max : 512, autoform : { afFieldInput : { type : "url"}}}, content : { type : String, max : 30000, optional : true}, tags : { type : [String], autoform : { type : "tags", afFieldInput : { maxTags : 10, maxChars : 30}}}});
	}});
};
var templates_SideBar = function() { };
templates_SideBar.init = function() {
	Template.sidebar.helpers({ tag_groups : function() {
		var tags = model_Tags.collection.find().fetch();
		var groups = model_TagGroups.collection.find().fetch();
		var _g = 0;
		while(_g < groups.length) {
			var g = groups[_g];
			++_g;
			var resolvedTags = [];
			var _g1 = 0;
			var _g2 = g.tags;
			while(_g1 < _g2.length) {
				var t = _g2[_g1];
				++_g1;
				var res = templates_SideBar.resolveTags(t,tags);
				var _g3 = 0;
				while(_g3 < res.length) {
					var r = res[_g3];
					++_g3;
					if(HxOverrides.indexOf(resolvedTags,r,0) == -1) resolvedTags.push(r);
				}
			}
			g.tags = resolvedTags;
		}
		return groups;
	}});
};
templates_SideBar.resolveTags = function(strOrRegex,tags) {
	var resolved = [];
	if(StringTools.startsWith(strOrRegex,"~")) {
		var split = strOrRegex.split("/");
		var reg = new EReg(split[1],split[2]);
		var _g = 0;
		while(_g < tags.length) {
			var t = tags[_g];
			++_g;
			if(reg.match(t.name)) resolved.push(t);
		}
	} else {
		var _g1 = 0;
		while(_g1 < tags.length) {
			var t1 = tags[_g1];
			++_g1;
			if(t1.name == strOrRegex) {
				resolved = [t1];
				break;
			}
		}
	}
	return resolved;
};
var templates_ViewArticle = function() { };
templates_ViewArticle.get_page = function() {
	return js.JQuery("#viewArticlePage");
};
templates_ViewArticle.init = function() {
};
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
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
CRouter.FADE_DURATION = 500;
model_Articles.NAME = "articles";
model_TagGroups.NAME = "tag_groups";
model_Tags.NAME = "tags";
Client.main();
})(typeof console != "undefined" ? console : {log:function(){}});

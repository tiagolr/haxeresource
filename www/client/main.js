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
	window.categories = model_Categories.collection._collection;
	window.articles = model_Articles.collection._collection;
	Meteor.subscribe("categories");
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
var Shared = function() { };
Shared.init = function() {
	new model_Categories();
	new model_Articles();
};
var StringTools = function() { };
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && HxOverrides.substr(s,0,start.length) == start;
};
var model_Articles = function() {
	Mongo.Collection.call(this,"articles");
	model_Articles.collection = this;
};
model_Articles.create = function(title,description,link,contents,categoryId,user) {
	return { title : title, description : description, link : link, contents : contents, categoryId : categoryId, upvotes : 0, downvotes : 0, comments : 0, created : new Date(), modified : new Date(), user : user};
};
model_Articles.__super__ = Mongo.Collection;
model_Articles.prototype = $extend(Mongo.Collection.prototype,{
});
var model_Categories = function() {
	Mongo.Collection.call(this,"categories");
	model_Categories.collection = this;
};
model_Categories.create = function(name,description,icon,parentId) {
	return { name : name, description : description, icon : icon, parentId : parentId};
};
model_Categories.__super__ = Mongo.Collection;
model_Categories.prototype = $extend(Mongo.Collection.prototype,{
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
		return new SimpleSchema({ title : { type : String, max : 100}, description : { type : String, max : 512}, link : { type : String, max : 512, autoform : { afFieldInput : { type : "url"}}}, content : { type : String, max : 30000, optional : true}, category : { type : String}, tags : { type : [String], autoform : { type : "tags", afFieldInput : { maxTags : 5, maxChars : 25}}}});
	}, categories : function() {
		return [{ label : "Cat1", value : 1},{ label : "Cat2", value : 2},{ label : "Cat3", value : 3},{ label : "Cat4", value : 4}];
	}});
};
var templates_SideBar = function() { };
templates_SideBar.init = function() {
	Template.sidebar.helpers({ categories : function() {
		var $final = [];
		var cats = model_Categories.collection.find().fetch();
		var _g = 0;
		while(_g < cats.length) {
			var c = cats[_g];
			++_g;
			if(c.parentId == null) $final.push(c); else {
				var _g1 = 0;
				while(_g1 < cats.length) {
					var parent = cats[_g1];
					++_g1;
					if(parent._id == c.parentId) {
						if(parent.children == null) parent.children = [];
						parent.children.push(c);
						break;
					}
				}
			}
		}
		return $final;
	}});
};
var templates_ViewArticle = function() { };
templates_ViewArticle.get_page = function() {
	return js.JQuery("#viewArticlePage");
};
templates_ViewArticle.init = function() {
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
Client.main();
})(typeof console != "undefined" ? console : {log:function(){}});

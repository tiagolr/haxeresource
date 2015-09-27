(function (console) { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var CRouter = function() { };
CRouter.__name__ = true;
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
	Router.route("/view/:_id",function() {
		var id = this.params._id;
		templates_ViewArticle.show(id);
	},{ onStop : function() {
		templates_ViewArticle.get_page().hide();
	}});
};
var Client = function() { };
Client.__name__ = true;
Client.main = function() {
	Shared.init();
	window.tags = model_Tags.collection;
	window.articles = model_Articles.collection;
	window.groups = model_TagGroups.collection;
	Meteor.subscribe("tags");
	Meteor.subscribe("tag_groups");
	Meteor.subscribe("articles",{ sort : { created : -1}, limit : 5});
	templates_Navbar.init();
	templates_SideBar.init();
	templates_ListArticles.init();
	templates_NewArticle.init();
	templates_ViewArticle.init();
	CRouter.init();
	SimpleSchema.messages({ eitherArticleOrLink : "An article must link to an external resource, or have embed contents, or both."});
	marked.setOptions({ highlight : function(code) {
		return hljs.highlightAuto(code).value;
	}});
	AutoForm.debug();
};
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
Math.__name__ = true;
var Shared = function() { };
Shared.__name__ = true;
Shared.init = function() {
	new model_TagGroups();
	new model_Articles();
	new model_Tags();
	model_Tags.collection.allow({ insert : function(name) {
		return true;
	}});
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
var model_Articles = function() {
	Mongo.Collection.call(this,"articles");
	model_Articles.collection = this;
	model_Articles.schema = new SimpleSchema({ title : { type : String, max : 100}, description : { type : String, max : 512}, link : { type : String, max : 512, optional : true, regEx : SimpleSchema.RegEx.Url, autoform : { afFieldInput : { type : "url"}}, custom : function() {
		if(!this.field("link").isSet && !this.field("content").isSet) return "eitherArticleOrLink";
		return null;
	}}, content : { type : String, max : 30000, optional : true, custom : function() {
		if(!this.field("link").isSet && !this.field("content").isSet) return "eitherArticleOrLink";
		return null;
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
		return null;
	}}, user : { type : String, optional : true, autoValue : function() {
		return this.userId;
	}}, upvotes : { type : Number, defaultValue : 0}, created : { type : Date, optional : true, autoValue : function() {
		if(this.isInsert) return new Date(); else {
			this.unset();
			return null;
		}
	}}, modified : { type : Date, optional : true, autoValue : function() {
		return new Date();
	}}});
};
model_Articles.__name__ = true;
model_Articles.__super__ = Mongo.Collection;
model_Articles.prototype = $extend(Mongo.Collection.prototype,{
	__class__: model_Articles
});
var model_TagGroups = function() {
	Mongo.Collection.call(this,"tag_groups");
	model_TagGroups.collection = this;
	model_TagGroups.schema = new SimpleSchema({ name : { type : String, max : 40}});
};
model_TagGroups.__name__ = true;
model_TagGroups.create = function(tagGroup) {
	model_TagGroups.collection.insert(tagGroup);
	return tagGroup;
};
model_TagGroups.__super__ = Mongo.Collection;
model_TagGroups.prototype = $extend(Mongo.Collection.prototype,{
	__class__: model_TagGroups
});
var model_Tags = function() {
	Mongo.Collection.call(this,"tags");
	model_Tags.collection = this;
	model_Tags.regEx = new RegExp("^[a-zA-Z0-9._-]+$");
	model_Tags.schema = new SimpleSchema({ name : { type : String, unique : true, regEx : model_Tags.regEx, max : 40, autoValue : function() {
		if(this.field("name").isSet) return (js_Boot.__cast(this.field("name").value , String)).toLowerCase();
		return null;
	}}});
};
model_Tags.__name__ = true;
model_Tags.create = function(tag) {
	tag.name = tag.name.toLowerCase();
	return model_Tags.collection.insert(tag);
};
model_Tags.getOrCreate = function(name) {
	name = name.toLowerCase();
	var exists = model_Tags.collection.findOne({ name : name});
	if(exists == null) {
		var newTag = model_Tags.create({ name : name});
		exists = model_Tags.collection.findOne({ _id : newTag});
	}
	if(exists == null) return null; else return { _id : exists._id, name : exists.name};
};
model_Tags.__super__ = Mongo.Collection;
model_Tags.prototype = $extend(Mongo.Collection.prototype,{
	__class__: model_Tags
});
var templates_ListArticles = function() { };
templates_ListArticles.__name__ = true;
templates_ListArticles.get_page = function() {
	return js.JQuery("#listArticlesPage");
};
templates_ListArticles.init = function() {
	Template.listArticles.helpers({ articles : function() {
		return model_Articles.collection.find({ },{ sort : { created : -1}, limit : 5});
	}});
	Template.articleRow.helpers({ formatDate : function(date) {
		return vagueTime.get({ from : new Date(), to : date});
	}, formatLink : function(link) {
		if(!StringTools.startsWith(link,"http://")) link = "http://" + link;
		return link;
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
	}});
};
var templates_Navbar = function() { };
templates_Navbar.__name__ = true;
templates_Navbar.init = function() {
};
var templates_NewArticle = function() { };
templates_NewArticle.__name__ = true;
templates_NewArticle.get_page = function() {
	return js.JQuery("#newArticlePage");
};
templates_NewArticle.init = function() {
	Template.newArticle.events({ 'click #btnPreviewArticle' : function(evt) {
		var title = js.JQuery("#naf-articleTitle").val();
		var content = js.JQuery("#naf-articleContent").val();
		var link = js.JQuery("#naf-articleLink").val();
		var desc = js.JQuery("#naf-articleDescription").val();
		js.JQuery("#na-previewTitle").html(title);
		js.JQuery("#na-articleDescription").html(desc);
		js.JQuery("#na-previewLink").html("<a href=\"" + link + "\" target=\"_blank\">" + link + "</a>");
		js.JQuery("#na-previewContent").html(marked(content));
	}, 'beforeItemAdd input' : function(evt1) {
		if(!model_Tags.regEx.test(evt1.item)) evt1.cancel = true;
	}});
	Template.newArticle.helpers({ });
	Template.registerHelper("schema",function() {
		return model_Articles.schema;
	});
	AutoForm.addHooks("newArticleForm",{ onSubmit : function(insertDoc,_,_1) {
		var id = null;
		if(insertDoc != null) {
			id = model_Articles.collection.insert(insertDoc);
			Router.go("/view/" + id);
		}
		this.done(null,id);
		return false;
	}});
};
var templates_SideBar = function() { };
templates_SideBar.__name__ = true;
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
templates_ViewArticle.__name__ = true;
templates_ViewArticle.get_page = function() {
	return js.JQuery("#viewArticlePage");
};
templates_ViewArticle.init = function() {
	Template.viewArticle.helpers({ article : function() {
		return Session.get("currentArticle");
	}});
};
templates_ViewArticle.show = function(articleId) {
	Session.set("currentArticle",model_Articles.collection.findOne({ _id : articleId}));
	templates_ViewArticle.get_page().show();
};
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
CRouter.FADE_DURATION = 500;
js_Boot.__toStr = {}.toString;
model_Articles.NAME = "articles";
model_TagGroups.NAME = "tag_groups";
model_Tags.NAME = "tags";
Client.main();
})(typeof console != "undefined" ? console : {log:function(){}});

//# sourceMappingURL=main.js.map
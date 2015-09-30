(function (console) { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
Math.__name__ = true;
var Server = function() { };
Server.__name__ = true;
Server.main = function() {
	Shared.init();
	Meteor.publish("tag_groups",function() {
		return model_TagGroups.collection.find();
	});
	Meteor.publish("tags",function() {
		return model_Tags.collection.find();
	});
	Meteor.publish("articles",function(selector,options) {
		return model_Articles.collection.find(selector,options);
	});
	Meteor.publish("countArticles",function() {
		Counts.publish(this,"countArticles",model_Articles.collection.find());
	});
	Meteor.publish("countArticlesTag",function(tagName) {
		var tag = model_Tags.collection.findOne({ name : tagName});
		if(tag != null) Counts.publish(this,"countArticlesTag" + tagName,model_Articles.collection.find({ tags : { '$in' : [tagName]}}));
	});
	if(model_TagGroups.collection.find().count() == 0) model_TagGroups.create({ name : "Haxe", mainTag : "haxe", tags : ["~/haxe-.*/"]});
	if(model_Articles.collection.find().count() == 0) {
		console.log("Creating dummy articles");
		model_Articles.create({ title : "Test Article1", description : "This is the first article Description", link : "http://www.haxedomain.com", content : "This is the article content, nothing special of course", user : "", tags : ["haxe-fuck"]});
		model_Articles.create({ title : "Test Article2", description : "This is the second article Description", link : "http://www.haxedomain.com", content : "This is the article content, nothing special of course", user : "", tags : ["haxe-tits"]});
	}
};
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
		return this.userId;
	}}, upvotes : { type : Number, defaultValue : 0}, created : { type : Date, optional : true, autoValue : function() {
		if(this.isInsert) return new Date(); else {
			this.unset();
			return undefined;
		}
	}}, modified : { type : Date, optional : true, autoValue : function() {
		return new Date();
	}}});
};
model_Articles.__name__ = true;
model_Articles.create = function(article) {
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
	__class__: model_Articles
});
var model_TagGroups = function() {
	Mongo.Collection.call(this,"tag_groups");
	model_TagGroups.collection = this;
	model_TagGroups.schema = new SimpleSchema({ name : { type : String, unique : true}, mainTag : { type : String, max : 30}, tags : { optional : true, type : [String]}});
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
	model_Tags.schema = new SimpleSchema({ name : { type : String, unique : true, regEx : model_Tags.regEx, max : 30, autoValue : function() {
		if(this.field("name").isSet) return (js_Boot.__cast(this.field("name").value , String)).toLowerCase();
		return undefined;
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
js_Boot.__toStr = {}.toString;
model_Articles.NAME = "articles";
model_TagGroups.NAME = "tag_groups";
model_Tags.NAME = "tags";
model_Tags.MAX_CHARS = 30;
Server.main();
})(typeof console != "undefined" ? console : {log:function(){}});

//# sourceMappingURL=main.js.map
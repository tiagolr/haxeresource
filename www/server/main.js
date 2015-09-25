(function (console) { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Server = function() { };
Server.main = function() {
	Shared.init();
	Meteor.publish("tag_groups",function() {
		return model_TagGroups.collection.find();
	});
	Meteor.publish("tags",function() {
		return model_Tags.collection.find();
	});
	Meteor.publish("articles",function() {
		return model_Articles.collection.find();
	});
	if(model_Tags.collection.find().count() == 0) {
		console.log("Creating dummy tags");
		model_Tags.create({ name : "haxe-fuck"});
		model_Tags.create({ name : "haxe-tits"});
		model_Tags.create({ name : "haxe-mom"});
	}
	if(model_TagGroups.collection.find().count() == 0) {
		console.log("Creating dummy tag groups");
		model_TagGroups.create({ name : "haxe", tags : ["haxe","~/haxe-.*/"]});
	}
	if(model_Articles.collection.find().count() == 0) {
		console.log("Creating dummy articles");
		model_Articles.create({ title : "Test Article1", description : "This is the first article Description", link : "http://www.haxedomain.com", content : "This is the article content, nothing special of course", user : "", tags : ["haxe-fuck"]});
		model_Articles.create({ title : "Test Article2", description : "This is the second article Description", link : "http://www.haxedomain.com", content : "This is the article content, nothing special of course", user : "", tags : ["haxe-tits"]});
	}
};
var Shared = function() { };
Shared.init = function() {
	new model_TagGroups();
	new model_Articles();
	new model_Tags();
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
model_Articles.NAME = "articles";
model_TagGroups.NAME = "tag_groups";
model_Tags.NAME = "tags";
Server.main();
})(typeof console != "undefined" ? console : {log:function(){}});

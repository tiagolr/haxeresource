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
	Meteor.publish("categories",function() {
		return model_Categories.collection.find();
	});
	Meteor.publish("articles",function() {
		return model_Articles.collection.find();
	});
	if(model_Categories.collection.find().count() == 0) {
		console.log("Creating dummy categories");
		var id1 = model_Categories.collection.insert(model_Categories.create("testCat1"));
		var id2 = model_Categories.collection.insert(model_Categories.create("testCat2",null,null,id1));
		var id3 = model_Categories.collection.insert(model_Categories.create("testCat3"));
	}
	if(model_Articles.collection.find().count() == 0) {
		console.log("Creating dummy articles");
		model_Articles.collection.insert(model_Articles.create("Test Article1","This is the first article Description","http://www.haxedomain.com","This is the article content, nothing special of course",model_Categories.collection.findOne({ name : "testCat2"})._id,"tempUserId"));
		model_Articles.collection.insert(model_Articles.create("Test Article2","This is the second article Description","http://www.haxedomain.com","This is the article content, nothing special of course",model_Categories.collection.findOne({ name : "testCat2"})._id,"tempUserId"));
	}
};
var Shared = function() { };
Shared.init = function() {
	new model_Categories();
	new model_Articles();
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
Server.main();
})(typeof console != "undefined" ? console : {log:function(){}});

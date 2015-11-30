(function (console) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Cache = function() { };
Cache.__name__ = true;
Cache.setArticleRss = function(params,output) {
	var hash = "articleRss" + SharedUtils.objectToHash(params);
	Reflect.setField(Cache.cache.rss.articles,hash,Cache.createEntry(output));
};
Cache.getArticleRss = function(params) {
	var hash = "articleRss" + SharedUtils.objectToHash(params);
	var res = Reflect.field(Cache.cache.rss.articles,hash);
	if(res != null && !Cache.hasExpired(res,Configs.server.cache.rss_articles_ttl)) return res.val;
	return null;
};
Cache.setSEOHtml = function(params,html) {
	var hash = "seoHtml" + SharedUtils.objectToHash(params);
	Reflect.setField(Cache.cache.seo.html,hash,Cache.createEntry(html));
};
Cache.getSEOHtml = function(params) {
	var hash = "seoHtml" + SharedUtils.objectToHash(params);
	var res = Reflect.field(Cache.cache.seo.html,hash);
	if(res != null && !Cache.hasExpired(res,Configs.server.cache.seo_html_ttl)) return res.val;
	return null;
};
Cache.createEntry = function(val) {
	return { val : val, ts : new Date().getTime()};
};
Cache.hasExpired = function(entry,ttl_mnts) {
	return new Date().getTime() - entry.ts > ttl_mnts * 60 * 1000;
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
HxOverrides.remove = function(a,obj) {
	var i = HxOverrides.indexOf(a,obj,0);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
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
var Permissions = function() { };
Permissions.__name__ = true;
Permissions.requireLogin = function() {
	if(!Permissions.isLogged()) {
		var err = Configs.shared.error.not_authorized;
		throw new Meteor.Error(err.code,err.reason,err.details);
	}
	return true;
};
Permissions.requirePermission = function(hasPermission) {
	if(!hasPermission) {
		var err = Configs.shared.error.no_permission;
		throw new Meteor.Error(err.code,err.reason,err.details);
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
Permissions.canTransferArticle = function() {
	return Permissions.isModerator();
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
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
var SEO = function() { };
SEO.__name__ = true;
SEO.init = function() {
	SSR.compileTemplate("layout",Assets.getText("seo/layout.html"));
	Template.layout.helpers({ getDocType : function() {
		return "<!DOCTYPE html>";
	}});
	SSR.compileTemplate("index",Assets.getText("seo/index.html"));
	SSR.compileTemplate("group",Assets.getText("seo/group.html"));
	SSR.compileTemplate("tag",Assets.getText("seo/tag.html"));
	SSR.compileTemplate("article",Assets.getText("seo/article.html"));
	Template.index.helpers({ formatUrl : function(str) {
		return SharedUtils.formatUrlName(str);
	}});
	Template.tag.helpers({ formatUrl : function(str1) {
		return SharedUtils.formatUrlName(str1);
	}});
	Template.group.helpers({ formatUrl : function(str2) {
		return SharedUtils.formatUrlName(str2);
	}});
	Template.article.helpers({ formatUrl : function(str3) {
		return SharedUtils.formatUrlName(str3);
	}});
	SEO.seoPicker = Picker.filter(function(req,res) {
		return (js_Boot.__cast(req.url , String)).indexOf("_escaped_fragment_") != -1;
	});
	SEO.defineRoutes();
};
SEO.defineRoutes = function() {
	SEO.seoPicker.route("/",function(params,req,res,next) {
		var html = Cache.getSEOHtml(["/"]);
		if(html != null) {
			res.end(html);
			return;
		}
		var articles = model_Articles.collection.find({ },{ fields : { _id : 1, title : 1}});
		var tags = model_Tags.collection.find({ },{ fields : { name : 1}});
		var groups = model_TagGroups.collection.find({ },{ fields : { name : 1}});
		html = SSR.render("layout",{ title : "Haxe Resource - Haxe documentation, articles and tutorials", description : "Haxe resource is a community site that collects learning material such as articles and tutorials related to the Haxe programming language.", template : "index", articles : articles, tags : tags, groups : groups});
		Cache.setSEOHtml(["/"],html);
		res.end(html);
	});
	SEO.seoPicker.route("/articles/:name",function(params1,req1,res1,next1) {
		var tagName = params1.name;
		var html1 = Cache.getSEOHtml(["/articles/tag/:name",tagName]);
		if(html1 != null) {
			res1.end(html1);
			return;
		}
		var articles1 = model_Articles.collection.find({ tags : { '$in' : [tagName]}},{ fields : { _id : 1, title : 1}});
		html1 = SSR.render("layout",{ title : "Haxe Resource - " + tagName + " tag", description : "Articles tagged as " + tagName + ".", template : "tag", articles : articles1});
		Cache.setSEOHtml(["/articles/tag/:name",tagName],html1);
		res1.end(html1);
	});
	SEO.seoPicker.route("/articles/group/:name",function(params2,req2,res2,next2) {
		var groupName = params2.name;
		var html2 = Cache.getSEOHtml(["/articles/group/:name",groupName]);
		if(html2 != null) {
			res2.end(html2);
			return;
		}
		var group = model_TagGroups.collection.findOne({ name : groupName});
		var tags1 = SharedUtils.resolveTags(group);
		tags1.push(group.mainTag);
		var articles2 = model_Articles.collection.find({ tags : { '$in' : tags1}},{ fields : { _id : 1, title : 1}});
		html2 = SSR.render("layout",{ title : "Haxe Resource - " + groupName + " group", description : group.description, template : "group", tags : tags1, articles : articles2});
		Cache.setSEOHtml(["/articles/group/:name",groupName],html2);
		res2.end(html2);
	});
	SEO.seoPicker.route("/articles/view/:_id/:name",function(params3,req3,res3,next3) {
		var articleId = params3._id;
		var html3 = Cache.getSEOHtml(["/articles/view/:_id/:name",articleId]);
		if(html3 != null) {
			res3.end(html3);
			return;
		}
		var article = model_Articles.collection.findOne({ _id : articleId});
		if(article.content != null) article.content = (Meteor.npmRequire("marked"))(article.content);
		html3 = SSR.render("layout",{ title : "Haxe Resource - " + article.title, description : article.description, template : "article", article : article});
		Cache.setSEOHtml(["/articles/view/:_id/:name",articleId],html3);
		res3.end(html3);
	});
};
var Server = function() { };
Server.__name__ = true;
Server.main = function() {
	Shared.init();
	Server.setupPublishes();
	Server.setupPermissions();
	Server.setupHooks();
	Server.setupMethods();
	Server.setupMaintenanceMethods();
	Server.setupAccounts();
	Server.setupEmail();
	Server.setupRss();
	SEO.init();
	Server.createAdmin();
	Server.createTagGroups();
	Server.createIndexes();
};
Server.setupPublishes = function() {
	Meteor.publish("tag_groups",function() {
		return model_TagGroups.collection.find({ },{ sort : { weight : 1}});
	});
	Meteor.publish("tags",function() {
		return model_Tags.collection.find();
	});
	Meteor.publish("articles",function(selector,options) {
		if(selector == null) selector = { };
		if(options == null) options = { };
		return model_Articles.collection.find(selector,options);
	});
	Meteor.publish("countArticles",function(id,selector1) {
		if(selector1 == null) selector1 = { };
		Counts.publish(this,"countArticles" + id,model_Articles.collection.find(selector1));
	});
	Meteor.publish("searchArticles",function(query,options1) {
		if(query == null || query == "") return model_Articles.collection.find({ });
		if(options1 == null) options1 = { };
		options1.fields = { score : { '$meta' : "textScore"}};
		if(options1.sort == null || options1.sort.score != null) options1.sort = { score : { '$meta' : "textScore"}};
		return model_Articles.collection.find({ '$text' : { '$search' : query}},options1);
	});
	Meteor.publish("reports",function() {
		if(Permissions.isModerator()) return model_Reports.collection.find(); else return null;
	});
};
Server.setupPermissions = function() {
	model_TagGroups.collection.allow({ insert : function(_,_1) {
		Permissions.requireLogin();
		return Permissions.requirePermission(Permissions.canInsertTagGroups());
	}, update : function(_2,_3,_4,_5) {
		Permissions.requireLogin();
		return Permissions.requirePermission(Permissions.canUpdateTagGroups());
	}, remove : function(_6,_7) {
		Permissions.requireLogin();
		return Permissions.requirePermission(Permissions.canRemoveTagGroups());
	}});
	model_Articles.collection.allow({ insert : function(_8,_9) {
		Permissions.requireLogin();
		return Permissions.requirePermission(Permissions.canInsertArticles());
	}, update : function(_10,document,fields,modifier) {
		Permissions.requireLogin();
		return Permissions.requirePermission(Permissions.canUpdateArticles(document));
	}, remove : function(_11,document1) {
		Permissions.requireLogin();
		return Permissions.requirePermission(Permissions.canRemoveArticles(document1));
	}});
	model_Reports.collection.allow({ insert : function(_12,_13) {
		Permissions.requireLogin();
		return true;
	}, remove : function(_14,_15) {
		Permissions.requireLogin();
		return Permissions.requirePermission(Permissions.isModerator());
	}});
	Meteor.users.deny({ update : function(_16,_17,_18,_19) {
		return true;
	}});
	Meteor.users.allow({ update : function(_20,document2,fields1,modifier1) {
		Permissions.requireLogin();
		return Permissions.requirePermission(Permissions.canUpdateUsers(document2,fields1));
	}});
};
Server.setupHooks = function() {
	model_Articles.collection.after.insert(function(userId,doc) {
		if(doc.tags == null) doc.tags = [];
		var _g = 0;
		var _g1 = doc.tags;
		while(_g < _g1.length) {
			var tagname = _g1[_g];
			++_g;
			model_Tags.addArticle(tagname,doc._id);
		}
	});
	model_Articles.collection.after.update(function(userId1,doc1) {
		var prev = this.previous;
		if(doc1.tags == null) doc1.tags = [];
		if(prev.tags == null) prev.tags = [];
		var _g2 = 0;
		var _g11 = doc1.tags;
		while(_g2 < _g11.length) {
			var tagname1 = _g11[_g2];
			++_g2;
			if(HxOverrides.indexOf(prev.tags,tagname1,0) == -1) model_Tags.addArticle(tagname1,doc1._id);
		}
		var _g3 = 0;
		var _g12 = prev.tags;
		while(_g3 < _g12.length) {
			var tagname2 = _g12[_g3];
			++_g3;
			if(HxOverrides.indexOf(doc1.tags,tagname2,0) == -1) model_Tags.removeArticle(tagname2,doc1._id);
		}
	});
	model_Articles.collection.after.remove(function(userId2,doc2) {
		if(doc2.tags == null) doc2.tags = [];
		var tags = doc2.tags;
		var _g4 = 0;
		while(_g4 < tags.length) {
			var tagname3 = tags[_g4];
			++_g4;
			model_Tags.removeArticle(tagname3,doc2._id);
		}
	});
};
Server.setupMethods = function() {
	Meteor.methods({ toggleArticleVote : function(id) {
		Permissions.requireLogin();
		if(model_Articles.collection.findOne({ _id : id}) == null) {
			var err = Configs.shared.error.args_article_not_found;
			throw new Meteor.Error(err.code,err.reason,err.details);
		}
		var votes = Meteor.user().profile.votes;
		if(votes == null) votes = [];
		if(HxOverrides.indexOf(votes,id,0) == -1) {
			votes.push(id);
			model_Articles.collection.update({ _id : id},{ '$inc' : { votes : 1}},{ getAutoValues : false});
		} else {
			HxOverrides.remove(votes,id);
			model_Articles.collection.update({ _id : id},{ '$inc' : { votes : -1}},{ getAutoValues : false});
		}
		Meteor.users.update({ _id : Meteor.userId()},{ '$set' : { 'profile.votes' : votes}},{ getAutoValues : false});
	}, removeUser : function(id1) {
		Permissions.requireLogin();
		Permissions.requirePermission(Permissions.canRemoveUser(Meteor.users.findOne({ _id : id1})));
		var user = Meteor.users.findOne({ _id : id1});
		if(user == null) {
			var err1 = Configs.shared.error.args_user_not_found;
			throw new Meteor.Error(err1.code,err1.reason,err1.details);
		}
		var votes1 = user.profile.votes;
		if(votes1 != null && votes1.length > 0) {
			while( votes1.hasNext() ) {
				var articleId = votes1.next();
				model_Articles.collection.update({ _id : articleId},{ '$dec' : { votes : 1}},{ getAutoValues : false});
			}
		}
		model_Articles.collection.remove({ user : id1});
		Meteor.users.remove({ _id : id1});
	}, transferArticle : function(articleId1,username) {
		Permissions.requireLogin();
		Permissions.requirePermission(Permissions.canTransferArticle());
		var user1 = Meteor.users.findOne({ username : username});
		if(user1 == null) {
			var err2 = Configs.shared.error.args_user_not_found;
			throw new Meteor.Error(err2.code,err2.reason,err2.details);
		}
		var article = model_Articles.collection.findOne({ _id : articleId1});
		if(article == null) {
			var err3 = Configs.shared.error.args_article_not_found;
			throw new Meteor.Error(err3.code,err3.reason,err3.details);
		}
		model_Articles.collection.update({ _id : articleId1},{ '$set' : { user : user1._id, username : username}},{ getAutoValues : false});
	}});
};
Server.setupMaintenanceMethods = function() {
	Meteor.methods({ updateTagsArticles : function() {
		Permissions.requirePermission(Permissions.isAdmin());
		model_Tags.collection.remove({ });
		var articles = model_Articles.collection.find().fetch();
		var _g = 0;
		while(_g < articles.length) {
			var article = articles[_g];
			++_g;
			var _g1 = 0;
			var _g2 = article.tags;
			while(_g1 < _g2.length) {
				var tagname = _g2[_g1];
				++_g1;
				if(model_Tags.collection.findOne({ name : tagname}) == null) model_Tags.collection.insert({ name : tagname});
				model_Tags.addArticle(tagname,article._id);
			}
		}
	}, addProfiles : function() {
		Permissions.requirePermission(Permissions.isAdmin());
		Meteor.users.update({ profile : { '$exists' : false}},{ '$set' : { 'profile' : { }}},{ getAutoValues : false, removeEmptyStrings : false});
	}, setPermissions : function(username,permissions) {
		Permissions.requirePermission(Permissions.isAdmin());
		var user = Meteor.users.findOne({ username : username});
		if(user == null) {
			var err = Configs.shared.error.args_user_not_found;
			throw new Meteor.Error(err.code,err.reason,err.details);
		}
		if(permissions == null) {
			var err1 = Configs.shared.error.args_user_not_found;
			throw new Meteor.Error(err1.code,err1.reason,err1.details);
		}
		if(!((permissions instanceof Array) && permissions.__enum__ == null)) {
			var err2 = Configs.shared.error.args_bad_permissions;
			throw new Meteor.Error(err2.code,err2.reason,err2.details);
		}
		var _g3 = 0;
		while(_g3 < permissions.length) {
			var p = permissions[_g3];
			++_g3;
			if(Reflect.field(Permissions.roles,p) == null || p == Permissions.roles.ADMIN) {
				var err3 = Configs.shared.error.args_bad_permissions;
				throw new Meteor.Error(err3.code,err3.reason,err3.details);
			}
		}
		Permissions.requirePermission(!Roles.userIsInRole(user._id,[Permissions.roles.ADMIN]));
		Roles.setUserRoles(user._id,permissions);
	}});
};
Server.setupAccounts = function() {
	Accounts.onCreateUser(function(options,user) {
		if(options.profile != null) user.profile = options.profile;
		if(user.services != null) {
			if(user.services.github != null) {
				var gh = user.services.github;
				var username = gh.username;
				var i = 1;
				while(Meteor.users.findOne({ username : username}) != null) {
					username = gh.username + (" (" + i + ")");
					i++;
				}
				user.username = username;
			} else if(user.services.google != null) {
				var go = user.services.google;
				var username1 = go.name;
				var i1 = 1;
				while(Meteor.users.findOne({ username : username1}) != null) {
					username1 = go.name + (" (" + i1 + ")");
					i1++;
				}
				user.username = username1;
			} else if(user.services.twitter != null) {
				var tw = user.services.twitter;
				var username2 = tw.screenName;
				var i2 = 1;
				while(Meteor.users.findOne({ username : username2}) != null) {
					username2 = tw.screenName + (" (" + i2 + ")");
					i2++;
				}
				user.username = username2;
			}
		}
		return user;
	});
};
Server.setupEmail = function() {
	Accounts.emailTemplates.siteName = "Haxe Resource";
	Accounts.emailTemplates.from = "Haxe Resource <no-reply@haxeresource.com>";
};
Server.setupRss = function() {
	Picker.route("/rss/articles",function(params,req,res,next) {
		var queryGroup;
		if(params.query == null) queryGroup = null; else queryGroup = params.query.group;
		var queryTag;
		if(params.query == null) queryTag = null; else queryTag = params.query.tag;
		var cached = Cache.getArticleRss({ group : queryGroup, tag : queryTag});
		if(cached != null) {
			res.writeHead(200,{ 'Content-Type' : "application/atom+xml"});
			res.end(cached);
			return;
		}
		var titleSuffix = "All Articles";
		var tags = null;
		if(queryGroup != null) {
			var group = model_TagGroups.collection.findOne({ name : queryGroup});
			tags = [];
			if(group != null) {
				var resolved = SharedUtils.resolveTags(group);
				var _g = 0;
				while(_g < resolved.length) {
					var t = resolved[_g];
					++_g;
					tags.push(t);
				}
				tags.push(group.mainTag);
				titleSuffix = "" + queryGroup + " Group";
			}
		} else if(queryTag != null) {
			tags = [];
			if(model_Tags.collection.findOne({ name : queryTag}) != null) {
				tags.push(queryTag);
				titleSuffix = "" + queryTag + " Tag";
			}
		}
		var feed = new (Meteor.npmRequire("feed"))({ title : "HaxeResource " + titleSuffix, description : "Articles and tutorials from the haxe community", link : Configs.shared.host});
		var selector = { };
		selector.created = { '$gte' : (function($this) {
			var $r;
			var t1 = new Date().getTime() - 86400000 * 30;
			var d = new Date();
			d.setTime(t1);
			$r = d;
			return $r;
		}(this))};
		if(tags != null) selector.tags = { '$in' : tags};
		model_Articles.collection.find(selector,{ sort : { created : -1}}).forEach(function(doc) {
			feed.addItem({ title : doc.title, link : Configs.shared.host + "/articles/view/" + doc._id + "/" + SharedUtils.formatUrlName(doc.title), description : doc.description, author : [{ name : doc.username}], date : doc.created});
		});
		var output = feed.render("atom-1.0");
		Cache.setArticleRss({ group : queryGroup, tag : queryTag},output);
		res.writeHead(200,{ 'Content-Type' : "application/atom+xml"});
		res.end(output);
	});
};
Server.createAdmin = function() {
	if(Meteor.users.findOne({ roles : { '$in' : [Permissions.roles.ADMIN]}}) == null) {
		var pwd = haxe_crypto_Md5.encode(Std.string(Math.random()));
		console.log("creating admin with pw : " + pwd);
		var adminId = Accounts.createUser({ username : "hxresadmin", password : pwd, profile : { }});
		Meteor.users.update({ _id : adminId},{ '$set' : { profile : { }}});
		if(adminId != null) {
			Meteor.users.update(adminId,{ '$set' : { initPwd : pwd}});
			Roles.setUserRoles(adminId,[Permissions.roles.ADMIN]);
		} else console.log("Error occurred, failed to create admin user account");
	}
};
Server.createTagGroups = function() {
	model_TagGroups.collection.remove({ });
	model_TagGroups.collection.insert({ name : "Haxe", mainTag : "haxe", tags : ["~/^haxe-..*$/"], icon : "/img/haxe-logo-50x50.png", description : "Haxe syntax, macros, compilation and more.", weight : 0});
	model_TagGroups.collection.insert({ name : "Openfl", mainTag : "openfl", tags : ["~/^openfl-..*$/"], icon : "/img/openfl-logo-50x50.png", description : "Openfl and lime frameworks.", weight : 1});
	model_TagGroups.collection.insert({ name : "HaxeFlixel", mainTag : "flixel", tags : ["~/^flixel-..*$/","~/^haxeflixel-..*$/"], icon : "/img/haxeflixel-logo-50x50.png", description : "Haxe flixel and game development.", weight : 2});
	model_TagGroups.collection.insert({ name : "Other", mainTag : "other", tags : ["~/^other-..*$/"], icon : "/img/other-logo-50x50.png", description : "Other libraries and subjects.", weight : 3});
};
Server.createIndexes = function() {
	Meteor.startup(function() {
		model_Articles.collection._ensureIndex({ content : "text", title : "text", description : "text", tags : "text"},{ name : "article_search_index", background : true, weights : { title : 10, tags : 5, description : 3, content : 1}});
		model_Articles.collection._ensureIndex({ 'user' : 1});
		model_Articles.collection._ensureIndex({ 'username' : 1});
		model_Articles.collection._ensureIndex({ 'tags' : 1});
	});
};
var Shared = function() { };
Shared.__name__ = true;
Shared.init = function() {
	new model_TagGroups();
	new model_Articles();
	new model_Tags();
	new model_Reports();
	model_Articles.collection.attachSchema(model_Articles.schema);
	model_Tags.collection.attachSchema(model_Tags.schema);
	model_TagGroups.collection.attachSchema(model_TagGroups.schema);
	model_Reports.collection.attachSchema(model_Reports.schema);
};
var SharedUtils = function() { };
SharedUtils.__name__ = true;
SharedUtils.objectToHash = function(o) {
	var str = Std.string(o);
	return haxe_crypto_Md5.encode(str);
};
SharedUtils.resolveTags = function(g) {
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
};
SharedUtils.formatUrlName = function(name) {
	name = StringTools.trim(name);
	name = StringTools.replace(name," ","-");
	return name;
};
SharedUtils.profileStart = function(name) {
	var value = new Date().getTime();
	SharedUtils.profiler.set(name,value);
};
SharedUtils.profileEnd = function(name) {
	if(SharedUtils.profiler.exists(name)) {
		var elapsed = new Date().getTime() - SharedUtils.profiler.get(name);
		console.log("profiler: finished " + name + " in " + elapsed + " ms");
	}
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
var haxe_IMap = function() { };
haxe_IMap.__name__ = true;
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
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__name__ = true;
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	set: function(key,value) {
		if(__map_reserved[key] != null) this.setReserved(key,value); else this.h[key] = value;
	}
	,get: function(key) {
		if(__map_reserved[key] != null) return this.getReserved(key);
		return this.h[key];
	}
	,exists: function(key) {
		if(__map_reserved[key] != null) return this.existsReserved(key);
		return this.h.hasOwnProperty(key);
	}
	,setReserved: function(key,value) {
		if(this.rh == null) this.rh = { };
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		if(this.rh == null) return null; else return this.rh["$" + key];
	}
	,existsReserved: function(key) {
		if(this.rh == null) return false;
		return this.rh.hasOwnProperty("$" + key);
	}
	,__class__: haxe_ds_StringMap
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
	}, autoValue : function() {
		if(Meteor.isServer && this.field("content").isSet) return (Meteor.npmRequire("sanitizer")).sanitize(this.field("content").value);
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
model_Articles.create = function(article) {
	model_Articles.collection.insert(article);
	return article;
};
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
var model_Reports = function() {
	Mongo.Collection.call(this,"reports");
	model_Reports.collection = this;
	model_Reports.schema = new SimpleSchema({ type : { type : String, allowedValues : ["ARTICLE","COMMENT","USER"]}, resource : { type : String, max : 50}, reason : { type : String, max : 100}, details : { type : String, optional : true, max : 512}, user : { type : String, optional : true, autoValue : function() {
		if(this.isInsert) return Meteor.userId(); else {
			this.unset();
			return undefined;
		}
	}}, created : { type : Date, optional : true, autoValue : function() {
		if(this.isInsert) return new Date(); else {
			this.unset();
			return undefined;
		}
	}}});
};
model_Reports.__name__ = true;
model_Reports.__super__ = Mongo.Collection;
model_Reports.prototype = $extend(Mongo.Collection.prototype,{
	__class__: model_Reports
});
var model_TagGroups = function() {
	Mongo.Collection.call(this,"tag_groups");
	model_TagGroups.collection = this;
	model_TagGroups.schema = new SimpleSchema({ name : { type : String, unique : true}, mainTag : { type : String, max : 30}, weight : { type : Number, defaultValue : 10}, icon : { type : String}, tags : { optional : true, type : [String]}, description : { type : String}});
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
model_Tags.addArticle = function(tagname,articleId) {
	if(model_Tags.collection.findOne({ name : tagname}).articles == null) model_Tags.collection.update({ name : tagname},{ '$push' : { articles : articleId}});
	model_Tags.collection.update({ name : tagname},{ '$addToSet' : { articles : articleId}});
};
model_Tags.removeArticle = function(tagname,articleId) {
	model_Tags.collection.update({ name : tagname},{ '$pull' : { articles : articleId}});
	var tag = model_Tags.collection.findOne({ name : tagname});
	if(tag.articles == null || tag.articles.length <= 0) model_Tags.collection.remove({ name : tagname});
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
var __map_reserved = {}
var ArrayBuffer = (Function("return typeof ArrayBuffer != 'undefined' ? ArrayBuffer : null"))() || js_html_compat_ArrayBuffer;
if(ArrayBuffer.prototype.slice == null) ArrayBuffer.prototype.slice = js_html_compat_ArrayBuffer.sliceImpl;
var DataView = (Function("return typeof DataView != 'undefined' ? DataView : null"))() || js_html_compat_DataView;
var Uint8Array = (Function("return typeof Uint8Array != 'undefined' ? Uint8Array : null"))() || js_html_compat_Uint8Array._new;
Cache.cache = { rss : { articles : { }}, seo : { html : { }}};
Configs.shared = { host : "http://localhost:3000", error : { not_authorized : { code : 401, reason : "Not authorized", details : "User must be logged."}, no_permission : { code : 403, reason : "No permission", details : "User does not have the required permissions."}, args_article_not_found : { code : 412, reason : "Invalid argument : article", details : "Article not found."}, args_user_not_found : { code : 412, reason : "Invalid argument : user", details : "User not found."}, args_bad_permissions : { code : 412, reason : "Invalid argument : permissions", details : "Invalid permission types"}}};
Configs.server = { cache : { rss_articles_ttl : 10, seo_html_ttl : 180}};
Permissions.roles = { ADMIN : "ADMIN", MODERATOR : "MODERATOR"};
SharedUtils.profiler = new haxe_ds_StringMap();
haxe_io_FPHelper.i64tmp = (function($this) {
	var $r;
	var x = new haxe__$Int64__$_$_$Int64(0,0);
	$r = x;
	return $r;
}(this));
js_Boot.__toStr = {}.toString;
js_html_compat_Uint8Array.BYTES_PER_ELEMENT = 1;
model_Articles.NAME = "articles";
model_Reports.NAME = "reports";
model_TagGroups.NAME = "tag_groups";
model_Tags.NAME = "tags";
model_Tags.MAX_CHARS = 30;
Server.main();
})(typeof console != "undefined" ? console : {log:function(){}});

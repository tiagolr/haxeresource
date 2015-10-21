import meteor.packages.npm.Marked;
import meteor.Picker;
import model.Articles;
import model.TagGroups;
import model.Tags;

/**
 * SEO publishes the site contents using similar routes but for crawlers
 * 
 * @author TiagoLr
 */
class SEO{
	static var seoPicker:Picker;
	
	static public function init() {
		untyped SSR.compileTemplate('layout', Assets.getText('seo/layout.html'));
		untyped Template.layout.helpers({
			getDocType: function() {
				return "<!DOCTYPE html>";
			},
		});
		
		untyped SSR.compileTemplate('index', Assets.getText('seo/index.html'));
		untyped SSR.compileTemplate('group', Assets.getText('seo/group.html'));
		untyped SSR.compileTemplate('tag', Assets.getText('seo/tag.html'));
		untyped SSR.compileTemplate('article', Assets.getText('seo/article.html'));
		
		untyped Template.index.helpers( { formatUrl: function (str) { return Shared.utils.formatUrlName(str); }, } );
		untyped Template.tag.helpers( {formatUrl: function (str) {return Shared.utils.formatUrlName(str);},});
		untyped Template.group.helpers( {formatUrl: function (str) {return Shared.utils.formatUrlName(str);},});
		untyped Template.article.helpers( {formatUrl: function (str) {return Shared.utils.formatUrlName(str);},});
		
		seoPicker = Picker.filter(function(req, res) {
			return cast (req.url, String).indexOf('_escaped_fragment_') != -1;
		});
		
		defineRoutes();
	}
	
	static private function defineRoutes():Void {
		seoPicker.route_('/', function (params, req, res, next) {
			var html = Cache.getSEOHtml( ['/'] );
			if (html != null) {
				res.end(html);
				return;
			}
			var articles = Articles.collection.find( { }, { fields: { _id:1, title:1 }} );
			var tags = Tags.collection.find( { }, {fields: {name:1}});
			var groups = TagGroups.collection.find( { }, {fields: {name:1}});
			
			html = untyped SSR.render('layout', {
				title: 'Haxe Resource - Haxe documentation, articles and tutorials',
				description: 'Haxe resource is a community site that collects learning material such as articles and tutorials related to the Haxe programming language.',
				template: "index",
				articles: articles,
				tags: tags,
				groups: groups,
			});
			
			Cache.setSEOHtml( ['/'], html);
			res.end(html);
		});
		
		
		seoPicker.route_('/articles/:name', function (params:Dynamic, req, res, next) {
			var tagName = params.name;
			var html = Cache.getSEOHtml([ '/articles/tag/:name', tagName ]);
			if (html != null) {
				res.end(html);
				return;
			}
		var articles = Articles.collection.find( { tags: { '$in': [tagName] }}, { fields: { _id:1, title:1 }} );
			
			html = untyped SSR.render('layout', {
				title: 'Haxe Resource - $tagName tag',
				description: 'Articles tagged as $tagName.',
				template: "tag",
				articles: articles,
			});
			
			Cache.setSEOHtml([ '/articles/tag/:name', tagName ], html);
			res.end(html);
		});
		
		
		seoPicker.route_('/articles/group/:name', function (params, req, res, next) {
			var groupName = params.name;
			var html = Cache.getSEOHtml(['/articles/group/:name', groupName]);
			if (html != null) {
				res.end(html);
				return;
			}
			
			var group:TagGroup = cast TagGroups.collection.findOne( { name:groupName } );
			var tags = Shared.utils.resolveTags(group);
			tags.push(group.mainTag);
			var articles = Articles.collection.find( { tags: {'$in':  tags }} , { fields: { _id:1, title:1 }} );
			
			html = untyped SSR.render('layout', {
				title: 'Haxe Resource - $groupName group',
				description: group.description,
				template: "group",
				tags:tags,
				articles: articles,
			});
			
			Cache.setSEOHtml( ['/articles/group/:name', groupName], html);
			res.end(html);
		});
		
		
		seoPicker.route_('/articles/view/:_id/:name', function (params, req, res, next) {
			var articleId = params._id;
			var html = Cache.getSEOHtml(['/articles/view/:_id/:name', articleId]);
			if (html != null) {
				res.end(html);
				return;
			}

			var article = Articles.collection.findOne( { _id:articleId } );
			if (article.content != null) {
				article.content = untyped new Marked(article.content);
			}
			
			html = untyped SSR.render('layout', {
				title: 'Haxe Resource - ${article.title}',
				description: article.description,
				template: "article",
				article: article,
			});
			
			Cache.setSEOHtml( ['/articles/view/:_id/:name', articleId], html);
			res.end(html);
		});
	}
	
}
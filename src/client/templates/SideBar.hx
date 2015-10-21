package templates;
import js.html.GetNotificationOptions;
import js.JQuery;
import meteor.packages.FlowRouter;
import meteor.Session;
import meteor.Template;
import model.Articles;
import model.TagGroups;
import model.TagGroups.TagGroup;
import model.Tags;
import model.Tags.Tag;

/**
 * ...
 * @author TiagoLr
 */
class SideBar {

	public static var tagGroups(get, set):Array<TagGroup>;
	static function get_tagGroups() {return Session.get('sb_tag_groups');}
	static function set_tagGroups(val) {Session.set('sb_tag_groups', val);return val;}
	
	var ignoreDivClick:Bool = false; // flag to hack the event propagation of <a></a> inside a clickable <div></div>

	public function new() {}
	public function init() {
		Template.get('sidebar').helpers( {
			
			tagGroups:function() {
				var tags:Array<Tag> = cast Tags.collection.find().fetch();
				var groups:Array<TagGroup> = cast TagGroups.collection.find().fetch();
				
				// resolve each group tags from tag names and regular expressions
				for (g in groups) {
					var resolved = Shared.utils.resolveTags(g);
					var final = new Array<{name:String, formattedName:String}>();
					for (name in resolved) {
						final.push( { name:name, formattedName:formatTagName(name) } ); // format name
					}
					
					resolved.push(g.mainTag);
					g.resolvedTags = final; // store resolvedTags in local groups
				}
				
				// store the resolved groups in a static variable so they can be accessed elsewhere.
				tagGroups = groups;
				
				return groups;
			},
			
			countUngrouped: function() {
				var tagNames = [];
				for (g in tagGroups) {
					tagNames.push(g.mainTag);
					
					for (t in g.resolvedTags) {
						tagNames.push(t.name);
					}
				}
				
				return Client.utils.retrieveArticleCount( { tags: { '$nin':tagNames }} );
			}
		});
		
		Template.get('sidebar').events( {
			'click #sb-ungrouped':function (_) {
				FlowRouter.go('/articles/group/ungrouped');
			}
		});
		
		Template.get('tagGroup').helpers( {
			countArticlesTag: function (tag) {
				var t = Tags.collection.findOne( { name:tag } ); 
				return (t == null || t.articles == null) ?
					-1:
					t.articles.length;
			},
			
			countArticlesGroup: function (mainTag:String, tags:Array<{name:String}>) {
				tags = tags.concat([{ name:mainTag }]); 
				var articles = [];
				for (tag in tags) {
					var t:Tag = cast Tags.collection.findOne( { name:tag.name } );
					if (t != null && t.articles != null) {
						for (a in t.articles) {
							if (articles.indexOf(a) == -1) {
								articles.push(a);
							}
						}
					}
				}
				
				return articles.length;
			}
		});
		
		Template.get('tagGroup').events( {
			'click .group-toggler': function (evt) {
				if (ignoreDivClick) {
					ignoreDivClick = false;
					return;
				}
				
				var trigger = new JQuery(evt.target);
				var collapsables : JQuery = new JQuery('.sidebar-groups .collapse');
				var isCollapsed = trigger.hasClass('collapsed');
				
				for (el in collapsables) {
					if (el.attr('id') == trigger.data('trigger') && el.hasClass('collapsed')) {
						untyped el.collapse('show');
						untyped el.removeClass('collapsed');
					} else {
						untyped el.collapse('hide');
						untyped el.addClass('collapsed');
					}
				}
			},
			
			'click .nav-tag-group > div > a': function (evt) {
				ignoreDivClick = true;
			},
			
		});
	}
	
	static function formatTagName(tag:String):String {
		var split = tag.split('-');
		if (split.length > 1) {
			split.shift();
			tag = split.join('-');
		}
		
		return tag;
	}
	
}
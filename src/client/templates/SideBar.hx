package templates;
import js.JQuery;
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
class SideBar{
	var ignoreDivClick:Bool = false; // flag to hack the event propagation of <a></a> inside a clickable <div></div>

	public function new() {}
	public function init() {
		Template.get('sidebar').helpers( {
			
			tag_groups:function() {
				var tags:Array<Tag> = cast Tags.collection.find().fetch();
				var groups:Array<TagGroup> = cast TagGroups.collection.find().fetch();
				
				// resolve each group tags from tag names and regular expressions
				for (g in groups) {
					var resolved = Shared.utils.resolveTags(g);
					var final = new Array<{name:String, formattedName:String}>();
					for (name in resolved) {
						final.push( { name:name, formattedName:formatTagName(name) } ); // format name
						//Client.utils.subscribeCountArticles( Articles.queryFromTags([name]));
					}
					
					resolved.push(g.mainTag);
					//Client.utils.subscribeCountArticles( Articles.queryFromTags(resolved));
					untyped g.resolvedTags = final;
				}
				
				return groups;
			},
		});
		
		Template.get('tagGroup').helpers( {
			countArticlesTag: function (tag) {
				return Client.utils.retrieveArticleCount( Articles.queryFromTags([tag]) );
			},
			
			countArticlesGroup: function (mainTag:String, tags:Array<{name:String}>) {
				var final = [for (t in tags) t.name];
				final.push(mainTag);
				
				var f = Client.utils.retrieveArticleCount( Articles.queryFromTags(final) );
				
				trace("OK " + f);
				return f;
			}
		});
		
		Template.get('tagGroup').events( {
			'click .nav-tag-group > div': function (evt) {
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
			}
		});
	}
	
	static function formatTagName(tag:String):String {
		var split = tag.split('-');
		if (split.length > 1) {
			split.shift();
			tag = split.join('-');
		}
		if (tag.length < 2) 
			return tag; // bug prevention
		
		return tag.substr(0, 1).toUpperCase() + tag.substr(1); // first letter uppercase
	}
	
}
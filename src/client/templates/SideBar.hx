package templates;
import js.html.Element;
import js.html.Event;
import js.JQuery;
import js.Lib;
import meteor.Meteor;
import meteor.packages.PublishCounts;
import meteor.Template;
import model.TagGroups;
import model.TagGroups.TagGroup;
import model.Tags;
import model.Tags.Tag;

/**
 * ...
 * @author TiagoLr
 */
class SideBar{
	static var ignoreDivClick:Bool = false; // flag to hack the event propagation of <a></a> inside a clickable <div></div>

	static public function init() {
		Template.get('sidebar').helpers( {
			
			tag_groups:function() {
				var tags:Array<Tag> = cast Tags.collection.find().fetch();
				var groups:Array<TagGroup> = cast TagGroups.collection.find().fetch();
				
				// resolve each group tags from tag names and regular expressions
				for (g in groups) {
					var resolvedTags = [];
					for (t in g.tags) {
						var res = resolveTags(t, tags);
						for (r in res) {
							r.name = formatTagName(r.name); // format name
							if (resolvedTags.indexOf(r) == -1) {
								resolvedTags.push(r);
							}
							Meteor.subscribe('countArticlesTag', r.original);
						}
					}
					untyped g.tags = resolvedTags;
				}
				
				return groups;
			},
		});
		
		Template.get('tagGroup').helpers( {
			countArticlesTag: function (tag) {
				return PublishCounts.get('countArticlesTag$tag');
			},
			
			countArticlesGroup: function (name) {
				var g:TagGroup = TagGroups.collection.findOne( { name:name } );
				if (g == null) return null;
				
				var total = PublishCounts.get('countArticlesTag' + g.mainTag);
				for (t in g.tags) {
					total += PublishCounts.get('countArticlesTag' + t);
				}
				return total;
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
	
	// return existing tag names from name or regular expression
	static public function resolveTags(strOrRegex:String, tags:Array<Tag>) {
		var resolved = new Array<{name:String, original:String}>();
		
		if (StringTools.startsWith(strOrRegex, '~')) {
			var split = strOrRegex.split('/');
			var reg = new EReg(split[1], split[2]);
			
			for (t in tags) {
				if (reg.match(t.name)) { 
					resolved.push({name:t.name, original:t.name});
				}
			}
			
		} else { // if selector is not a regex, find an exact match
			for (t in tags) { 
				if (t.name == strOrRegex) {
					resolved = [{name:t.name, original:t.name}];
					break;
				}
			}
		}
		
		return resolved;
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
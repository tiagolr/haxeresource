/**
 * ...
 * @author TiagoLr
 */
class Configs {
	
	public static var shared = {
		#if debug
		host: 'http://localhost:3000',
		#else 
		host: 'http://haxeresource.meteor.com',
		#end
		
		error : {
			not_authorized : {
				code : 401,
				reason: 'Not authorized',
				details: 'User must be logged.'
			},
			no_permission : {
				code: 403,
				reason: 'No permission',
				details: 'User does not have the required permissions.'
			},
			args_article_not_found : {
				code: 412,
				reason: 'Invalid argument : article',
				details: 'Article not found.'
			},
			args_user_not_found : {
				code: 412,
				reason: 'Invalid argument : user',
				details: 'User not found.'
			},
			args_bad_permissions : {
				code: 412,
				reason: 'Invalid argument : permissions',
				details: 'Invalid permission types',
			},
		}
	}
	
	#if client
	public static var client = {
		#if debug
		page_size: 3,
		#else 
		page_size: 10,
		#end
		page_fadein_duration : 500,
		page_fadeout_duration : 0,
		min_iframe_height: 250,
		
		texts: {
			la_showing_all: 	'Showing <em>all</em> articles',
			la_showing_tag: 	function(tag:String) return 'Showing <em>$tag</em> tag',
			la_showing_group: 	function(group:String) return 'Showing <em>$group</em> group',
			la_showing_query:	function(query:String) return 'Showing results for <em>$query</em> query',
			la_showing_ungrouped: "Showing ungrouped articles",
			la_tt_report:		"Report spam or other issues with this article.",
			na_placeh_title:	"Title goes here",
			na_placeh_desc:		"Brief description about the subject",
			na_placeh_link:		"ex: http://www.site.com/article",
			na_placeh_content: 	"Text contents using github flavored markdown",
			na_placeh_tags:		"",
			na_label_title: 	"Title*",
			na_label_desc:		"Description*",
			na_label_link:		"Link ",
			na_label_content:	"Content ",
			na_label_tags:		"Tags ",
			na_tt_links:		"Url to the article web-page.\nRequired if not posting any content.",
			na_tt_contents:		"Articles can provide only external link or only markdown content or both.",
			na_tt_tags:			"Enter tags by pressing `comma` or `enter` keys.\nChars allowed : [a-zA-Z.0-9-_].\nTags are automatically converted to lowercase when storing.",
			na_a_featured:		"Select from existing grouped tags.",
			na_fmodal_title:	"Select Featured Tags",
			na_fmodal_desc:		"Select one or more existing tags to make your article visible.",
			
			prompt_ra_msg:		"The article will be permanently deleted, are you sure?",
			prompt_ra_confirm:	"Yes",
			prompt_ra_cancel:	"No",
		}
	}
	#end
	
	#if server
	public static var server = {
		cache: {
			rss_articles_ttl: 10, // time to live in minutes for articles rss feeds
			seo_html_ttl: 180 // time to live in minutes for crawlers html
		}
	}
	#end
}
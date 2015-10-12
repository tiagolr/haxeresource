/**
 * ...
 * @author TiagoLr
 */
class Configs {
	
	public static var shared = {
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
				reason: 'Bad arguments',
				details: 'Article not found.'
			},
			args_user_not_found : {
				code: 412,
				reason: 'Bad arguments',
				details: 'User not found.'
			},
			args_bad_permissions : {
				code: 412,
				reason: 'Bad arguments',
				details: 'Invalid permission types',
			},
		}
	}
	
	#if client
	public static var client = {
		page_size: 5,
		page_fadein_duration : 500,
		page_fadeout_duration : 0,
		
		texts: {
			la_showing_all: 	'Showing <em>all</em> articles',
			la_showing_tag: 	function(tag:String) return 'Showing <em>$tag</em> tag',
			la_showing_group: 	function(group:String) return 'Showing <em>$group</em> group',
			na_placeh_title:	"Title goes here",
			na_placeh_desc:		"Brief description about the subject",
			na_placeh_link:		"Url to the original article, ex: http://www.site.com/article",
			na_placeh_content: 	"Text contents using github flavored markdown",
			na_placeh_tags:		"",
			na_label_title: 	"Title*",
			na_label_desc:		"Description*",
			na_label_link:		"Link ",
			na_label_content:	"Contents ",
			na_label_tags:		"Tags ",
			na_tt_links:		"An url for the original post (if any), required if not posting the contents directly here.",
			na_tt_contents:		"The article contents are written using markdown notation, articles may contain only links to external posts like blogs or other webpages, in that case contents are not required.",
			na_tt_tags:			"Tags may be inserted by pressing `comma` or `enter` keys. Depending on the tags choosen, the article may be added to different groups, for eg. using `haxe-macros` the article will be added to `Haxe` group inside `macros` subgroup",
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
	}
	#end
}
/**
 * ...
 * @author TiagoLr
 */
class Configs {
	
	public static var shared = 
	{
		error : {
			NOT_AUTHORIZED : 
			{
				code : 401,
				reason: 'Not authorized',
				details: 'User Must be logged in.'
			},
			NO_PERMISSION : 
			{
				code: 403,
				reason: 'No permission',
				details: 'User does not have the required permissions.'
			},
		}
	}
	
	#if client
	public static var client = 
	{
		PAGE_SIZE: 5,
		PAGE_FADEIN_DURATION : 500,
		PAGE_FADEOUT_DURATION : 0,
		MSG_SHOWING_ALL: 'Showing <em>all</em> articles',
		MSG_SHOWING_TAG: function(tag:String) return 'Showing <em>$tag</em> tag',
		MSG_SHOWING_GROUP: function(group:String) return 'Showing <em>$group</em> group',
	}
	#end
	
	#if server
	public static var server = 
	{
		error : 
		{
			ARG_ARTICLE_NOT_FOUND : 
			{
				code: 412,
				reason: 'Bad arguments',
				details: 'Article not found.'
			},
			ARG_USER_NOT_FOUND : 
			{
				code: 412,
				reason: 'Bad arguments',
				details: 'User not found.'
			},
		}
	}
	#end
}
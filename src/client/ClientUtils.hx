import meteor.Meteor;
import meteor.packages.PublishCounts;

using Lambda;
/**
 * ...
 * @author TiagoLr
 */
class ClientUtils{

	// cache article count subscriptions to avoid duplicates
	var articleCountSubs:Array<String> = new Array<String>();
	
	
	public function new() { }
	
	/**
	 * When retrieving article counts, the subscription is automatically made.
	 * Make sure retrieving article count is always made inside a reactive computation like template.autorun 
	 * so that the subscriptions are automatically invalidated.
	 */
	public function retrieveArticleCount(?selector: { } ) {
		if (selector == null) selector = { };
		var id = Shared.utils.objectToHash(selector);
		
		Meteor.subscribe('countArticles', id, selector);
		
		return PublishCounts.get('countArticles$id');
	}
	
	
	
}
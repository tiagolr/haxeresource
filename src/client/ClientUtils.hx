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

	
	public function subscribeCountArticles(?selector: { } ) {
		if (selector == null) selector = { };
		var id = Shared.utils.objectToHash(selector);
		
		if (articleCountSubs.has(id)) {
			return; // prevents repeated subscriptions
		} else {
			articleCountSubs.push(id);
		}
		
		Meteor.subscribe('countArticles', id, selector);
	}
	
	public function retrieveArticleCount(?selector: { } ) {
		if (selector == null) selector = { };
		var id = Shared.utils.objectToHash(selector);
		
		return PublishCounts.get('countArticles$id');
	}
	
}
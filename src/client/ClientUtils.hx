import haxe.Constraints.Function;
import meteor.Error;
import meteor.Meteor;
import meteor.packages.FlowRouter;
import meteor.packages.PublishCounts;
import meteor.packages.Toastr;

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
	
	public function parseMarkdown(raw:String):String {
		return untyped marked(raw);
	}
	
	public function handleServerError(error:Error) {
		if (Std.is(error.error, Int)) {
			Toastr.error(error.details, error.reason);
		}
	}
	
	public function alert(msg:String, ?label:String, ?callback:Function) {
		untyped bootbox.alert(msg, label, callback);
	}
	
	public function prompt(msg:String, ?cancel:String, ?confirm:String, ?callback:Function) {
		untyped bootbox.prompt(msg, cancel, confirm, callback);
	}
	
	public function confirm(msg:String, ?cancel:String, ?confirm:String, ?callback:Function) {
		untyped bootbox.dialog({
			message: msg,
			buttons: {
				cancel: {
					label: cancel,
					className: "btn-default",
				},
				confirm: {
					label: confirm,
					className: "btn-primary",
					callback: callback,
				},
			}
		});
	}
	
}
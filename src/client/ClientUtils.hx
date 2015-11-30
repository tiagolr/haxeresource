import haxe.Constraints.Function;
import js.Browser;
import js.JQuery;
import meteor.Error;
import meteor.Meteor;
import meteor.packages.FlowRouter;
import meteor.packages.PublishCounts;
import meteor.packages.Toastr;
import templates.ViewArticle;

using Lambda;
/**
 * ...
 * @author TiagoLr
 */
class ClientUtils{

	// cache article count subscriptions to avoid duplicates
	static var articleCountSubs:Array<String> = new Array<String>();
	
	/**
	 * When retrieving article counts, the subscription is automatically made.
	 * Make sure retrieving article count is always made inside a reactive computation like template.autorun 
	 * so that the subscriptions are automatically invalidated.
	 */
	static public function retrieveArticleCount(?selector: { } ) {
		if (selector == null) selector = { };
		var id = SharedUtils.objectToHash(selector);
		
		Meteor.subscribe('countArticles', id, selector);
		
		return PublishCounts.get('countArticles$id');
	}
	
	static public function parseMarkdown(raw:String):String {
		return raw == null ? null:
			untyped marked(raw);
	}
	
	static public function handleServerError(error:Error) {
		if (Std.is(error.error, Int)) {
			Toastr.error(error.details, error.reason);
		}
	}
	
	static public function notifyInfo(msg:String, ?title:String) {
		Toastr.info(msg, title);
	}
	
	static public function notifyError(msg:String, ?title:String) {
		Toastr.error(msg, title);
	}
	
	static public function notifySuccess(msg:String, ?title:String) {
		Toastr.success(msg, title);
	}
	
	static public function notifyWarning(msg:String, ?title:String) {
		Toastr.warning(msg, title);
	}
	
	
	static public function alert(msg:String, label:String, ?callback:Function) {
		untyped bootbox.alert(msg, label, callback);
	}
	
	static public function prompt(msg:String, ?callback:String->Void) {
		untyped bootbox.prompt(msg, callback);
	}
	
	static public function confirm(msg:String, ?cancel:String, ?confirm:String, ?callback:Function) {
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
	
	static public function capitalize(type:String) {
		if (type == null || type.length == 0) {
			return type;
		}
		
		var final = "";
		var split = type.split(' ');
		for (s in split) {
			if (final.length > 0) {
				final += ' ';
			}
			final += s.substr(0, 1).toUpperCase() + s.substr(1).toLowerCase();
		}
		return final;
	}
	
	static public function articleLinkToIframe(link:String) {
		if (link == null || link == "") 
			return "";
		
		// detect youtube links and embed them
		if (link.indexOf('www.youtube.com') != -1 || link.indexOf('www.youtu.be') != -1) {
			var ryoutube = ~/(?:watch\?v=)(.+)/gi;
			if (ryoutube.match(link)) {
				try {
					var res = ryoutube.matched(1);
					
					// if the query string has more arguments after movie id, format the query string
					var idx = res.indexOf('&'); 
					if (idx >= 0) {
						res = res.substr(0, idx) + '?' + res.substr(idx); 
					}
					
					link = 'https://www.youtube.com/embed/' + res;
				} catch(e:Dynamic) {}
			}
		} 
		else 
		
		// detect try_haxe link and embed them
		if (link.indexOf('//try.haxe.org') != -1) {
			var rtryhaxe = ~/(try.haxe.org\/)#(.+)/gi;
			if (rtryhaxe.match(link)) {
				try {
					link = 'http://try.haxe.org/embed/' + rtryhaxe.matched(2);
				} catch(e:Dynamic) {}
			}
		}
		
		return '<iframe class="va-article-frame" src="$link" frameBorder="0" allowfullscreen></iframe>';
	}
}
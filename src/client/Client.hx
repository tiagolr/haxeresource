import haxe.DynamicAccess;
import js.Browser;
import js.html.Event;
import meteor.Accounts;
import meteor.Error;
import meteor.Meteor;
import meteor.packages.AutoForm;
import meteor.packages.FlowRouter;
import meteor.packages.SimpleSchema;
import meteor.packages.Toastr;
import model.Articles;
import model.TagGroups;
import model.Tags;
import templates.ListArticles;
import templates.Navbar;
import templates.NewArticle;
import templates.SideBar;
import templates.ViewArticle;

/**
 * Client
 * @author TiagoLr
 */
#if debug
@:expose("Client")
#end
class Client {
	
	static public var utils:ClientUtils = new ClientUtils();
	static public var navbar:Navbar = new Navbar();
	static public var sidebar:SideBar = new SideBar();
	static public var listArticles:ListArticles = new ListArticles();
	static public var newArticle:NewArticle = new NewArticle();
	static public var viewArticle:ViewArticle = new ViewArticle();
	static public var router:Router = new Router();
	
	static var preloadReqs = {
		tagGroups:false,
	}
	
	public static function main() {
		Shared.init();
		
		untyped Browser.window[Tags.NAME] 		= untyped Tags.collection;
		untyped Browser.window[Articles.NAME] 	= untyped Articles.collection;
		untyped Browser.window[TagGroups.NAME] 	= untyped TagGroups.collection;

		Meteor.subscribe(Tags.NAME);
		Meteor.subscribe(TagGroups.NAME, { onReady : function() { preloadReqs.tagGroups = true; checkPreload(); }} );
		
		navbar.init();
		sidebar.init();
		listArticles.init();
		newArticle.init();
		viewArticle.init();
		
		FlowRouter.wait();
		router.init();
		
		// schema custom error messages
		SimpleSchema.messages_({eitherArticleOrLink: "An article must link to an external resource, or have embed contents, or both."});
		
		// initialize markdown
		untyped marked.setOptions({
			 highlight: function (code) {
				return hljs.highlightAuto(code).value;
			}
		});
		
		// Setup accounts login ui
		Accounts.ui.config( {
			passwordSignupFields: PasswordSignupFields.USERNAME_AND_EMAIL,
		});
		
		// Setup toastr notifications
		Toastr.options = {
			closeButton:true,
			progressBar:true,
			//timeOut: 5000,
			//extendedTimeOut:2500,
		}
		
		#if debug
		AutoForm.debug();
		#end
	}
	
	static function checkPreload() {
		var reqs : DynamicAccess<Bool> = preloadReqs;
		for (req in reqs.keys()) {
			if (reqs[req] != true) {
				return;
			}
		}
		
		// all requirements are ready
		FlowRouter.initialize();
	}

}

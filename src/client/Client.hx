import haxe.DynamicAccess;
import js.Browser;
import js.html.Event;
import js.JQuery;
import meteor.Accounts;
import meteor.Error;
import meteor.Meteor;
import meteor.packages.AutoForm;
import meteor.packages.FlowRouter;
import meteor.packages.SimpleSchema;
import meteor.packages.Toastr;
import meteor.Template;
import model.Articles;
import model.Reports;
import model.TagGroups;
import model.Tags;
import templates.ListArticles;
import templates.Navbar;
import templates.NewArticle;
import templates.ReportModal;
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
	static public var reportModal:ReportModal = new ReportModal();
	
	static var preloadReqs = {
		tagGroups:false,
	}
	
	public static function main() {
		Shared.init();
		
		// expose collections
		untyped Browser.window[Tags.NAME] 		= untyped Tags.collection;
		untyped Browser.window[Articles.NAME] 	= untyped Articles.collection;
		untyped Browser.window[TagGroups.NAME] 	= untyped TagGroups.collection;
		untyped Browser.window[Reports.NAME] 	= untyped Reports.collection;

		Meteor.subscribe(Tags.NAME);
		Meteor.subscribe(TagGroups.NAME, { onReady : function() { preloadReqs.tagGroups = true; checkPreload(); }} );
		
		navbar.init();
		sidebar.init();
		listArticles.init();
		newArticle.init();
		viewArticle.init();
		reportModal.init();
		
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
			//progressBar:true,
			//timeOut: 5000,
			//extendedTimeOut:2500,
		}
		
		// initialize bootstrap tooltips
		new JQuery('document').ready(function(_) {
			untyped new JQuery('[data-toggle="tooltip"]').tooltip();
		});
		
		//-----------------------------------------------
		// Global Helpers
		//-----------------------------------------------
		
		// returns a text from configs
		Template.registerHelper('getText', function( text:String) {
			if (text == null) {
				trace('warning: calling getText() with null arg0');
				return null;
			}
			
			var resolved = Reflect.field(Configs.client.texts, text);
			if (resolved == null) {
				trace( 'warning: text "$text" not found');
			}
			
			return resolved;
		});
		
		// returns a question icon that displays a tooltip when hovered
		Template.registerHelper('getIconTooltip', function( tooltip:String, placement:String ) {
			if (tooltip == null) {
				trace('warning: calling getIconTooltip() with null arg0 ');
				return null;
			}
			
			var tip = Reflect.field(Configs.client.texts, tooltip);
			if (tip == null) {
				trace('warning: tooltip "$tooltip" not found');
				return null;
			}
			
			if (placement != 'top' && placement != 'bottom' && placement != 'left' && placement != 'right') {
				placement = 'right';
			}
			
			return 
			'<div class="icon-tooltip" data-toggle="tooltip" data-placement="$placement" title="$tip">
				<span class="glyphicon glyphicon-question-sign"></span>
			</div>';
		});
		
		Template.registerHelper('formatUrlName', function(name:String) {
			return Shared.utils.formatUrlName(name);
		});
		
		//-----------------------------------------------
		
		
		
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

package templates;
import js.JQuery;
import meteor.Error;
import meteor.packages.AutoForm;
import meteor.packages.FlowRouter;
import meteor.packages.SimpleSchema;
import meteor.packages.SimpleSchema.SchemaDef;
import meteor.Template;
import model.Articles;
import model.Tags;

/**
 * ...
 * @author TiagoLr
 */
class NewArticle {

	public var page(get, null):JQuery;
	function get_page():JQuery {
		return new JQuery('#newArticlePage');
	}
	
	public function new() {}
	public function init() {
		Template.get('newArticle').events( {
			'click #btnPreviewArticle': function (evt) {
				var title = new JQuery("#naf-articleTitle").val();
				var content = new JQuery("#naf-articleContent").val();
				var link = new JQuery("#naf-articleLink").val();
				var desc = new JQuery("#naf-articleDescription").val();
				
				new JQuery('#na-previewTitle').html(title);
				new JQuery('#na-articleDescription').html(desc);
				new JQuery('#na-previewLink').html('<a href="$link" target="_blank">$link</a>');
				new JQuery('#na-previewContent').html(untyped marked(content));
			},
			
			// Only accept valid tags
			'beforeItemAdd input' : function (evt) {
				
				if (!Tags.regEx.test(evt.item)) {
					evt.cancel = true;
				}
			}
			
		});
		
		Template.get('newArticle').helpers( {
		});
		
		untyped Template.registerHelper('schema', function () {
			return Articles.schema;
		});
		
		AutoForm.addHooks('newArticleForm', {
			onSubmit: function (insertDoc, _, _) {
				var id = null;
				if (insertDoc != null) {
					id = Articles.collection.insert(insertDoc);
					FlowRouter.go('/view/$id');
				}
				
				HookCtx.done(id);
				return false;
			},
			
		});
	}
}
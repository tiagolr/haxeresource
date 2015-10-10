package templates;
import haxe.Timer;
import js.JQuery;
import js.Lib;
import meteor.Error;
import meteor.Meteor;
import meteor.packages.AutoForm;
import meteor.packages.FlowRouter;
import meteor.packages.SimpleSchema;
import meteor.packages.SimpleSchema.SchemaDef;
import meteor.Session;
import meteor.Template;
import model.Articles;
import model.Articles.Article;
import model.Tags;

/**
 * ...
 * @author TiagoLr
 */
class NewArticle {

	var page(get, null):JQuery;
	function get_page():JQuery {
		return new JQuery('#newArticlePage');
	}
	
	var editArticle(get, set):Article;
	function get_editArticle() {
		return Session.get('editArticle');
	}
	function set_editArticle(val:Article) {
		Session.set('editArticle', val);
		return val;
	}
	
	public function new() {}
	public function init() {
		Template.get('newArticle').helpers( {
			
			editArticle: function() {
				return Session.get('editArticle');
			},
			
			hasNoContents: function() {
				var val = AutoForm.getFieldValue('newArticleForm', 'content');
				trace("HERE " + val);
				return val == null || val == "";
			},
			
			titlePlaceholder: "Title goes here",
			descriptionPlaceholder: "Brief description about the subject",
			linkPlaceholder: "Url to the original article, ex: http://www.site.com/article",
			contentPlaceholder: "Text contents using github flavored markdown",
			tagsPlaceholder: "",
		});
		
		Template.get('newArticle').events( {
			'click #btnPreviewContents': function (evt) {
				var previewPanel = new JQuery('#na-previewPanel');
				var editPanel = new JQuery('#na-editPanel');
				
				// set both panels to the same height
				previewPanel.outerHeight(untyped editPanel.outerHeight());
				
				var title = new JQuery("#naf-articleTitle").val();
				var content = new JQuery("#naf-articleContent").val();
				var link = new JQuery("#naf-articleLink").val();
				var desc = new JQuery("#naf-articleDescription").val();
				
				new JQuery('#na-previewTitle').html(title);
				new JQuery('#na-articleDescription').html(desc);
				new JQuery('#na-previewLink').html('<a href="$link" target="_blank">$link</a>');
				new JQuery('#na-previewContent').html(Client.utils.parseMarkdown(content));
			},
			
			// Only accept valid tags
			'beforeItemAdd input' : function (evt) {
				if (!Tags.regEx.test(untyped evt.item)) {
					untyped evt.cancel = true;
				}
			}
			
		});
		
		AutoForm.addHooks('newArticleForm', {
			
			onSubmit: function (insertDoc, updateDoc, _) {
				Lib.nativeThis.event.preventDefault();
				var ctx:Dynamic = Lib.nativeThis;
				var id = null;
				if (Session.get('editArticle') == null) { 
					// insert new document
					id = Articles.collection.insert(insertDoc, function (error) {
						if (error != null) {
							Client.utils.handleServerError(cast error);
							ctx.done(error);
						} else {
							FlowRouter.go('/view/$id');
							ctx.done();
						}
					});
				} else {
					// update existing document
					id = editArticle._id;
					Articles.collection.update( { _id:id }, updateDoc, null, function(error) {
						if (error != null) {
							Client.utils.handleServerError(cast error);
							ctx.done(error);
						} else {
							FlowRouter.go('/view/$id');
							ctx.done(id);
						}
					});
				}
			},
			
		});
		
	}
	
	public function show(articleId:String = null) {
		
		if (articleId != null) {
			//AutoForm.resetForm('newArticleForm');
			Meteor.subscribe(Articles.NAME, { _id:articleId }, null, {
				
				onReady:function () {
					var article:Article = Articles.collection.findOne( { _id:articleId } );
					if (article != null) {
						editArticle = article;
						page.show(Configs.client.PAGE_FADEIN_DURATION);
						
						// FIX - force tags to show in input tags
						var tags = editArticle.tags;
						if (tags != null) {
							for (t in editArticle.tags) {
								untyped new JQuery("#naf-articleTags").tagsinput('add', t);
							}
						}
					} else {
						// TODO show flash error
						trace('NewArticle.show: Could not find article $articleId to edit');
						FlowRouter.go('/');
					}
				}, onError: function(e) {
					trace("Error: " + e);
					// TODO on error
				}
				
			});
		} else {
			page.show(Configs.client.PAGE_FADEIN_DURATION);
		}
	}
	
	public function hide() {
		if (Session.get('editArticle') != null) {
			Session.set('editArticle', null);
			//AutoForm.resetForm('newArticleForm');
		}
		page.hide(Configs.client.PAGE_FADEOUT_DURATION);
	}
}
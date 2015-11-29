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
import model.TagGroups.TagGroup;
import model.Tags;

/**
 * ...
 * @author TiagoLr
 */
class NewArticle {

	var page(get, null):JQuery;
	function get_page():JQuery {return new JQuery('#newArticlePage');}
	
	var editArticle(get, set):Article;
	function get_editArticle() {return Session.get('editArticle');}
	function set_editArticle(val) {Session.set('editArticle', val);return val;}
	
	public function new() {}
	public function init() {
		Template.get('newArticle').helpers( {
			
			editArticle: function() {
				return editArticle;
			},
			
			featuredTags: function() {
				var final = [];
				var groups = SideBar.tagGroups;
				
				if (groups == null) {
					return [];
				}
				
				for (g in groups) {
					final.push(g.mainTag);
					var tags:Array<Dynamic> = untyped g.resolvedTags;
					if (tags == null) {
						continue;
					}
					for (t in tags) {
						final.push(t.name);
					}
				}
				
				return final;
			},
			
			titlePlaceholder: Configs.client.texts.na_placeh_title,
			descriptionPlaceholder: Configs.client.texts.na_placeh_desc,
			linkPlaceholder: Configs.client.texts.na_placeh_link,
			contentPlaceholder: Configs.client.texts.na_placeh_content,
			tagsPlaceholder: Configs.client.texts.na_placeh_tags, 
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
				
				
				var res = "";
				if (link != null && link != "" && (content == null || content == "")) {
					res = ClientUtils.articleLinkToIframe(link);
				} else {
					res = ClientUtils.parseMarkdown(content);
				}
				new JQuery('#na-previewContent').html(res);
			},
			
			// Only accept valid tags
			'beforeItemAdd input' : function (evt) {
				if (!Tags.regEx.test(untyped evt.item)) {
					untyped evt.cancel = true;
				}
			},
			
			'change #na-featuredTagsList' : function (evt) {
				new JQuery('#na-featuredTagsAccept').toggleClass('disabled', new JQuery('#na-featuredTagsList').val() == null);
			},
			
			'click #na-featuredTagsAccept' : function (evt) {
				var selected:Array<String> = cast new JQuery('#na-featuredTagsList').val();
				if (selected != null) {
					for (tag in selected) {
						untyped new JQuery("#naf-articleTags").tagsinput('add', tag);
					}
				}
				
				untyped new JQuery('#na-modalFeaturedTags').modal('hide');
			},
			
		});
		
		AutoForm.addHooks('newArticleForm', {
			
			onSubmit: function (insertDoc, updateDoc, _) {
				Lib.nativeThis.event.preventDefault();
				var ctx:Dynamic = Lib.nativeThis;
				var id = null;
				if (Session.get('editArticle') == null) { 
					// insert new document
					id = Articles.collection.insert(insertDoc, function (error) {
						if (error == null) {
							var title = SharedUtils.formatUrlName(insertDoc.title);
							var path = FlowRouter.path('/articles/view/:id/:name', { id:id, name:title } );
							
							FlowRouter.go(path);
							ctx.done();
						} else {
							ClientUtils.handleServerError(cast error);
							ctx.done(error);
						}
					});
				} else {
					// update existing document
					id = editArticle._id;
					Articles.collection.update( { _id:id }, updateDoc, null, function(error, doc) {
						if (error == null) {
							
							var title = Articles.collection.findOne( { _id:id } ).title;
							title = SharedUtils.formatUrlName(title);
							var path = FlowRouter.path('/articles/view/:id/:name', { id:id, name:title } );
							
							FlowRouter.go(path);
							ctx.done();
						} else {
							ClientUtils.handleServerError(cast error);
							ctx.done(error);
						}
					});
				}
			},
			
		});
		
	}
	
	public function show(args: Dynamic ) {
		var articleId = args != null ? args.articleId : null;
		
		if (articleId != null) {
			// edits article
			Meteor.subscribe(Articles.NAME, { _id:articleId }, null, {
				
				onReady:function () {
					var article:Article = Articles.collection.findOne( { _id:articleId } );
					if (article != null) {
						editArticle = article;
						page.show(Configs.client.page_fadein_duration);
						
						// force tags to show in input tags
						var tags = editArticle.tags;
						if (tags != null) {
							for (t in editArticle.tags) {
								untyped new JQuery("#naf-articleTags").tagsinput('add', t);
							}
						}
					} else {
						ClientUtils.notifyError('Could not find article $articleId to edit');
						FlowRouter.go('/');
					}
				}, onError: function(e) {
					trace("Error: " + e);
				}
				
			});
		} else {
			// creates new article
			page.show(Configs.client.page_fadein_duration); 
		}
	}
	
	public function hide() {
		editArticle = null;
		
		// clear tags input
		untyped new JQuery("#naf-articleTags").tagsinput('removeAll');
		
		page.hide(Configs.client.page_fadeout_duration);
	}
}
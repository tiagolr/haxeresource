package templates;
import js.JQuery;
import meteor.packages.SimpleSchema;
import meteor.packages.SimpleSchema.SchemaDef;
import meteor.Template;

/**
 * ...
 * @author TiagoLr
 */
class NewArticle {

	static public var page(get, null):JQuery;
	static function get_page():JQuery {
		return new JQuery('#newArticlePage');
	}
	static public function init() {
		Template.get('newArticle').events( {
			'click #btnPreviewArticle': function (evt) {
				var title = new JQuery("#naf-articleTitle").val();
				var content = new JQuery("#naf-articleContent").val();
				
				new JQuery('#previewTitle').html(title);
				new JQuery('#previewContent').html(untyped marked(content));
			}
		});
		
		Template.get('newArticle').helpers( {
			
			schema: function () {
				return new SimpleSchema ({
					title: {
						type: String,
						max:100
					}, 
					description: {
						type:String,
						max:512
					},
					link: {
						type:String,
						max:512,
						//optional:true,
						autoform: {
							afFieldInput: {
								type: "url"
							}
						}
					},
					content: {
						type:String,
						max:30000,
						optional:true
					},
					tags: {
						type:[String],
						autoform: {
							type: 'tags',
							afFieldInput: {
								maxTags:10,
								maxChars:30,
							}
						}
					}
				});
			}
			
		});
		
		/*untyped Template.registerHelper('schema', function () {
			return schema;
		});*/
	}
}
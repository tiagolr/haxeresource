package templates;
import js.JQuery;
import meteor.Template;

/**
 * ...
 * @author TiagoLr
 */
class ViewArticle {

	static public var page(get, null):JQuery;
	static function get_page():JQuery {
		return new JQuery('#viewArticlePage');
	}
	static public function init() {
	}
	
}
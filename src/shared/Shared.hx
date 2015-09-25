import meteor.packages.Router;
import model.Articles;
import model.TagGroups;
import model.Tags;
/**
 * Shared
 * @author TiagoLr
 */
class Shared {

	public static function init() {
		new TagGroups();
		new Articles();
		new Tags();
	}
	
}
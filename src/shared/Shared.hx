import meteor.packages.Router;
import model.Articles;
import model.Categories;
/**
 * Shared
 * @author TiagoLr
 */
class Shared {

	public static function init() {
		new Categories();
		new Articles();
	}
	
}
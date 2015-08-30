package templates;
import meteor.Template;
import model.Categories;
import model.Categories.Category;

/**
 * ...
 * @author TiagoLr
 */
class SideBar{

	static public function init() {
		Template.get('sidebar').helpers( {
			categories:function() {
				var final = new Array<Category>();
				var cats = Categories.collection.find().fetch();
				for (c in cats) {
					if (c.parentId == null) {
						final.push(c);
					} else {
						for (parent in cats) {
							if (untyped parent._id == c.parentId) {
								if (parent.children == null) {
									parent.children = new Array<Category>();
								}
								parent.children.push(c);
								break;
							}
						}
					}
				}
				return final;
			}
		});
	}
	
}
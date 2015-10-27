package templates;
import js.JQuery;
import js.Lib;
import meteor.packages.AutoForm;
import meteor.Session;
import meteor.Template;
import model.Articles;
import model.Reports;
import model.Reports.ReportTypes;

/**
 * ...
 * @author TiagoLr
 */
class ReportModal{

	var isVisible(get, set):Bool;
	function set_isVisible(val) {Session.set('report_modal_visible',val);return val;}
	function get_isVisible() {return Session.get('report_modal_visible');}
	
	var type(get, set):String;
	function set_type(val) {Session.set('report_modal_type',val);return val;}
	function get_type() { return Session.get('report_modal_type'); }

	var resource(get, set):String;
	function set_resource(val) {Session.set('report_modal_resource',val);return val;}
	function get_resource() {return Session.get('report_modal_resource');}
	
	public function new() { }
	public function init() {
		Template.get('reportModal').helpers( {
			isVisible: function() {
				return isVisible;
			},
			type: function() {
				return type;
			},
			typeCapitalize: function() {
				return Client.utils.capitalize(type);
			},
			resource: function () {
				return resource;
			}
		});
		
		AutoForm.addHooks('reportForm', {
			onSubmit: function (insertDoc, _, _) {
				Lib.nativeThis.event.preventDefault();
				var ctx:Dynamic = Lib.nativeThis;
				
				switch (cast type) {
					case ReportTypes.ARTICLE:
						if (Articles.collection.findOne( { _id:resource } == null)) {
							hide();
							Client.utils.notifyError('Article to report not found');
							throw 'Article to report not found';
						}
					default : throw 'report type not supported';
				}
				
				Reports.collection.insert(insertDoc, function (error) {
					if (error != null) {
						Client.utils.handleServerError(cast error);
						ctx.done(error);
					} else {
						Client.utils.notifySuccess('Report sent');
						ctx.done();
					}
				});
				hide();
			}
		});
		
	}
	
	public function show(type:ReportTypes, resourceId:String) {
		trace('showing type $type id $resourceId yo');
		this.type = cast type;
		this.resource = resourceId;
		isVisible = true;
		untyped new JQuery('#reportModal').modal('show');
		untyped new JQuery('#reportModal').one('hidden.bs.modal', function (_) {
			isVisible = false;
		});
	}
	
	function hide() {
		untyped new JQuery('#reportModal').modal('hide');
	}
}
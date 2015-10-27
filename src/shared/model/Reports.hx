package model;
import js.Lib;
import meteor.Collection;
import meteor.Meteor;
import meteor.packages.SimpleSchema;

typedef Report = {
	?_id:String,
	type:String,
	resource:String,
	reason:String,
	user:String,
	?details:String,
}

@:enum abstract ReportTypes(String) {
	var ARTICLE = "ARTICLE";
	var COMMENT = "COMMENT";
	var USER = "USER";
}
/**
 * Categories
 * @author TiagoLr
 */
class Reports extends Collection {
	public static inline var NAME = 'reports';
	
	public static var schema(default, null):SimpleSchema;
	public static var collection(default, null):Reports;
	public function new() {
		super(NAME);
		collection = this;
		schema = new SimpleSchema({
			type: {
				type: String,
				allowedValues:[ReportTypes.ARTICLE, ReportTypes.COMMENT, ReportTypes.USER]
			},
			resource: { 
				type:String,
				max:50,
			},
			reason: {
				type:String,
				max:100,
			},
			details: {
				type:String,
				optional:true,
				max:512,
			},
			user: {
				type: String,
				optional:true,
				autoValue: function () {
					if (SchemaCtx.isInsert) {
						return Meteor.userId();
					} else {
						SchemaCtx.unset();
						return Lib.undefined;
					}
				}
			},
			created: {
				type:Date,
				optional:true,
				autoValue: function() {
					if (SchemaCtx.isInsert) {
						return Date.now();
					} else {
						SchemaCtx.unset();
						return Lib.undefined;
					}
				}
			},
		});
	}
	
}
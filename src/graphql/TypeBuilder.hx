package graphql;

import haxe.macro.Context;
import haxe.macro.Expr;
import graphql.GraphQLField;

using StringTools;

class TypeBuilder {
	macro static public function build():Array<Field> {
		var fields = Context.getBuildFields();
		var graphql_field_definitions:Array<ExprOf<GraphQLField>> = [];
		for (f in fields) {
			var new_field = buildFieldType(f);
			if (new_field != null) {
				graphql_field_definitions.push(new_field);
			}
		}

		var tmp_class = macro class {
			/**
				Auto-generated list of public fields on the class. Prototype for generating a full graphql definition
			**/
			public static var gql_fields:Array<graphql.GraphQLField> = $a{graphql_field_definitions};
		}

		for (field in tmp_class.fields) {
			fields.push(field);
		}

		return fields;
	}

	#if macro
	static function buildFieldType(f:Field):ExprOf<GraphQLField> {
		if (isVisible(f)) {
			var deprecationReason = getDeprecationReason(f);
			var comment = getComment(f);
			var type = getType(f);

			var field:ExprOf<GraphQLField> = macro {
				name: $v{f.name},
				type: $v{type},
				comment: $v{comment},
				deprecationReason: $deprecationReason
			}
			return field;
		}
		return null;
	}

	/**
		Determines if the field should be visible in the GraphQL Schema
	**/
	static function isVisible(field:Field) {
		for (meta in field.meta) {
			if (meta.name == ':GraphQLHide') {
				return false;
			}
		}
		return field.access.contains(APublic);
	}

	/**
		Returns a string expression for the deprecation reason, if provided using the @:deprecated metadata
	**/
	static function getDeprecationReason(field:Field):ExprOf<String> {
		var deprecationReason = macro null;
		for (meta in field.meta) {
			if (meta.name == ':deprecated') {
				deprecationReason = meta.params[0];
			}
		}
		return deprecationReason;
	}

	/**
		Get the commment string from a field
	**/
	static function getComment(field:Field) : Null<String> {
		return if (field.doc != null) {
			field.doc.trim();
		} else {
			null;
		};
	}

	/**
		Determine the type of a field in a macro
	**/
	static function getType(field:Field) {
		var type:String;
		switch (field.kind) {
			case(FVar(TPath({name: a}))):
				type = a;
			default:
				type = 'Dynamic';
		}
		return type;
	}
	#end
}

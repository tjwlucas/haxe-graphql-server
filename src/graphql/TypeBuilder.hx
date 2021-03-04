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
		for (meta in f.meta) {
			if (meta.name == ':GraphQLHide') {
				return null;
			}
		}

		if (f.access.contains(APublic)) {
			var deprecationReason:Expr = macro null;
			for (meta in f.meta) {
				if (meta.name == ':deprecated') {
					deprecationReason = meta.params[0];
				}
			}

			var type:String;
			switch (f.kind) {
				case(FVar(TPath({name: a}))):
					type = a;
				default:
					type = 'Dynamic';
			}

			var comment = if (f.doc != null) f.doc.trim() else null;

			var field:ExprOf<GraphQLField> = macro {
				name: $v{ f.name },
				type: $v{ type },
				comment: $v{ comment },
				deprecationReason: $deprecationReason
			}
			return field;
		}
		return null;
	}
	#end
}

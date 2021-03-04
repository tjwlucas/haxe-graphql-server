package graphql;

import haxe.macro.Context;
import haxe.macro.Expr;
import graphql.GraphQLField;

using StringTools;

class TypeBuilder {
	macro static public function build():Array<Field> {
		var fields = Context.getBuildFields();
		var graphql_field_definitions:Array<GraphQLField> = [];
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
			public static var gql_fields : Array<graphql.GraphQLField> = $v{ graphql_field_definitions };
		}

		for (mcf in tmp_class.fields) fields.push(mcf);

		return fields;
	}

	static function buildFieldType(f:Field):GraphQLField {
		for (meta in f.meta) {
			if (meta.name == ':GraphQLHide') {
				return null;
			}
		}

		if (f.access.contains(APublic)) {
			var deprecationReason:Null<String>;
			for (meta in f.meta) {
				if (meta.name == ':deprecated') {
					deprecationReason = switch (meta.params[0].expr) {
						case(EConst(CString(value))):
							value;
						default:
							throw 'Deprecation reason must be a string literal';
					}
				}
			}

			var type:String;
			switch (f.kind) {
				case(FVar(TPath({name: a}))):
					type = a;
				default:
					type = 'Dynamic';
			}
			var field:GraphQLField = {
				name: f.name,
				type: type,
				comment: if (f.doc != null) f.doc.trim() else null,
				deprecationReason: deprecationReason
			}
			return field;
		}
		return null;
	}
}

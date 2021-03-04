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

		var gql_fields = {
			name: 'gql_fields',
			doc: 'Auto-generated list of public fields on the class. Prototype for generating a full graphql definition',
			meta: [],
			access: [AStatic, APublic],
			kind: FVar(macro:Array<graphql.GraphQLField>, macro $v{graphql_field_definitions}),
			pos: Context.currentPos()
		};
		fields.push(gql_fields);

		return fields;
	}

	static function buildFieldType(f:Field):GraphQLField {
		for(meta in f.meta) {
			if(meta.name == ':GraphQLHide') {
				return null;
			}
		}

		if (f.access.contains(APublic)) {
			var deprecationReason : Null<String>;
			for(meta in f.meta) {
				if(meta.name == ':deprecated') {
					deprecationReason = 'deprecated';
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

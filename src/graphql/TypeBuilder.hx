package graphql;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import graphql.GraphQLField;
import haxe.macro.Type;

using StringTools;

class TypeBuilder {
	static var metadata = {
		build: 'graphql',
		built: 'graphql_built',
		hide_field: 'GraphQLHide',
		deprecated: 'deprecated'
	}

	macro static public function process():Void {
		Compiler.addGlobalMetadata('', '@:build(graphql.TypeBuilder.build())', true, true, false);
	}

	macro static public function build():Array<Field> {
		var fields = Context.getBuildFields();
		switch Context.getLocalType() {
			case null:
				null;
			case TInst(_.get() => c, _):
				if ((c.meta.has(':${metadata.build}') || c.meta.has(metadata.build)) && !c.meta.has(':${metadata.built}')) {
					buildClass(c, fields);
					c.meta.add(':${metadata.built}', [], Context.currentPos());
				}
			default:
				null;
		}
		return fields;
	}

	#if macro
	static function buildClass(cls:ClassType, fields:Array<Field>) {
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
	}

	static function buildFieldType(f:Field):ExprOf<GraphQLField> {
		if (isVisible(f)) {
			var deprecationReason = getDeprecationReason(f);
			var comment = getComment(f);
			var type = getType(f);

			var field:ExprOf<GraphQLField> = macro {
				name: $v{f.name},
				type: graphql.GraphQLTypes.$type,
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
			if ([':${metadata.hide_field}', metadata.hide_field].contains(meta.name)) {
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
			if ([':${metadata.deprecated}', metadata.deprecated].contains(meta.name)) {
				deprecationReason = meta.params[0];
			}
		}
		return deprecationReason;
	}

	/**
		Get the commment string from a field
	**/
	static function getComment(field:Field):Null<String> {
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

package graphql;

import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.TypeTools;

class FieldTypeBuilder {
	var field:Field;
	static var types_class = Context.getType('graphql.GraphQLTypes');
	static var static_field_name_list = TypeTools.getClass(types_class).statics.get().map((field) -> return field.name);
	public function new(field:Field) {
		this.field = field;
	}

	function getBaseType(type) {
		if(static_field_name_list.contains(type)) {
			return macro graphql.GraphQLTypes.$type;
		} else {
			try {
				var cls = Context.getType(type).getClass();
				if(cls.statics.get().filter((s) -> s.name == 'gql').length > 0) {
					return macro $i{cls.name}.gql.type;
				}
			} catch (e) {} // Pass through to the error below, no need to throw it especially
		}
		throw new Error('Type declaration ($type) not supported in the GraphQL type builder', field.pos); 
	}

	function arrayType(params: Array<TypeParam>) {
		var type : Expr;
		switch(params[0]) {
			case(TPType(TPath({name: a, params: p}))):
				var base_type = getBaseType(a);
				if(a == 'Array') {
					var arrayOf = arrayType(p);
					type = macro $base_type($arrayOf);
				} else {
					type = macro $base_type;
				}
			default:
				getBaseType('Unknown');
		}
		return type;
	}

	function functionReturnType(ret: ComplexType) {
		var type : Expr;
		switch(ret) {
			case(TPath({name: a, params: p})):
				var base_type = getBaseType(a);
				if(a == 'Array') {
					var arrayOf = arrayType(p);
					type = macro $base_type($arrayOf);
				} else {
					type = macro $base_type;
				}
			default:
				getBaseType('Unknown');
		}
		return type;
	}

	public function getType() {
		var type:Expr;

		switch (field.kind) {
			case(FVar(TPath({name: a, params: p}))):
				if(a == 'Array') {
					var base_type = getBaseType(a);
					var arrayOf = arrayType(p);
					type = macro $base_type($arrayOf);
				} else {
					var base_type = getBaseType(a);
					type = macro $base_type;
				}
			case(FFun({ret: return_type, args: args})):
				// TODO: add function arguments
				type = functionReturnType(return_type);
			default:
				trace(field.kind);
				getBaseType('Unknown');
				type = macro 'Unknown';
		}

		return type;
    }
}
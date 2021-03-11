package graphql;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.TypeTools;

class FieldTypeBuilder {
	var field:Field;
	static var types_class = Context.getType('graphql.GraphQLTypes');
    static var static_field_name_list = TypeTools.getClass(types_class).statics.get().map((field) -> return field.name);
    
    var type : Expr;

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
    
    function typeFromTPath(name: String, ?params: Array<TypeParam>) {
        var base_type = getBaseType(name);
        if(name == 'Array') {
            var arrayOf = arrayType(params);
            return macro $base_type($arrayOf);
        } else {
            return macro $base_type;
        }        
    }

	function arrayType(params: Array<TypeParam>) {
		var type : Expr;
		switch(params[0]) {
            case(TPType(TPath({name: a, params: p}))):
                type = typeFromTPath(a, p);
			default:
				getBaseType('Unknown');
		}
		return type;
	}

	function functionReturnType(ret: ComplexType) {
		var type : Expr;
		switch(ret) {
			case(TPath({name: a, params: p})):
                type = typeFromTPath(a, p);
			default:
				getBaseType('Unknown');
		}
		return type;
	}

	public function getType() {
        if(type == null) buildFieldType();
		return type;
    }

    public function buildFieldType() : Void {
		switch (field.kind) {
			case(FVar(TPath({name: a, params: p}))):
                type = typeFromTPath(a, p);
			case(FFun({ret: return_type, args: args})):
                // TODO: add function arguments
				type = functionReturnType(return_type);
			default:
				getBaseType('Unknown');
				type = macro 'Unknown';
		}
    }
}
#end
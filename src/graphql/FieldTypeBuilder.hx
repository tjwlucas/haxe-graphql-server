package graphql;
import graphql.TypeBuilder.FieldMetadata;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.TypeTools;
using StringTools;
using haxe.macro.TypeTools;

class FieldTypeBuilder {
	var field:Field;
	static var types_class = Context.getType('graphql.GraphQLTypes');
    static var static_field_name_list = TypeTools.getClass(types_class).statics.get().map((field) -> return field.name);
    
    public var type : Expr;
    public var args : Expr = macro [];
    public var arg_names: Array<String> = [];
    public var is_function = false;

	public function new(field:Field) {
		this.field = field;
	}

	function getBaseType(type) {
		if(static_field_name_list.contains(type)) {
			return macro graphql.GraphQLTypes.$type;
		} else {
			try {
				var cls = Context.getType(type).getClass();
				if(cls.superClass.t.toString() == 'graphql.GraphQLObject') {
					return macro () -> $i{cls.name}._gql.type;
				}
			} catch (e) {} // Pass through to the error below, no need to throw it especially
		}
		throw new Error('Type declaration ($type) not supported in the GraphQL type builder', field.pos); 
    }
    
    function typeFromTPath(name: String, ?params: Array<TypeParam>, nullable = false) {
        if(name == 'Array') {
            var arrayOf = arrayType(params);
			var base_type = getBaseType(name);
            return macro graphql.GraphQLTypes.NonNull($base_type($arrayOf));
        } else if (name == 'Null') {
			var base_type = nullableType(params);
			return macro $base_type;
		} else {
			var base_type = getBaseType(name);
			if(nullable) {
				return macro $base_type;
			} else {
				return macro graphql.GraphQLTypes.NonNull($base_type);
			}
        }        
	}
	
	function nullableType(params: Array<TypeParam>) {
		var type : Expr;
		switch(params[0]) {
            case(TPType(TPath({name: a, params: p}))):
                type = typeFromTPath(a, p, true);
			default:
				getBaseType('Unknown');
		}
		return type;
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
                is_function = true;
                // TODO: add function arguments
                var arg_list : Array<Expr> = [];
                for(arg in args) {
                    switch(arg.type) {
                        case(TPath({name: a, params: p})):
                            arg_names.push(arg.name);
                            arg_list.push( macro php.Lib.associativeArrayOfObject({
                                type: ${ typeFromTPath(a, p) },
                                name: $v{ arg.name },
                                description: null,
                                deprecationReason: null,
                                args: null
                            }));
                        default:
                            getBaseType('Unknown');
                    }
                }
                this.args = macro $a{ arg_list };
				type = functionReturnType(return_type);
			default:
				getBaseType('Unknown');
				type = macro 'Unknown';
		}
    }

	/**
		Get the commment string from the field
	**/
	public function getComment():Null<String> {
		return if (this.field.doc != null) {
			this.field.doc.trim();
		} else {
			null;
		};
    }
    
    /**
		Returns a string expression for the deprecation reason, if provided using the @:deprecated metadata
	**/
	public function getDeprecationReason():ExprOf<String> {
		var deprecationReason = macro null;
		if(hasMeta(Deprecated)) {
			deprecationReason = getMeta(Deprecated).params[0];
		}
		return deprecationReason;
    }
    
    function hasMeta(name : FieldMetadata) {
		var found = false;
		for (meta in field.meta) {
			if ([':$name', name].contains(meta.name)) {
				if(found == true) {
					throw new Error('Duplicate metadata found for $name on ${field.name}', meta.pos);
				}
				found = true;
			}
		}
		return found;
	}

	function getMeta(name : FieldMetadata) {
		return field.meta.filter((meta) -> {
			return [':$name', name].contains(meta.name);
		})[0];
	}

	/**
		Determines if the field should be visible in the GraphQL Schema
	**/
	public function isVisible() {
		/** Always exclude constructors **/
		if(field.name == 'new') {
			return false;
		}
		if(hasMeta(Hide)) {
			return false;
		}
		return field.access.contains(APublic);
	}
}
#end
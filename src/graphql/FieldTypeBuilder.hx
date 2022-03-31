package graphql;
import graphql.FieldMetadata;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.TypeTools;
using StringTools;
using haxe.macro.ExprTools;

class FieldTypeBuilder {
	var field:Field;
	static var types_class = Context.getType('graphql.GraphQLTypes');
    static var static_field_name_list = TypeTools.getClass(types_class).statics.get().map((field) -> return field.name);
    
    public var type : Expr;
    public var args : Expr = macro [];
    public var arg_names: Array<String> = [];
    public var is_function = false;

	public var query_type : GraphQLObjectType;

	public function new(field:Field, type: GraphQLObjectType = Query) {
		this.field = field;
		this.query_type = type;
	}

	function getBaseType(type) {
		if(static_field_name_list.contains(type)) {
			return macro graphql.GraphQLTypes.$type;
		} else {
			try {
				var cls = Context.getType(type).getClass();
				if(cls.interfaces.map(i -> i.t.toString()).contains('graphql.GraphQLObject')) {
					switch(this.query_type) {
						case (Query): return macro () -> $i{cls.name}._gql.type;
						case (Mutation): return macro () -> $i{cls.name}._gql.mutation_type;
					}
				}
			} catch (e) {} // Pass through to the error below, no need to throw it especially
		}
		throw new Error('Type declaration ($type) not supported in the GraphQL type builder', field.pos); 
    }
    
    function typeFromTPath(name: String, ?params: Array<TypeParam>, nullable = false) {
        if(name == 'Array') {
            var arrayOf = arrayType(params);
			var base_type = getBaseType(name);
			var array_expr = macro $base_type($arrayOf);
			if(nullable) {
				return macro $array_expr;
			} else {
				return macro graphql.GraphQLTypes.NonNull($array_expr);
			}
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

	public function getContextVariableName() {
		var expr : Expr;
		if (hasMeta(ContextVar)) {
			expr = getMeta(ContextVar).params[0];
		} else {
			var context_variable_name = Context.defined("gql_context_variable") ? Context.definedValue("gql_context_variable") : 'ctx';
			expr = macro $i{context_variable_name};
		}
		return expr.toString();
	}

    public function buildFieldType() : Void {
		switch (field.kind) {
			case(FVar(TPath({name: a, params: p}))):
                type = typeFromTPath(a, p, hasMeta('optional'));
            case(FFun({ret: return_type, args: args})):
                is_function = true;
                var arg_list : Array<ExprOf<Dynamic>> = [];
                for(arg in args) {
                    switch(arg.type) {
                        case(TPath({name: a, params: p})):
							arg_names.push(arg.name);
							var ctx_var_name = getContextVariableName();
							if(arg.name != ctx_var_name) {
								var defaultValue = arg.value != null ? arg.value : macro null;
								var arg_field : ExprOf<GraphQLArgField> = macro {
									var arg : graphql.GraphQLArgField = {
										type: ${ typeFromTPath(a, p, arg.opt ? true : arg.value != null) },
										name: $v{ arg.name },
										description: null
									};
									if($defaultValue != null) {
										arg.defaultValue = $defaultValue;
									}
									arg;
								};
								arg_list.push( macro php.Lib.associativeArrayOfObject($arg_field));
							}
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

	public function isStatic() : Bool {
		return field.access.contains(AStatic);
	}
    
    function hasMeta(name : FieldMetadata, allowMultiple = false) {
		var found = false;
		for (meta in field.meta) {
			if ([':$name', name].contains(meta.name)) {
				if(allowMultiple == false && found == true) {
					throw new Error('Duplicate metadata found for $name on ${field.name}', meta.pos);
				}
				found = true;
			}
		}
		return found;
	}

	/**
		Retrieves the *first* metadata item with the provided name (with or without preceding `:`)
	**/
	function getMeta(name : FieldMetadata) {
		return getMetas(name)[0];
	}

	/**
		Retrieves list of metadata with the given name (with or without preceding `:`)
	**/
	function getMetas(name : FieldMetadata) {
		return field.meta.filter((meta) -> {
			return [':$name', name].contains(meta.name);
		});
	}

	/**
		Determines if the field should be visible in the GraphQL Schema
	**/
	public function isVisible() {
		// Never show if flagged as hidden
		if(hasMeta(Hide)) {
			return false;
		}

		/** Always exclude 'special methods' **/
		if(['new', 'toString'].contains(field.name)) {
			return false;
		}

		switch(query_type) {
			// If not explicitly specified, for query or mutation, use public field access
			// Otherwise, base purely on metadata
			case Query:
				if(hasMeta(MutationField) && !hasMeta(QueryField)) {
					return false;
				} else if (hasMeta(QueryField)) {
					return true;
				} else {
					return field.access.contains(APublic);
				}
			// Show field on mutation iff has mutation metadata
			case Mutation:
				if(hasMeta(MutationField)) {
					return true;
				} else {
					return false;
				}
		}
	}

	/**
		Retrieves a list of all attached validate metadata entries and returns a list of validation expressions based on them
	**/
	public function getValidators(meta : FieldMetadata = Validate) : Array<Expr> {
		var checks : Array<Expr> = [];
		if (hasMeta(meta, true)) {
			var validations = getMetas(meta);
			for(v in validations) {
				var check = v.params[0];
				var message = v.params.length > 1 ? v.params[1] : macro "Validation failed";
				var extension = v.params.length > 2 ? v.params[2] : macro "validation";
				var clientSafe = v.params.length > 3 ? v.params[3] : macro null;
				var expr = macro {
					if(!$check) {
						throw new graphql.GraphQLError($message, $extension, $clientSafe);
					}
				}
				checks.push(expr);
			}
		}
		return checks;
	}

	/**
		Gets the validation context metadata, if present, and adds it to the validation expression list, before any of the validations are run.
	**/
	public function getValidationContext() : Array<Expr> {
		var expressions : Array<Expr> = [];
		if (hasMeta(ValidationContext, true)) {
			var validations = getMetas(ValidationContext);
			for(v in validations) {
				var expr = v.params[0];
				expressions.push(expr);
			}
		}
		return expressions;
	}
}
#end
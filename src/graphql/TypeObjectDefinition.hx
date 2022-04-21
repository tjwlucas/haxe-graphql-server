package graphql;

import graphql.externs.ObjectType;
import graphql.externs.NativeArray;

using graphql.Util;

/**
    Object holding GraphQL schema and resolver definition
**/
@:structInit
class TypeObjectDefinition {
    /**
        Name given to the type in GraphQL queries
    **/ 
    var type_name: String;

    /**
        Name given to the type in GraphQL queries
    **/
    var mutation_name : String;

    /**
        Array of fields, constructed from the class to be added to the GraphQL query type object
    **/
    var fields: Void->Array<graphql.GraphQLField>;

    /**
        GraphQL query object type definition, as passed to the `graphql-php` library
    **/
    public var type : ObjectType;
    
    /**
        Array of fields, constructed from the class to be added to the GraphQL mutation type object
    **/
    var mutation_fields: Void->Null<Array<graphql.GraphQLField>>;

    var has_mutation : Bool;


    /**
        GraphQL mutation object type definition, as passed to the `graphql-php` library
    **/
    public var mutation_type : Null<ObjectType>;

    /**
        Description of the object, generated from the 'doc' style comment at build time
    **/
    public var description: Null<String>;

    public function new(
        type_name:String, 
        mutation_name:String, 
        fields:Void->Array<graphql.GraphQLField>, 
        mutation_fields: Void->Array<graphql.GraphQLField>,
        description: String,
        has_mutation: Bool
        ) {
        this.type_name = type_name;
        this.fields = fields;
        this.mutation_fields = mutation_fields;
        this.mutation_name = mutation_name;
        this.description = description;
        this.has_mutation = has_mutation;

        type  = new ObjectType({
            name: this.type_name,
            description: this.description,
            fields: () -> {
                var named_fields : Map<String, NativeArray> = [];

                for(f in this.fields()) [
                    named_fields[f.name] = f.associativeArrayOfObject()
                ];
                return Util.associativeArrayOfHash(named_fields);
            }
        }.associativeArrayOfObject());

        if(this.has_mutation) {           
            mutation_type  = new ObjectType({
                name: this.mutation_name,
                description: this.description,
                fields: () -> {
                    var named_mutation_fields : Map<String, NativeArray> = [];

                    for(f in this.mutation_fields()) [
                        named_mutation_fields[f.name] = f.associativeArrayOfObject()
                    ];
                    return Util.associativeArrayOfHash(named_mutation_fields);
                }
            }.associativeArrayOfObject());
        }
    }
}
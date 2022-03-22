package graphql;

import php.NativeArray;
import graphql.externs.ObjectType;
using php.Lib;

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
    var fields: Array<graphql.GraphQLField>;

    /**
        GraphQL query object type definition, as passed to the `graphql-php` library
    **/
    public var type : ObjectType;
    
    /**
        Array of fields, constructed from the class to be added to the GraphQL mutation type object
    **/
    var mutation_fields: Null<Array<graphql.GraphQLField>>;


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
        fields:Array<graphql.GraphQLField>, 
        mutation_fields: Array<graphql.GraphQLField>,
        description: String
        ) {
        this.type_name = type_name;
        this.fields = fields;
        this.mutation_fields = mutation_fields;
        this.mutation_name = mutation_name;
        this.description = description;

        var named_fields : Map<String, NativeArray> = [];

        for(f in this.fields) [
            named_fields[f.name] = f.associativeArrayOfObject()
        ];

        type  = new ObjectType({
            name: this.type_name,
            description: this.description,
            fields: Lib.associativeArrayOfHash(named_fields)
        }.associativeArrayOfObject());

        if(mutation_fields.length > 0) {
            var named_mutation_fields : Map<String, NativeArray> = [];

            for(f in this.mutation_fields) [
                named_mutation_fields[f.name] = f.associativeArrayOfObject()
            ];        
            mutation_type  = new ObjectType({
                name: this.mutation_name,
                description: this.description,
                fields: Lib.associativeArrayOfHash(named_mutation_fields)
            }.associativeArrayOfObject());
        }
    }
}
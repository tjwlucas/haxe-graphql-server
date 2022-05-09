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

        type = buildTypeObject(this.type_name, this.description, this.fields);

        if(this.has_mutation) {           
            mutation_type  = buildTypeObject(this.mutation_name, this.description, this.mutation_fields);
        }
    }

    inline function buildTypeObject(name : String, description : String, fields : Void->Array<GraphQLField>) {
        return new ObjectType({
            name: name,
            description: description,
            fields: () -> {
                var namedFields : Map<String, NativeArray> = [];

                for(f in fields()) [
                    namedFields[f.name] = f.associativeArrayOfObject()
                ];
                return Util.associativeArrayOfHash(namedFields);
            }
        }.associativeArrayOfObject());
    }
}
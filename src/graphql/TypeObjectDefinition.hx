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
    var typeName: String;

    /**
        Name given to the type in GraphQL queries
    **/
    var mutationName : String;

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
    var mutationFields: Void->Null<Array<graphql.GraphQLField>>;

    var hasMutation : Bool;

    /**
        GraphQL mutation object type definition, as passed to the `graphql-php` library
    **/
    public var mutationType : Null<ObjectType>;

    /**
        Description of the object, generated from the 'doc' style comment at build time
    **/
    public var description: Null<String>;

    public function new(
        typeName:String, 
        mutationName:String, 
        fields:Void->Array<graphql.GraphQLField>, 
        mutationFields: Void->Array<graphql.GraphQLField>,
        description: String,
        hasMutation: Bool
    ) {
        this.typeName = typeName;
        this.fields = fields;
        this.mutationFields = mutationFields;
        this.mutationName = mutationName;
        this.description = description;
        this.hasMutation = hasMutation;

        type = buildTypeObject(this.typeName, this.description, this.fields);

        if(this.hasMutation) {           
            mutationType  = buildTypeObject(this.mutationName, this.description, this.mutationFields);
        }
    }

    inline function buildTypeObject(name : String, typeDescription : String, typeFields : Void->Array<GraphQLField>) {
        return new ObjectType({
            name: name,
            description: typeDescription,
            fields: () -> {
                var namedFields : Map<String, NativeArray> = [];

                for(f in typeFields()) [
                    namedFields[f.name] = f.associativeArrayOfObject()
                ];
                return Util.associativeArrayOfHash(namedFields);
            }
        }.associativeArrayOfObject());
    }
}
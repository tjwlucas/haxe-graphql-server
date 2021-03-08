package graphql;

@:structInit
class TypeObjectDefinition {    
    var type_name: String;
    var fields: Array<graphql.GraphQLField>;
}
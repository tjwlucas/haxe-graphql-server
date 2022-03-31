package graphql;

@:autoBuild(graphql.TypeBuilder.build())
interface GraphQLObject {
    /**
        Object holding generated GraphQL schema and resolver definition for this class
    **/
    public var gql(get, null) : graphql.TypeObjectDefinition;
    
    public function get_gql() : graphql.TypeObjectDefinition;
}

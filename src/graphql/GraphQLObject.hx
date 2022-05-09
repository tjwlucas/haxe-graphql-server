package graphql;

@:autoBuild(graphql.TypeBuilder.build())
interface GraphQLObject {
    /**
        Object holding generated GraphQL schema and resolver definition for this class
    **/
    var gql(get, null) : graphql.TypeObjectDefinition;
    
    private function get_gql() : graphql.TypeObjectDefinition;
}

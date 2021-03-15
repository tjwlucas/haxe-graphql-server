package graphql;

@:autoBuild(graphql.TypeBuilder.build())
@:keepSub
abstract class GraphQLObject {
    public var gql(get, null) : graphql.TypeObjectDefinition;
    
    public function get_gql() : graphql.TypeObjectDefinition {
        return null;
    };
}

package graphql.externs;

#if php @:native("GraphQL\\Type\\Definition\\ObjectType")
#elseif js @:jsRequire("graphql", "GraphQLObjectType")
#end
extern class ObjectType {
    public function new(definition:NativeArray);
}
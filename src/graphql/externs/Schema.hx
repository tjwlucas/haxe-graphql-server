package graphql.externs;

import graphql.externs.NativeArray;

#if php @:native('GraphQL\\Type\\Schema')
#elseif js @:jsRequire('graphql', 'GraphQLSchema')
#end
extern class Schema {
    public function new(definition:NativeArray);
}
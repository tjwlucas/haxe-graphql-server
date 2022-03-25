package graphql.externs;

import graphql.externs.NativeArray;

@:native('GraphQL\\Type\\Schema')
extern class Schema {
    public function new(definition:NativeArray);
}
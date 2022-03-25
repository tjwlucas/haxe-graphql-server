package graphql.externs;

import graphql.externs.NativeArray;

@:native('GraphQL\\Type\\Definition\\ObjectType')
extern class ObjectType {
    public function new(definition:NativeArray);
}
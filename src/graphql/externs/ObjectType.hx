package graphql.externs;

import php.NativeArray;

@:native('GraphQL\\Type\\Definition\\ObjectType')
extern class ObjectType {
    public function new(definition:NativeArray);
}
package graphql.externs;

import php.NativeArray;

@:native('GraphQL\\Type\\Schema')
extern class Schema {
    public function new(definition:NativeArray);
}
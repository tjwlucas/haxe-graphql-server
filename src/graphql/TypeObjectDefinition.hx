package graphql;

import php.NativeArray;
import graphql.externs.ObjectType;
using php.Lib;

@:structInit
class TypeObjectDefinition {    
    var type_name: String;
    var fields: Array<graphql.GraphQLField>;

    public var type : ObjectType;

    public function new(type_name:String, fields:Array<graphql.GraphQLField>) {
        this.type_name = type_name;
        this.fields = fields;

        var named_fields : Map<String, NativeArray> = [];

        for(f in this.fields) [
            named_fields[f.name] = f.associativeArrayOfObject()
        ];

        type  = new ObjectType({
            name: this.type_name,
            fields: Lib.associativeArrayOfHash(named_fields)
        }.associativeArrayOfObject());
    }
}
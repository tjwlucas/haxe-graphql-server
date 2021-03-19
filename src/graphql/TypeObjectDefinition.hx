package graphql;

import php.NativeArray;
import graphql.externs.ObjectType;
using php.Lib;

@:structInit
class TypeObjectDefinition {    
    var type_name: String;
    var mutation_name : String;
    var fields: Array<graphql.GraphQLField>;

    public var type : ObjectType;
    
    var mutation_fields: Null<Array<graphql.GraphQLField>>;
    public var mutation_type : Null<ObjectType>;

    public function new(type_name:String, mutation_name:String, fields:Array<graphql.GraphQLField>, mutation_fields: Array<graphql.GraphQLField>) {
        this.type_name = type_name;
        this.fields = fields;
        this.mutation_fields = mutation_fields;
        this.mutation_name = mutation_name;

        var named_fields : Map<String, NativeArray> = [];

        for(f in this.fields) [
            named_fields[f.name] = f.associativeArrayOfObject()
        ];

        type  = new ObjectType({
            name: this.type_name,
            fields: Lib.associativeArrayOfHash(named_fields)
        }.associativeArrayOfObject());

        if(mutation_fields.length > 0) {
            var named_mutation_fields : Map<String, NativeArray> = [];

            for(f in this.mutation_fields) [
                named_mutation_fields[f.name] = f.associativeArrayOfObject()
            ];        
            mutation_type  = new ObjectType({
                name: this.mutation_name,
                fields: Lib.associativeArrayOfHash(named_mutation_fields)
            }.associativeArrayOfObject());
        }
    }
}
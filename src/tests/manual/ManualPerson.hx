package tests.manual;

import graphql.GraphQLObject;

@:typeName("Person")
class ManualPerson implements GraphQLObject {
    var _name : String;
    public function new (name:String) {
        _name = name;
    }

    @:validate(name != obj._name, 'Both names are the same ($name), and that is arbitrarily disallowed')
    public function greet(name : String = "Sir") : String {
        return 'Hello, $name, my name is $_name';
    }
}

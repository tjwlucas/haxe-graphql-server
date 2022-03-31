package tests.cases;

import graphql.GraphQLError;
import graphql.GraphQLServer;
import graphql.GraphQLObject;
import utest.Assert;
import graphql.externs.NativeArray;


using graphql.Util;
using StringTools;

class MutationTest extends utest.Test {
    var server : GraphQLServer;
    function setup() {
        var base = new MutationTestObject();
        this.server = new GraphQLServer(base);
    }

    function specQueryTests() {
        var response = server.executeQuery('{queryOnlyField}');
        response.data['queryOnlyField'] == "Query Only";

        var response = server.executeQuery('{queryOnlyFieldExplicit}');
        response.data['queryOnlyFieldExplicit'] == "Query Only";

        var response = server.executeQuery('{bothField}');
        response.data['bothField'] == "Will appear on both";

        var response = server.executeQuery('{mutationOnlyField}');
        Assert.isNull(response.data);
        Assert.notNull(response.errors);

        var errors = response.errors;
        // errors.length == 1;
        var error = errors[0];
        var error_message : String = @:privateAccess error.getMessage();
        error_message.startsWith('Cannot query field "mutationOnlyField" on type "MutationTestObject"') == true;
    }

    function specMutationTests() {
        var response = server.executeQuery('mutation {mutationOnlyField}');
        response.data['mutationOnlyField'] == "Mutation Only";

        var response = server.executeQuery('mutation {bothField}');
        response.data['bothField'] == "Will appear on both";

        var response = server.executeQuery('mutation {queryOnlyFieldExplicit}');
        Assert.isNull(response.data);
        Assert.notNull(response.errors);

        var errors = response.errors;
        // errors.length == 1;
        var error = errors[0];
        var error_message : String = @:privateAccess error.getMessage();
        error_message.startsWith('Cannot query field "queryOnlyFieldExplicit" on type "MutationTestObjectMutation"') == true;

        var response = server.executeQuery('mutation {queryOnlyField}');
        Assert.isNull(response.data);
        Assert.notNull(response.errors);

        var errors = response.errors;
        // errors.length == 1;
        var error = errors[0];
        var error_message : String = @:privateAccess error.getMessage();
        error_message.startsWith('Cannot query field "queryOnlyField" on type "MutationTestObjectMutation"') == true;
    }

    function specDynamicMutationReturn() {
        // Query
        var response = server.executeQuery('{
            dynamicMutationReturnTest {
                __typename
                queryOnlyField
            }
        }');
        var data : NativeArray = response.data;
        var dynamicMutationReturnTest : NativeArray = data.dynamicMutationReturnTest;
        dynamicMutationReturnTest.queryOnlyField == "Query Only";
        dynamicMutationReturnTest.__typename == "DynamicMutationReturnTestObject";


        var response = server.executeQuery('{
            dynamicMutationReturnTest {
                mutationOnlyField
            }
        }');
        Assert.isNull(response.data);
        Assert.notNull(response.errors);

        var errors = response.errors;
        // errors.length == 1;
        var error = errors[0];
        var error_message : String = @:privateAccess error.getMessage();
        error_message.startsWith('Cannot query field "mutationOnlyField" on type "DynamicMutationReturnTestObject"') == true;

        // Mutation
        var response = server.executeQuery('mutation {
            dynamicMutationReturnTest {
                __typename
                mutationOnlyField
            }
        }');
        var data : NativeArray = response.data;
        var dynamicMutationReturnTest : NativeArray = data.dynamicMutationReturnTest;
        dynamicMutationReturnTest.mutationOnlyField == "Mutation Only";
        dynamicMutationReturnTest.__typename == "DynamicMutationReturnTestObjectMutation";


        var response = server.executeQuery('mutation {
            dynamicMutationReturnTest {
                queryOnlyField
            }
        }');
        Assert.isNull(response.data);
        Assert.notNull(response.errors);

        var errors = response.errors;
        // errors.length == 1;
        var error = errors[0];
        var error_message : String = @:privateAccess error.getMessage();
        error_message.startsWith('Cannot query field "queryOnlyField" on type "DynamicMutationReturnTestObjectMutation"') == true;
    }

    function specRenamedMutationReturn() {
        // Mutation
        var response = server.executeQuery('mutation {
            dynamicRenamedMutationReturnTest {
                __typename
            }
        }');
        var data : NativeArray = response.data;
        var dynamicRenamedMutationReturnTest : NativeArray = data.dynamicRenamedMutationReturnTest;
        dynamicRenamedMutationReturnTest.__typename == "CustomMutationReturn";


        // Query
        var response = server.executeQuery('{
            dynamicRenamedMutationReturnTest {
                __typename
            }
        }');
        var data : NativeArray = response.data;
        var dynamicRenamedMutationReturnTest : NativeArray = data.dynamicRenamedMutationReturnTest;
        dynamicRenamedMutationReturnTest.__typename == "RenamedDynamicMutationReturnTestObject";
    }

    function specRenamedMutationDescription() {
        // Mutation
        var response = server.executeQuery('{
            __type(name:"CustomMutationReturn") {
                description
            }
        }');
        var data : NativeArray = response.data;
        Assert.notNull(data.__type);
        if(data.__type != null) {
            var __type : NativeArray = data.__type;
            __type.description == 'This is a custom Mutation return object';
        }
    }
}


class MutationTestObject implements GraphQLObject {
    public function new() {}

    public var queryOnlyField : String = "Query Only";

    @:query public var queryOnlyFieldExplicit : String = "Query Only";

    @:mutation public var mutationOnlyField : String = "Mutation Only";

    @:query @:mutation public var bothField : String = "Will appear on both";
    @:query @:mutation public var dynamicMutationReturnTest : DynamicMutationReturnTestObject = new DynamicMutationReturnTestObject();
    
    @:query @:mutation public var dynamicRenamedMutationReturnTest : RenamedDynamicMutationReturnTestObject = new RenamedDynamicMutationReturnTestObject();

}

class DynamicMutationReturnTestObject implements GraphQLObject {
    public function new() {}
    public var queryOnlyField : String = "Query Only";
    @:mutation public var mutationOnlyField : String = "Mutation Only";
}

/**
    This is a custom Mutation return object
**/
@:mutationName('CustomMutationReturn')
class RenamedDynamicMutationReturnTestObject implements GraphQLObject {
    public function new() {}
    public var queryOnlyField : String = "Query Only";
    @:mutation public var mutationOnlyField : String = "Mutation Only";
}
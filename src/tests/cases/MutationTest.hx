package tests.cases;

import php.NativeAssocArray;
import graphql.GraphQLError;
import graphql.GraphQLServer;
import graphql.GraphQLObject;
import utest.Assert;

using php.Lib;
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

        var errors = response.errors.toHaxeArray();
        errors.length == 1;
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

        var errors = response.errors.toHaxeArray();
        errors.length == 1;
        var error = errors[0];
        var error_message : String = @:privateAccess error.getMessage();
        error_message.startsWith('Cannot query field "queryOnlyFieldExplicit" on type "MutationTestObjectMutation"') == true;

        var response = server.executeQuery('mutation {queryOnlyField}');
        Assert.isNull(response.data);
        Assert.notNull(response.errors);

        var errors = response.errors.toHaxeArray();
        errors.length == 1;
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
        var data : NativeAssocArray<NativeAssocArray<Dynamic>> = response.data;
        data['dynamicMutationReturnTest']['queryOnlyField'] == "Query Only";
        data['dynamicMutationReturnTest']['__typename'] == "DynamicMutationReturnTestObject";


        var response = server.executeQuery('{
            dynamicMutationReturnTest {
                mutationOnlyField
            }
        }');
        Assert.isNull(response.data);
        Assert.notNull(response.errors);

        var errors = response.errors.toHaxeArray();
        errors.length == 1;
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
        var data : NativeAssocArray<NativeAssocArray<Dynamic>> = response.data;
        data['dynamicMutationReturnTest']['mutationOnlyField'] == "Mutation Only";
        data['dynamicMutationReturnTest']['__typename'] == "DynamicMutationReturnTestObjectMutation";


        var response = server.executeQuery('mutation {
            dynamicMutationReturnTest {
                queryOnlyField
            }
        }');
        Assert.isNull(response.data);
        Assert.notNull(response.errors);

        var errors = response.errors.toHaxeArray();
        errors.length == 1;
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
        var data : NativeAssocArray<NativeAssocArray<Dynamic>> = response.data;
        data['dynamicRenamedMutationReturnTest']['__typename'] == "CustomMutationReturn";


        // Query
        var response = server.executeQuery('{
            dynamicRenamedMutationReturnTest {
                __typename
            }
        }');
        var data : NativeAssocArray<NativeAssocArray<Dynamic>> = response.data;
        data['dynamicRenamedMutationReturnTest']['__typename'] == "RenamedDynamicMutationReturnTestObject";
    }
}


class MutationTestObject extends GraphQLObject {
    public function new() {}

    public var queryOnlyField : String = "Query Only";

    @:query public var queryOnlyFieldExplicit : String = "Query Only";

    @:mutation public var mutationOnlyField : String = "Mutation Only";

    @:query @:mutation public var bothField : String = "Will appear on both";
    @:query @:mutation public var dynamicMutationReturnTest : DynamicMutationReturnTestObject = new DynamicMutationReturnTestObject();
    
    @:query @:mutation public var dynamicRenamedMutationReturnTest : RenamedDynamicMutationReturnTestObject = new RenamedDynamicMutationReturnTestObject();

}

class DynamicMutationReturnTestObject extends GraphQLObject {
    public function new() {}
    public var queryOnlyField : String = "Query Only";
    @:mutation public var mutationOnlyField : String = "Mutation Only";
}

@:mutationName('CustomMutationReturn')
class RenamedDynamicMutationReturnTestObject extends GraphQLObject {
    public function new() {}
    public var queryOnlyField : String = "Query Only";
    @:mutation public var mutationOnlyField : String = "Mutation Only";
}
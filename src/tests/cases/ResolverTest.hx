package tests.cases;

import graphql.GraphQLError;
import php.Exception;
import php.NativeArray;
import graphql.GraphQLServer;
import graphql.GraphQLObject;
import utest.Assert;

using php.Lib;

class ResolverTest extends utest.Test {
    var server : GraphQLServer;
    function setup() {
        var base = new ResolverTestObject();
        this.server = new GraphQLServer(base);
    }

    function specSimpleMethod() {
        var response = server.executeQuery('{simpleMethod}');
        response.data['simpleMethod'] == "This is a simple response";
    }

    function specAddMethod() {
        var response = server.executeQuery("query($x:Int!, $y:Int!){
            add(x:$x, y:$y)
        }", {
            x: 5,
            y: 12
        }.associativeArrayOfObject());
        Assert.equals(response.data['add'], 17);
    }

    function specProtectedAddMethod() {
        var response = server.executeQuery("query($x:Int!, $y:Int!){
            protectedAdd(x:$x, y:$y)
        }", {
            x: 5,
            y: 12
        }.associativeArrayOfObject());
        
        Assert.isNull(response.data);
        Assert.notNull(response.errors);
        var errors = response.errors.toHaxeArray();
        errors.length == 1;
        var error : GraphQLError = errors[0];
        @:privateAccess error.getMessage() == 'Validation failed';
        error.getCategory() == 'validation';
        error.isClientSafe() == true;
    }

    function specProtectedNullableAddMethod() {
        var response = server.executeQuery("query($x:Int!, $y:Int!){
            protectedNullableAdd(x:$x, y:$y)
        }", {
            x: 5,
            y: 12
        }.associativeArrayOfObject());
        
        Assert.notNull(response.data);
        response.data['protectedNullableAdd'] == null;

        Assert.notNull(response.errors);
        var errors = response.errors.toHaxeArray();
        errors.length == 1;
        var error : GraphQLError = errors[0];
        @:privateAccess error.getMessage() == 'Validation failed';
        error.getCategory() == 'validation';
        error.isClientSafe() == true;
    }

    function specListMethod() {
        // Using just the default values
        var response = server.executeQuery("{list}");
        
        Assert.notNull(response.data);
        Assert.equals(response.data['list'], [0,1,2,3,4,5,6,7,8,9,10].toPhpArray());

        // Using valid provided values
        var response = server.executeQuery("{list(min:3, max:8)}");
        
        Assert.notNull(response.data);
        Assert.equals(response.data['list'], [3,4,5,6,7,8].toPhpArray());

        // Using invalid provided values
        var response = server.executeQuery("{list(min:13, max:8)}");
        
        Assert.isNull(response.data);

        Assert.notNull(response.errors);
        var errors = response.errors.toHaxeArray();
        errors.length == 1;
        var error : GraphQLError = errors[0];
        @:privateAccess error.getMessage() == 'Minimum must be smaller than maximum!';
        error.getCategory() == 'validation';
        error.isClientSafe() == true;
    }

    function specResultValidationMethod() {
        // Using valid provided values
        var response = server.executeQuery("query($input:String!){
            toUpperCase(input:$input)
        }", {
            input: 'this is valid'
        }.associativeArrayOfObject());
        
        Assert.notNull(response.data);
        response.data['toUpperCase'] == "THIS IS VALID";

        // Using invalid provided values
        var response = server.executeQuery("query($input:String!){
            toUpperCase(input:$input)
        }", {
            input: 'forbidden'
        }.associativeArrayOfObject());
        
        Assert.isNull(response.data);

        Assert.notNull(response.errors);
        var errors = response.errors.toHaxeArray();
        errors.length == 1;
        var error : GraphQLError = errors[0];
        @:privateAccess error.getMessage() == 'Validation failed';
        error.getCategory() == 'validation';
        error.isClientSafe() == true;
    }

    function specVariableResolver() {
        // Get plain unprotected variable
        var response = server.executeQuery("{unprotectedVariable}"); 
               
        Assert.notNull(response.data);
        Assert.equals(response.data['unprotectedVariable'], 42);

        // Get plain unprotected variable, with no validation metadata)
        var response = server.executeQuery("{unvalidatedVariable}");
        
        Assert.notNull(response.data);
        Assert.equals(response.data['unvalidatedVariable'], 42);    

        // Get a blocked variable
        var response = server.executeQuery("{protectedVariable}");
        
        Assert.isNull(response.data);

        Assert.notNull(response.errors);
        var errors = response.errors.toHaxeArray();
        errors.length == 1;
        var error : GraphQLError = errors[0];
        @:privateAccess error.getMessage() == 'Validation failed';
        error.getCategory() == 'validation';
        error.isClientSafe() == true;
    }
}


class ResolverTestObject extends GraphQLObject {
    public function new() {}

    public function simpleMethod() : String {
        return "This is a simple response";
    }

    public function add(x:Int, y:Int) : Int {
        return x + y;
    }

    @:validate(false)
    public function protectedAdd(x:Int, y:Int) : Int {
        return x + y;
    }

    @:validate(false)
    public function protectedNullableAdd(x:Int, y:Int) : Null<Int> {
        return x + y;
    }

    @:validate(min < max, "Minimum must be smaller than maximum!")
    public function list(min: Int = 0, max:Int = 10) : Array<Int> {
        return [for(i in min...(max+1)) i];
    }

    @:validateResult(result != "FORBIDDEN")
    public function toUpperCase(input:String) : String {
        return input.toUpperCase();
    }

    @:validate(false)
    public var protectedVariable : Int = 42;

    @:validate(true)
    public var unprotectedVariable : Int = 42;

    public var unvalidatedVariable : Int = 42;
}
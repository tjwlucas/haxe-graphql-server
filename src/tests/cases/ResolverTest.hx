package tests.cases;

import graphql.GraphQLServer;
import graphql.GraphQLObject;
import utest.Assert;
import graphql.externs.NativeArray;
using graphql.Util;

#if php
    import php.Exception;
#end

class ResolverTest extends utest.Test {
    var server : GraphQLServer;
    var base : ResolverTestObject;
    function setup() {
        base = new ResolverTestObject();
        var context = new SomeContextClass();
        this.server = new GraphQLServer(base, context);
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
        var errors = response.errors;
        // errors.length == 1;
        var error : graphql.externs.Error = errors[0];
        error.getMessage() == 'Validation failed';
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
        var errors = response.errors;
        // errors.length == 1;
        var error : graphql.externs.Error = errors[0];
        error.getMessage() == 'Validation failed';
        error.getCategory() == 'validation';
        error.isClientSafe() == true;
    }

    function specProtectedNullableAddObjectValueMethod() {
        var response = server.executeQuery("query($x:Int!, $y:Int!){
            protectedNullableAddObjectValue(x:$x, y:$y)
        }", {
            x: 5,
            y: 12
        }.associativeArrayOfObject());
        
        Assert.notNull(response.data);
        response.data['protectedNullableAddObjectValue'] == null;

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
        var errors = response.errors;
        // errors.length == 1;
        var error : graphql.externs.Error = errors[0];
        error.getMessage() == 'Minimum must be smaller than maximum!';
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
        var errors = response.errors;
        // errors.length == 1;
        var error : graphql.externs.Error = errors[0];
        error.getMessage() == 'Validation failed';
        error.getCategory() == 'validation';
        error.isClientSafe() == true;
    }

    function specNullResolvers() {
        var fields = @:privateAccess base.gql.fields;

        var expect_resolvers = [
            'unvalidatedVariable' => false,
            'protectedVariable' => true,
            'unprotectedVariable' => true,
            'simpleMethod' => true,
            'staticFunction' => true,
            'staticVar' => true
        ];

        for(name => hasResolver in expect_resolvers) {
            var field = Util.getFieldDefinitionByName(fields, name);
            switch(hasResolver) {
                case true: field.resolve != null;
                case false: field.resolve == null;
            }
        }
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
        var errors = response.errors;
        // errors.length == 1;
        var error : graphql.externs.Error = errors[0];
        error.getMessage() == 'Validation failed';
        error.getCategory() == 'validation';
        error.isClientSafe() == true;
    }

    function specContext() {
        var response = server.executeQuery("{withContext}");
        Assert.notNull(response.data);
        if(response.data != null) {
            response.data['withContext'] == 'This is a value on the context';   
        }

        var response = server.executeQuery("{withNamedContext}");
        Assert.notNull(response.data);
        if(response.data != null) {
            response.data['withNamedContext'] == 'This is a value on the context';
        }

        var response = server.executeQuery("{withContextAndValidation}");
        Assert.notNull(response.data);
        if(response.data != null) {
            response.data['withContextAndValidation'] == 'This is a value on the context';
        }        

        var response = server.executeQuery("{withCustomContextAndValidation}");
        Assert.notNull(response.data);
        if(response.data != null) {
            response.data['withCustomContextAndValidation'] == 'This is a value on the context';
        }
    }

    function specStatic() {
        var response = server.executeQuery("{staticVar}");
        Assert.notNull(response.data);
        if(response.data != null) {
            response.data['staticVar'] == 'This is a static variable';   
        }
        var response = server.executeQuery("{staticVarWithValidation}");
        Assert.notNull(response.data);
        if(response.data != null) {
            response.data['staticVarWithValidation'] == 'This is a static variable (with arbitrary validation)';   
        }
        
        var response = server.executeQuery("{staticVarWithFailingValidation}");
        Assert.isNull(response.data);
        Assert.notNull(response.errors);
        var errors = response.errors;
        // errors.length == 1;
        var error : graphql.externs.Error = errors[0];
        error.getMessage() == 'Validation failed';
        error.getCategory() == 'validation';
        error.isClientSafe() == true;

        var response = server.executeQuery("{staticFunction}");
        Assert.notNull(response.data);
        if(response.data != null) {
            response.data['staticFunction'] == 'This is a static function';   
        }
    }
}


@:validationContext((ctx : SomeContextClass))
class ResolverTestObject implements GraphQLObject {
    public function new() {}

    var falseValue = false;

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

    @:validate(obj.falseValue)
    public function protectedNullableAddObjectValue(x:Int, y:Int) : Null<Int> {
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

    public function withContext(ctx : SomeContextClass) : String {
        return ctx.value;
    }

    @:context(custom)
    public function withNamedContext(custom : SomeContextClass) : String {
        return custom.value;
    }

    // Catch a bug whereby context variable is trying to be read from arguments
    @:validate(ctx.allowed == true)
    public function withContextAndValidation(ctx : SomeContextClass) : String {
        return ctx.value;
    }

    @:context(customContext)
    @:validate(customContext.allowed == true)
    public function withCustomContextAndValidation(customContext : SomeContextClass) : String {
        return customContext.value;
    }

    static public var staticVar : String = "This is a static variable";

    @:validate(true)
    static public var staticVarWithValidation : String = 'This is a static variable (with arbitrary validation)';
    
    @:validateResult(result != 'bad')
    static public var staticVarWithFailingValidation : String = 'bad';

    static public function staticFunction() : String {
        return "This is a static function";
    }
}

class SomeContextClass {
    public function new(){}
    public var value = 'This is a value on the context';
    public var allowed = true;
}
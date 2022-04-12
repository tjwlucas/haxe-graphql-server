# haxe-graphql-php-server

## What is it?
`haxe-graphql-php-server` is a library for Haxe that takes traditionally defined Haxe classes and generates (using build-time macros) a GraphQL schema and set of resolvers that can be used to run a ready-to-go graphql server.

## Requirements/target
As the name implies, the library targets PHP. It does not implement the GraphQL server itself, but rather converts the class structure of the Haxe code into a structure that can be interpreted by the [webonyx/graphql-php](https://github.com/webonyx/graphql-php) library to generate a complete working GraphQL server. Since `webonyx/graphql-php` is based on the [reference implementation in JavaScript](https://github.com/graphql/graphql-js) it is conceivable that, with some work, it could be modified to compile to a nodejs target using `graphql-js`, at some point, as well, although that is not currently on the roadmap.

## Why
While existing libraries for building a GraphQL servers can yield great results, the syntax required is very verbose. This makes sense in languages like Javascript and PHP, since the required typing information is not necessarily present, but with Haxe's typing system, I thought this could be streamlined. This library is an attempt at doing just that.

### Motivational Example (Building an ObjectType)

#### Plain PHP
Take the first example given in the `webonyx/graphql-php` documentation, and focussing purely on building the main Query object type:

```php
<?php
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;

$queryType = new ObjectType([
    'name' => 'Query',
    'fields' => [
        'echo' => [
            'type' => Type::string(),
            'args' => [
                'message' => Type::nonNull(Type::string()),
            ],
            'resolve' => fn ($rootValue, $args) => $rootValue['prefix'] . $args['message'],
        ],
    ],
]);
```

#### Equivalent Haxe using `haxe-graphql-php-server`

```haxe
import graphql.GraphQLObject;

class Query implements GraphQLObject {
    public function new(){}
    public function echo(message:String, ctx:Map<String, String>) : String {
        return ctx['prefix'] + message;
    }
}
```

## Quickstart

To set up and run a new GraphQL server, you will need to install this package:
```
haxelib install graphql-server-php
```
You will also need to install the `webonyx/graphql-php` using composer:
```
composer require webonyx/graphql-php
```

Then the following files:

`src/Main.hx`
```haxe
import graphql.GraphQLServer;

class Main {
    static function main() {
        var queryObject = new Query();
        var rootValue = [
            'prefix' => 'You said: '
        ];
        var server = new GraphQLServer(queryObject, rootValue);
        server.run();
    }
}
```
`src/Query.hx`
```haxe
import graphql.GraphQLObject;
class Query implements GraphQLObject {
    public function new(){}    
    public function echo(message:String, ctx: Map<String, String>) : Null<String> {
        return ctx['prefix'] + message;
    }
}
```
`build.hxml`
```hxml
-cp src
--main Main
-lib graphql-server-php
-php bin
```

Would be all you need to get a basic GraphQL server up and running.

### Printing the generated schema
In order to retrieve the generated schema as a GraphQL Schema Language string, once the `server` object has been created, as above, `server.readSchema()` will return a string containing the schema definition. In this case:
```gql
type Query {
  echo(message: String!): String
}
```

### Note on autoloading
By default, this configuration will include a 
```php
require_once('vendor/autoload.php');
```
Which will work in the case of running a development server like:
```
php -S 127.0.0.1:1234 ./bin/index.php
```
However, it is likely to need tailoring to your deployment. For that, there is a `vendor` build flag. For example: `-D vendor=../vendor/autoload.php` will change the require statement to `require_once('../vendor/autoload.php');`

`-D vendor=0` or `-D vendor=false` will remove the require statement altogether, if you do not need it.

## Basic functionality

### GraphQLServer

The `GraphqlServer` constructor takes 2 arguments, a `GraphQLObject` (Discussed in more detail, later) which defines the schema in its entirety (including resolvers), and an *optional* `context` object. This can be of *any* type, and is made available to all resolvers, throughout the schema (See [context](#context)) 

### GraphQLObject

The `GraphQLObject` is where the 'magic' happens. Any class that implements `GraphQLObject` will be processed at build time to generate an object type for the schema. For instance, from the earlier example:

```haxe
import graphql.GraphQLObject;

class Query implements GraphQLObject {
    public function new(){}    
    public function echo(message:String) : Null<String> {
        return message;
    }
    public function getObject() : OtherObject {
        return new OtherObject();
    }
}

class OtherObject implements GraphQLObject {
    public function new(){}
    public var property : String = "Value";
    public var float : Float = 3.215;
}
```

Will generate:
```gql
type Query {
    echo(message:String!) : String
    getObject : OtherObject!
}
type OtherObject {
    property : String!
    float : Float!
}
```
A couple of things to note: 
- Properties must be *explicitly* typed. (Both return values and function arguments)
- Allowed scalar types:
    - `String`
    - `Int`
    - `Float`
    - `Bool`
    - `Null<T>`
    - `Array<T>`
- There is also the special scalar `ID`, which can be represented using the haxe type `graphql.IDType`. This will auto-cast between `Int` and `String` values as required.
- These scalar types can be used as return values and input argument values.
- Additionally, any class implementing `GraphQLObject` can be used as a return type.
- Complex *input* types are not currently supported.
- By default, any property set as `public` will be added to the query type schema, and `private` properties ignored.
    - Public properties you want to remove from the schema can be annotated with `@:GraphQLHide`
    - Private properties can be added to the query schema by annotating with `@:query`
    - The `new()` constructor is a special case and will never be added to the schema
- Default values for function arguments will also be passed into the schema

### Context
The second parameter passed into the `GraphQLServer` constructor is a 'context' object. This is made available in resolved functions as an extra `ctx` argument. This argument will be ignored by the GraphQL typing macros and will automatically have the provided context passed to it when resolving. The object can be any type.

Notice in the initial example:
```haxe
import graphql.GraphQLObject;
class Main {
    static function main() {
        var queryObject = new Query();
        var rootValue = [
            'prefix' => 'You said: '
        ];
        var server = new GraphQLServer(queryObject, rootValue);
        server.run();
    }
}
class Query implements GraphQLObject {
    public function new(){}    
    public function echo(message:String, ctx: Map<String, String>) : Null<String> {
        return ctx['prefix'] + message;
    }
}
```

The value provided to the `GraphQLServer` at the start is made available via the `ctx` argument. The resultant GraphQL type will only include a `message` argument, the `ctx` is ignored. This `ctx` can be renamed from `ctx` on a per-field basis, using `@:context` metadata, e.g.:

```haxe
@:context(renamedContext)
public function echo(message:String, renamedContext: Map<String, String>) : Null<String> {
    return renamedContext['prefix'] + message;
}
```

Would be functionally equivalent to the previous example.

It can also be renamed per-project by defining the `gql_context_variable` build argument.
e.g. `-D gql_context_variable=renamedContext`.

### Mutations

Any field annotated with `@:mutation` will be added to a Mutation type corresponding to the `GraphQLObject` instead of a `Query` type. (it is permitted to use both `@:query` and `@:mutation`, in which which the property will appear on both Query and Mutation types). If (and only if) the root `GraphQLObject` contains at least one property annotated with `@:mutation`, a mutation root type will be generated. Mutation types follow all the same rules as Query types.

Simple example:

```haxe
class Base implements GraphQLObject {
    public function new(){}    
    public function echo(message:String) : Null<String> {
        return message;
    }
    @:mutation 
    function login(user:String, password:String, ctx:SessionObject) : Bool {
        return ctx.login(user, password);
    }
}
```
Would generate a schema following something like this:
```gql
type Base {
    echo(message:String!) : String
}
type BaseMutation {
    login(user:String!, password:String!) : Bool!
}
```

### Type Names

By default the types are named after the `ClassName` for the query type, and `ClassNameMutation` for mutation types. This can be modified by using the `@:typeName(MyCustomTypeName)` and `@:mutationName(MyCustomMutationTypeName)` metadata on the class.

### Validation

It is also simple to inject validation into resolvers using the `@:validation` metadata. It takes 3 parameters, only the first of which is required:
1. A statement that is required to be `true`
2. A message to return on failure (default `Validation failed`)
3. A 'category' for the error (default `validation`)

The statement passed in to the `@:validation` metadata can reference the arguments passed to the function, the context object (using `ctx`), and the current object being resolved (using `obj`). Extra statements can be added to the validation context using `@:validationContext`. This can be added either at the field level, or if added to the class, it will be included for every field on it. You can add as many validation statements as you like.

Validation example:

```haxe
@:validationContext(var nlimit = 1000)
class Base implements GraphQLObject {
    public function new(){}    

    @:validate(n >= 0, 'n must be non-negative ($n given)')
    @:validate(n <= nlimit, 'n must be <= $nlimit ($n given)')
    @:validate(ctx.isLoggedIn())
    public function random(n : Int = 10) : Null<Array<Float>> {
        return [for(i in 0...n) Math.random()];
    }
}
```
It is also possible to validate *after* retrieving the value, based on the result, using `@:validateResult`. This works exactly the same, except that the resolver is run *first*, and the result is stored in a `result` variable on the validator context:

```haxe
class Base implements GraphQLObject {
    public function new(){}    

    @:validateResult(result != null, "That returned null!")
    public function getSomeValue() : String {
        ...
    }
}
```

### Deprecation
Any field can be marked as deprecated by annotating with `@:deprecationReason("The deprecation message")`. The deprecation reason is required.

### Description
'Doc' style comments on both fields and classes will be included on the schema as the field/type description:

```haxe
/**
    This comment will describe the type on the schema
**/
class Query implements GraphQLObject {
    public function new(){}    

    /**
        This comment will describe the echo field on the schema
    **/
    public function echo(message:String) : String {
        return message;
    }
}
```

Alternatively, `@:doc` metadata can be use, instead (This will take precedence over any comments, and including just `@:doc` with no argument will clear the doc, even if there is a comment):

```haxe
/**
    This comment will describe the type on the schema
**/
@:doc("This is the base query")
class Query implements GraphQLObject {
    public function new(){}    

    /**
        This comment will not be included on the schema
    **/
    @:doc
    public function echo(@:doc("What would you like to say?") message:String) : String {
        return message;
    }
}
```

Results in:
```gql
"""This is the base query"""
type Query {
  echo(
    """What would you like to say?"""
    message: String!
  ): String!
}
```

### Deferred Resolvers (n+1 problem)

Resolution can be deferred and multiple fields resolved in a single call (See [N+1 problem](https://webonyx.github.io/graphql-php/data-fetching/#solving-n1-problem))

To use a similar example to the above link:

```haxe
class BlogStory implements GraphQLObject {
    ...
    var authorId : Int;

    @:deferred(MyUserBuffer, obj.authorId)
    public function getAuthor() : UserObject;

    @:deferred(MyUserBuffer)
    public function getUserById(id : Int) : UserObject;
}

class MyUserBuffer extends graphql.DeferredLoader {
    static function load() : Map<Int, UserObject> {
        // Backend code to populate `results` with a `Map<Int, UserObject>`
        // e.g a sql call for `select ... from user where id in ?`
        // with ? bound to the `keys` variable
        return results;
    }
}
```

The return type of the `load` function must be of the form `Map<K,V>`. If a second argument is passed to `@:deferred` it must be an expression corresponding to the key to be loaded (This is scoped just as the [validation](#validation) expressions). This loader class will have a static property called `keys`, with the type `Array<K>` (So in this example, `Array<Int>`), which will be available through `keys`/`this.keys`/`[[ Your Loader Class Name ]].keys` in your load function.

e.g. 
```haxe
@:deferred(MyUserBuffer)
public function getUserById(id : Int) : UserObject;
```
Is equivalent to
```haxe
@:deferred(MyUserBuffer, id)
public function getUserById(id : Int) : UserObject;
```

For any more customised uses for the deferred resolver, the `Deferred` class is available as an extern:
```haxe
new graphql.externs.Deferred<String>(() -> {
    return "Some String";
});
```
#### Notes:
- Returning a `Deferred` type directly will result in any post-validation seeing the `Deferred` object as the result, whereas the automatic method above will act on the final result, as expected.
- Functions generated using the `@:deferred` method above will be removed from the class, and exist *only* directly on the resolver.
- In the case of nested resolvers, the deferred resolver may need to run several times (e.g. if the keys for sub-calls depend on the results from parents). In this case, the load will still be deferred, and each successive call will add to the previous results list, so new data will still be batched and fetched only if it has not already been.


### Build flags

|flag|Value|Purpose|
|-|-|-|
|`gql_explicit_resolvers`|`none`|Always build a resolver function for a field (rather than leaving `null` for simple properties, as is default)|
|`vendor`|`0`/`false`/`[path]`|Disable or set path for [vendor require](#note-on-autoloading)|
|`graphql-verbose`|`none`|Generate verbose output at build time|
|`gql_context_variable`|`ctx`|Renames the context variable used in resolvers (see [context](#context))|
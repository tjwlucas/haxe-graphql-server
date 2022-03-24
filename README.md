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

class Query extends GraphQLObject {
    public function new(){}
    public function echo(message:String, ctx:Map<String, String>) : String {
        return ctx['prefix'] + message;
    }
}
```

## Quickstart

To set up and run a new GarphQL server, you will need to install this package:
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
class Query extends GraphQLObject {
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

The `GraphQLObject` is where the 'magic' happens. Any class that extends `GraphQLObject` will be processed at build time to generate an object type for the schema. For instance, from the earlier example:

```haxe
import graphql.GraphQLObject;

class Query extends GraphQLObject {
    public function new(){}    
    public function echo(message:String) : Null<String> {
        return message;
    }
    public function getObject() : OtherObject {
        return new OtherObject();
    }
}

class OtherObject extends GraphQLObject {
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
- These scalar types can be used as return values and input argument values.
- Additionally, any class extending `GraphQLObject` can be used as a return type.
- Complex *input* types are not currently supported.

### Context
TODO
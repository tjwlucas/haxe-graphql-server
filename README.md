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

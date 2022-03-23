# haxe-graphql-php-server

## What is it?
`haxe-graphql-php-server` is a library for Haxe that takes traditionally defined Haxe classes and generates (using build-time macros) a GraphQL schema and set of resolvers that can be used to run a ready-to-go graphql server.

## Requirements/target
As the name implies, the library targets PHP. It does not implement the GraphQL server itself, but rather converts the class structure of the Haxe code into a structure that can be interpreted by the `webonyx/graphql-php` library to generate a complete working GraphQL server.

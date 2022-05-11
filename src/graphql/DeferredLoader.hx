package graphql;

/**
    Abstract class which, when extended will be built into a deferred resolver.

    A static `load()` function should be provided, taking an Array of IDs,
    and returning a corresponding Map of results, as in this partial example:

    ```
    class MyDataLoader extends graphql.DeferredLoader {
        static function load(keys:Array<Int>) : Map<Int, DataObject> {
            // Backend code to populate `results` with a `Map<Int, UserObject>`
            // e.g a sql call for `select ... from data where id in ?`
            // with ? bound to the `keys` variable
            return results;
        }
    }
    ```
**/
@:autoBuild(graphql.DeferredLoaderBuilder.build())
abstract class DeferredLoader {}
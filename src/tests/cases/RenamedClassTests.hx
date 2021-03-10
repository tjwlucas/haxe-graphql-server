package tests.cases;

import utest.Assert;
import tests.types.RenamedClass;
import utest.Test;

class RenamedClassTests extends Test {
    var type = RenamedClass;
    function specTypeExists() {
        Assert.notNull(type.gql);
    }

    @:depends(specTypeExists)
    function specTypeName() {
        @:privateAccess type.gql.type_name == 'RenamedForGraphQL';
    }
}
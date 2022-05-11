package tests;

import utest.Runner;
import graphql.Util;

class TestLoader {
    static function main() : Void {
        var runner = new Runner();
        new NoExitReport(runner);
        runner.addCases(tests.cases);
        runner.run();
    }

    static function __init__() : Void {
        Util.phpCompat();
    }
}

class NoExitReport extends utest.ui.text.PrintReport {
    override function complete(result:utest.ui.common.PackageResult) : Void {
        this.result = result;

        Sys.println(this.getResults());

        if (!result.stats.isOk) {
            Sys.exit(1);
        }
    }
}

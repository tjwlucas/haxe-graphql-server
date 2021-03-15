package tests;

import utest.Runner;

class TestLoader {
	static function main() {
		var runner = new Runner();
		new NoExitReport(runner);
		runner.addCases(tests.cases);
		runner.run();
	}

	static function __init__() {
		php.Global.require_once('vendor/autoload.php');
	}
}

class NoExitReport extends utest.ui.text.PrintReport {
	override function complete(result:utest.ui.common.PackageResult) {
		this.result = result;

		Sys.println(this.getResults());

		if (!result.stats.isOk) {
			Sys.exit(1);
		}
	}
}

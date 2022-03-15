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
		// PHP 8.1 compatibility workaround https://github.com/HaxeFoundation/haxe/issues/10502
		untyped if (version_compare(PHP_VERSION, "8.1.0", ">=")) error_reporting(error_reporting() & ~E_DEPRECATED);
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

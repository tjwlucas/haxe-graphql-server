package tests;

import utest.Runner;

class TestLoader {
	static function main() {
		CompileTime.importPackage("tests.cases");
		var testcases = CompileTime.getAllClasses('tests.cases');

		var runner = new Runner();
		new NoExitReport(runner);
		for (c in testcases)
			runner.addCase(Type.createInstance(c, []));
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

		if (result.stats.isOk) {
			// Sys.println('Tests passed, continuing with build...');
		} else {
			// Sys.println('Tests failed, aborting build.');
			Sys.exit(1);
		}
	}
}

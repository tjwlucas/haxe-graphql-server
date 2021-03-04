<?php

// `haxe build.hxml`;

require_once('./bin/autoload.php');

set_include_path(get_include_path().PATH_SEPARATOR.__DIR__);
spl_autoload_register(
	function($class){
		$file = stream_resolve_include_path(str_replace('\\', '/', $class) .'.php');
		if ($file) {
			include_once $file;
		}
	}
);

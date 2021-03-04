<?php

use PHPUnit\Framework\TestCase;
use tests\TestLoader;

class GeneralTest extends TestCase
{
    function testTrue()
    {
        $this->assertEquals(true, TestLoader::loaded);
    }
}

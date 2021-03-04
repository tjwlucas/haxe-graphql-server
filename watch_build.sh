#!/usr/bin/env bash

build
while inotifywait -re close_write ./src
do
    haxe build.hxml
done
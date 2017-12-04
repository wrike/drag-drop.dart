#!/usr/bin/env bash

rm -rf .dart_tool && cd tool/generate/ && pub get && cd ../../ && rm -rf ./dart_tool/build && rm -rf ./.dart_tool/build && dart ./tool/generate/build.dart ${1}

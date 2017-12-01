import 'dart:async';

import 'package:build_runner/build_runner.dart';
import 'package:built_value_generator/built_value_generator.dart';
import 'package:source_gen/source_gen.dart';

Future main(List<String> args) async {
  String entryPoint = args.isNotEmpty ? args.first : 'lib';
  if (!entryPoint.endsWith('.dart')) {
    if (!entryPoint.endsWith('/')) {
      entryPoint += '/';
    }
    entryPoint += '**.dart';
  }

  await build(
      new PhaseGroup.singleAction(
          new PartBuilder([new BuiltValueGenerator()]),
          new InputSet(
              new PackageGraph.forThisPackage().root.name, [entryPoint])),
      deleteFilesByDefault: true);
}


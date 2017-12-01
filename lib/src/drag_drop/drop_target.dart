library drop_target;

import 'dart:html';
import 'package:built_value/built_value.dart';
import 'options/drop_options.dart';

part 'drop_target.g.dart';


abstract class DropTarget implements Built<DropTarget, DropTargetBuilder> {
  factory DropTarget([updates(DropTargetBuilder b)]) = _$DropTarget;

  DropTarget._();

  Element get element;
  Element get container;
  DropOptions get options;

  @nullable
  Object get model;

  @nullable
  bool get canAccept;
}



library drag_source;

import 'dart:html';
import 'package:built_value/built_value.dart';
import 'options/drag_options.dart';

part 'drag_source.g.dart';


abstract class DragSource implements Built<DragSource, DragSourceBuilder> {
  factory DragSource([updates(DragSourceBuilder b)]) = _$DragSource;

  DragSource._();

  @nullable
  Element get element;

  @nullable
  Element get container;

  @nullable
  DragOptions get options;

  @nullable
  Object get model;

  @nullable
  Element get ghostElement;

  @nullable
  Element get sourceElement;
}



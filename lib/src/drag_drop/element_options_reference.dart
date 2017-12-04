library element_options_reference;

import 'dart:html';
import 'package:built_value/built_value.dart';
import 'options/base_options.dart';

part 'element_options_reference.g.dart';


/// Reference holds Source element (event.target) and it's closes parent element
/// as a Target, what is matched as a valid target by Options, bound
/// to the parent Container element.
/// Container holds Target which is Source itself or contains Source

abstract class DragDropElementOptionsReference implements Built<DragDropElementOptionsReference, DragDropElementOptionsReferenceBuilder> {
  factory DragDropElementOptionsReference([updates(DragDropElementOptionsReferenceBuilder b)]) = _$DragDropElementOptionsReference;

  DragDropElementOptionsReference._();

  BaseDragDropOptions get options;
  Element get source;
  Element get target;
  Element get container;

  @nullable
  bool get isBlocked;
}

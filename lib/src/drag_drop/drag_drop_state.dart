library drag_drop_state;

import 'package:built_value/built_value.dart';

part 'drag_drop_state.g.dart';


abstract class DragDropState implements Built<DragDropState, DragDropStateBuilder> {
  factory DragDropState([updates(DragDropStateBuilder b)]) = _$DragDropState;

  DragDropState._();

  bool get isDragging;
  bool get isEnabled;
}



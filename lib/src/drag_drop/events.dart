import 'dart:html';

import '../../movement.dart';
import 'drag_source.dart';
import 'drop_target.dart';



abstract class BaseDragEvent {
  final MouseEvent browserEvent;
  final DragSource source;

  BaseDragEvent({this.source, this.browserEvent});
}

abstract class BaseDragDropEvent extends BaseDragEvent {
  final DropTarget target;

  BaseDragDropEvent({this.target, DragSource source, MouseEvent browserEvent})
    : super(source: source, browserEvent: browserEvent);
}

class DropEvent extends BaseDragDropEvent {
  DropEvent({DropTarget target, DragSource source, MouseEvent browserEvent})
    : super(target: target, source: source, browserEvent: browserEvent);
}

class DragEndEvent extends BaseDragDropEvent {
  final bool firedAfterDrop;

  DragEndEvent({DropTarget target, DragSource source, MouseEvent browserEvent, this.firedAfterDrop})
    : super(target: target, source: source, browserEvent: browserEvent);
}

class DragEnterEvent extends DragDropMovementEvent {
  DragEnterEvent({DropTarget target, DragSource source, MouseEvent browserEvent, MovementDetails movement})
    : super(target: target, source: source, browserEvent: browserEvent, movement: movement);
}

class DragSpringEnterEvent extends DragDropMovementEvent {
  DragSpringEnterEvent({DropTarget target, DragSource source, MouseEvent browserEvent, MovementDetails movement})
    : super(target: target, source: source, browserEvent: browserEvent, movement: movement);
}

class DragLeaveEvent extends BaseDragDropEvent {
  final bool firedBeforeEnd;

  DragLeaveEvent({DropTarget target, DragSource source, MouseEvent browserEvent, this.firedBeforeEnd: false})
    : super(target: target, source: source, browserEvent: browserEvent);
}

class DragOverEvent extends  DragDropMovementEvent {
  DragOverEvent({DropTarget target, DragSource source, MouseEvent browserEvent, MovementDetails movement})
    : super(target: target, source: source, browserEvent: browserEvent, movement: movement);
}

class DragStartEvent extends BaseDragEvent {
  DragStartEvent({DragSource source, MouseEvent browserEvent})
    : super(source: source, browserEvent: browserEvent);
}

abstract class DragDropMovementEvent extends BaseDragDropEvent {
  final MovementDetails movement;

  DragDropMovementEvent({DropTarget target, DragSource source, MouseEvent browserEvent, this.movement})
    : super(target: target, source: source, browserEvent: browserEvent);
}

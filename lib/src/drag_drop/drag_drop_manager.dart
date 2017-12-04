import 'dart:async';
import 'dart:html';
import '../../scroll.dart';
import 'drag_drop_state.dart';
import 'element_manager.dart';
import 'event_manager.dart';
import 'events.dart';
import 'options/drag_options.dart';
import 'options/drop_options.dart';
import 'reference_manager.dart';


abstract class DragDropManager {

  static const String ACCEPTABLE_TARGET_DROP_EFFECT = 'move';
  static const String NON_ACCEPTABLE_TARGET_DROP_EFFECT = 'none';
  static const String PERMITTED_SOURCE_OPERATIONS = 'move';

  Stream<DragDropState> get onStateChange;

  DragDropState get state;

  Stream<DragStartEvent> get onDragStart;
  Stream<DragEnterEvent> get onDragEnter;
  Stream<DragSpringEnterEvent> get onDragSpringEnter;
  Stream<DragOverEvent> get onDragOver;
  Stream<DragLeaveEvent> get onDragLeave;
  Stream<DropEvent> get onDrop;
  Stream<DragEndEvent> get onDragEnd;

  DragDropManager(ScrollManager scrollManager, DragDropElementManager elementManager,
    MovementManager movementManager, DragDropEventManager eventManager,
    DragDropReferenceManager referenceManager);

  void handleBeforeDragStart(MouseEvent event);
  void handleDragStart(MouseEvent event);
  void handleDragEnter(MouseEvent event);
  void handleDragLeave(MouseEvent event);
  void handleDragOver(MouseEvent event);
  void handleDrop(MouseEvent event);
  void handleDragEnd(MouseEvent event);
  void handleAfterDragEnd(MouseEvent event);
  void attachDropOptions(Element container, DropOptions options);
  void attachDragOptions(Element container, DragOptions options);
  void detachDropOptions(Element container, DropOptions options);
  void detachDragOptions(Element container, DragOptions options);
  void makeElementDroppable(Element element);
  void makeElementDraggable(Element element);
  void makeElementNonDraggable(Element element);
  void enable();
  void disable();
  void destroy();

}

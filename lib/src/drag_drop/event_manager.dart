import 'dart:async';
import 'dart:html';
import 'package:user_environment/user_environment.dart';
import 'drag_drop_manager.dart';
import 'element_manager.dart';
import 'event_queue.dart';
import 'events.dart';


abstract class DragDropEventManager {

  Stream<DragStartEvent> get onDragStart;
  Stream<DragEnterEvent> get onDragEnter;
  Stream<DragSpringEnterEvent> get onDragSpringEnter;
  Stream<DragOverEvent> get onDragOver;
  Stream<DragLeaveEvent> get onDragLeave;
  Stream<DropEvent> get onDrop;
  Stream<DragEndEvent> get onDragEnd;

  DragDropEventManager(DragDropElementManager elementManager, DragDropEventQueue dragDropEventQueue, Element dragDropContainer, UserEnvironment environment);

  void attachDragDropManager(DragDropManager manager);
  void detachDragDropManager();
  bool hasDragDropManagerAttached();
  Element getEventTarget(MouseEvent event);
  void addEvent(BaseDragEvent event);
  void reset();

}

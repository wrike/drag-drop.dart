import 'dart:html';
import 'drag_source.dart';
import 'drop_target.dart';
import 'element_manager.dart';
import 'element_options_reference.dart';
import 'model_storage.dart';
import 'options/base_options.dart';
import 'options/drag_options.dart';
import 'options/drop_options.dart';


typedef bool BaseDragDropOptionsMatcher(BaseDragDropOptions options);
typedef DragSource OptionsSpecificSourceProvider();

abstract class DragDropReferenceManager {

  DragDropReferenceManager(DragDropElementManager elementManager, DragDropModelStorage modelStorage);

  void attachDropOptions(Element container, DropOptions options);
  void attachDragOptions(Element container, DragOptions options);
  void detachDropOptions(Element container, DropOptions options);
  void detachDragOptions(Element container, DragOptions options);
  DragDropElementOptionsReference getReferenceForTargetElement(Element startElement, DragSource source, MouseEvent event);
  DragDropElementOptionsReference getReferenceForSourceElement(Element startElement, [Element dragStartElement]);
  List<Element> getSuitableDropContainerElements(Element startElement, DragSource source);
  DragSource refineDragSourceOrGetOptionsSpecific(DragSource source, DropOptions options, MouseEvent event);
  DragDropElementOptionsReference createReferenceFromDropTarget(DropTarget target);
  DropTarget createDropTargetFromReference(DragDropElementOptionsReference reference);
  DragSource createDragSourceFromReference(DragDropElementOptionsReference reference, [Element dragStartElement]);
  void reset();

}

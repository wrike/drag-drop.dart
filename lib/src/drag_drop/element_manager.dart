import 'dart:html';
import 'dart:math';
import 'package:user_environment/user_environment.dart';
import 'drag_source.dart';
import 'drop_target.dart';


abstract class DragDropElementManager {

  static const String ELEMENT_DROPPABLE_ATTRIBUTE = 'droppable';
  static const String SOURCE_GHOST_WRAPPER = 'drag-source-ghost-wrapper';
  static const String SOURCE_GHOSTED_CLS = 'drag-source-valid';
  static const String TARGET_OVER_CLS = 'drop-target-over';
  static const String TARGET_OVER_VALID_CLS = 'drop-target-over-valid';
  static const String TARGET_OVER_INVALID_CLS = 'drop-target-over-invalid';
  static const String TARGET_SPRING_CLS = 'drop-target-spring';
  static const String TARGET_SPRING_VALID_CLS = 'drop-target-spring-valid';
  static const String TARGET_SPRING_INVALID_CLS = 'drop-target-spring-invalid';
  static const String CONTAINER_OVER_CLS = 'drag-drop-container-over';

  static final Point<int> DEFAULT_GHOST_OFFSET = new Point<int>(0, 0);
  static final Point<int> MINIMUM_DRAG_IMAGE_OFFSET = new Point<int>(5, 5);

  Element get dragDropContainer;
  Element get ghostContainer;
  UserEnvironment get environment;

  DragDropElementManager(Element dragDropContainer, Element ghostContainer, UserEnvironment environment);

  Element getDropTargetElement(Element startElement);
  Element getDragSourceElement(Element startElement);
  Element getParentElement(el);
  bool isElementDraggable(Element element);
  bool isElementDroppable(Element element);
  void makeElementDroppable(Element element);
  void makeElementDraggable(Element element);
  void makeElementNonDraggable(Element element);
  List<Element> makeElementAncestorsNonDraggable(Element startElement);
  bool isInputElement(Element startElement);
  bool isElementAncestorOf(Element ancestorElement, Element childElement, [Element stopElement]);
  Point getElementEventRelativePosition(Element element, MouseEvent event);
  Element createGhostElement(DragSource source, MouseEvent event);
  void setDragImage(Element ghostElement, MouseEvent event);
  void moveGhostElementByEvent(MouseEvent event);
  void removeGhostElement();
  void hideGhostElement();
  void showGhostElement();
  void highlightDropContainers(List<Element> containers);
  void clearDropContainers();
  void decorateDropContainer(Element container);
  void clearDropContainer(Element container);
  void decorateSpringDropTarget(DropTarget dropTarget);
  void clearSpringDropTarget(DropTarget dropTarget);
  void decorateDropTarget(DropTarget dropTarget);
  void clearDropTarget(DropTarget dropTarget);
  void decorateDragSource(DragSource dragSource);
  void clearDragSource(DragSource dragSource);
  void reset();

}

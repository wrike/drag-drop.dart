import 'dart:html';
import 'dart:math';
import 'package:user_environment/user_environment.dart';
import 'drag_source.dart';
import 'drop_target.dart';
import 'element_manager.dart';
import 'options/ghost_options.dart';


typedef bool _ElementMatcher(Element element);


class DragDropElementManagerImpl implements DragDropElementManager {

  static const List<String> _INPUT_TAGS = const ['INPUT', 'TEXTAREA', 'SELECT'];

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

  final Element dragDropContainer;
  final Element ghostContainer;
  final UserEnvironment environment;

  final Set<Element> _activeDropContainers = new Set<Element>();

  Element _ghostElementContainer;
  Point<int> _ghostElementContainerEventRelativeOffset;

  bool get _isDragImageNotSupported => environment.browser.type == BrowserType.IE || environment.browser.type == BrowserType.Edge;

  DragDropElementManagerImpl(this.dragDropContainer, this.ghostContainer, this.environment) {
    _decorateGhostContainer();
  }

  Element getDropTargetElement(Element startElement) {
    return _getMatchedElementOrAncestor(startElement, isElementDroppable);
  }

  Element getDragSourceElement(Element startElement) {
    return _getMatchedElementOrAncestor(startElement, isElementDraggable);
  }

  Element _getMatchedElementOrAncestor(Element startElement, _ElementMatcher elementMatcher) {
    Element el = startElement;

    while (el != null) {
      if (elementMatcher(el)) {
        return el;
      }
      el = getParentElement(el);
    }
    return null;
  }

  Element getParentElement(el) {
    return el == dragDropContainer ? null : _getNonRestrictedParentElement(el);
  }

  Element _getNonRestrictedParentElement(Element element) {
    return element.parentNode == document ? null : element.parent;
  }

  bool isElementDraggable(Element element) {
    return element.draggable ?? false;
  }

  bool isElementDroppable(Element element) {
    String value = element.getAttribute(ELEMENT_DROPPABLE_ATTRIBUTE);
    return value != null && value.toLowerCase() != 'false';
  }

  void makeElementDroppable(Element element) {
    element.setAttribute(ELEMENT_DROPPABLE_ATTRIBUTE, 'true');
  }

  void makeElementDraggable(Element element) {
    element.draggable = true;
  }

  void makeElementNonDraggable(Element element) {
    element.draggable = false;
  }

  List<Element> makeElementAncestorsNonDraggable(Element startElement) {
    List<Element> affectedElements = <Element>[];
    Element el = startElement;
    while (el != null) {
      if (isElementDraggable(el)) {
        affectedElements.add(el);
        makeElementNonDraggable(el);
      }
      el = getParentElement(el);
    }
    return affectedElements;
  }

  bool isInputElement(Element startElement) {
    if (_INPUT_TAGS.contains(startElement.tagName)) {
      return true;
    }

    Element el = startElement;
    while (el != null) {
      if (el.contentEditable?.toLowerCase() == 'true') {
        return true;
      }
      el = _getNonRestrictedParentElement(el);
    }
    return false;
  }

  bool isElementAncestorOf(Element ancestorElement, Element childElement, [Element stopElement]) {
    if (childElement == null || ancestorElement == null) {
      return false;
    }
    Element el = childElement;
    while (el != null) {
      if (el == ancestorElement) {
        return true;
      } else if (el == stopElement) {
        return false;
      }
      el = _getNonRestrictedParentElement(el);
    }
    return false;
  }

  Point getElementEventRelativePosition(Element element, MouseEvent event) {
    Rectangle rect = _getElementPageClientRect(element);
    return new Point(
      (event.page.x - rect.left).toInt().clamp(0, rect.width),
      (event.page.y - rect.top).toInt().clamp(0, rect.height)
    );
  }

  Rectangle<num> _getElementPageClientRect(Element element) {
    Rectangle<num> rect = element.getBoundingClientRect();
    return new Rectangle<num>(rect.left + window.scrollX, rect.top + window.scrollY, rect.width, rect.height);
  }

  Element createGhostElement(DragSource source, MouseEvent event) {
    Element container;

    DragGhostOptions ghostOptions = source.options.provideGhost(source);
    Element ghostElement = (ghostOptions?.element ?? source.element)?.clone(true);

    if (ghostElement != null) {
      if (_isDragImageNotSupported) {
        ghostElement.style.visibility = 'hidden';
      }
      Rectangle sourceRect = source.element.getBoundingClientRect();
      Point<int> containerOffset = ghostOptions?.offset ?? DEFAULT_GHOST_OFFSET;
      Point<int> containerPosition = new Point(sourceRect.left.toInt() + containerOffset.x, sourceRect.top.toInt() + containerOffset.y);
      container = _createGhostElementContainer(containerPosition);
      container.append(ghostElement);
      ghostContainer.append(container);
      _ghostElementContainerEventRelativeOffset = new Point((event.page.x - window.scrollX).toInt() - containerPosition.x, (event.page.y - window.scrollY).toInt() - containerPosition.y);
    }

    _ghostElementContainer = container;
    return ghostElement;
  }

  Element _createGhostElementContainer(Point position) {
    Element container = new DivElement();
    container.style
      ..left = '${position.x}px'
      ..top = '${position.y}px'
      ..pointerEvents = 'none'
    ;
    _addClasses(container, [SOURCE_GHOST_WRAPPER]);
    return container;
  }

  void setDragImage(Element ghostElement, MouseEvent event) {
    if (_isDragImageNotSupported || ghostElement == null) {
      return;
    }
    Point offset = _calculateDragImagesOffset(ghostElement, event);
    event.dataTransfer.setDragImage(ghostElement, offset.x, offset.y);
  }

  Point _calculateDragImagesOffset(Element ghostElement, MouseEvent event) {
    Rectangle ghostRect = _getElementPageClientRect(ghostElement);

    int minXOffset = min(MINIMUM_DRAG_IMAGE_OFFSET.x, ghostRect.width ~/ 2);
    int minYOffset = min(MINIMUM_DRAG_IMAGE_OFFSET.y, ghostRect.height ~/ 2);
    int maxXOffset = max(minXOffset + 1, (ghostRect.width - minXOffset).toInt());
    int maxYOffset = max(minYOffset + 1, (ghostRect.height - minYOffset).toInt());
    int offsetX = (event.page.x - ghostRect.left).toInt();
    int offsetY = (event.page.y - ghostRect.top).toInt();

    return new Point(
      offsetX.clamp(minXOffset, maxXOffset),
      offsetY.clamp(minYOffset, maxYOffset)
    );
  }

  void moveGhostElementByEvent(MouseEvent event) {
    if (_ghostElementContainer != null) {
      _ghostElementContainer.style
        ..top = '${(event.page.y - window.scrollY).toInt() - _ghostElementContainerEventRelativeOffset.y}px'
        ..left = '${(event.page.x - window.scrollX).toInt() - _ghostElementContainerEventRelativeOffset.x}px'
        ..pointerEvents = 'auto'
      ;
    }
  }

  void removeGhostElement() {
    _ghostElementContainerEventRelativeOffset = null;
    if (_ghostElementContainer != null) {
      _ghostElementContainer.remove();
      _ghostElementContainer = null;
    }
  }

  void hideGhostElement() => _setGhostContainerDisplayProperty('none');

  void showGhostElement() => _setGhostContainerDisplayProperty('block');

  void _setGhostContainerDisplayProperty(String type) {
    if (_ghostElementContainer != null) {
      _ghostElementContainer.style.display = type;
    }
  }

  void highlightDropContainers(List<Element> containers) {
    _activeDropContainers.where((Element container) => !containers.contains(container)).toList()
      .forEach(clearDropContainer);
    containers.where((Element container) => !_activeDropContainers.contains(container))
      .forEach(decorateDropContainer);
  }

  void clearDropContainers() {
    _activeDropContainers.toList().forEach(clearDropContainer);
  }

  void decorateDropContainer(Element container) {
    _addClasses(container, [CONTAINER_OVER_CLS]);
    _activeDropContainers.add(container);
  }

  void clearDropContainer(Element container) {
    _removeClasses(container, [CONTAINER_OVER_CLS]);
    _activeDropContainers.remove(container);
  }

  void decorateSpringDropTarget(DropTarget dropTarget) {
    _addClasses(dropTarget.element, [
      TARGET_SPRING_CLS,
      dropTarget.canAccept ? TARGET_SPRING_VALID_CLS : TARGET_SPRING_INVALID_CLS
    ]);
    _removeClasses(dropTarget.element, [
      dropTarget.canAccept ? TARGET_SPRING_INVALID_CLS : TARGET_SPRING_VALID_CLS
    ]);
  }

  void clearSpringDropTarget(DropTarget dropTarget) {
    _removeClasses(dropTarget.element, [
      TARGET_SPRING_CLS,
      TARGET_SPRING_VALID_CLS,
      TARGET_SPRING_INVALID_CLS
    ]);
  }

  void decorateDropTarget(DropTarget dropTarget) {
    _addClasses(dropTarget.element, [
      TARGET_OVER_CLS,
      dropTarget.canAccept ? TARGET_OVER_VALID_CLS : TARGET_OVER_INVALID_CLS
    ]);
    _removeClasses(dropTarget.element, [
      dropTarget.canAccept ? TARGET_OVER_INVALID_CLS : TARGET_OVER_VALID_CLS
    ]);
  }

  void clearDropTarget(DropTarget dropTarget) {
    clearSpringDropTarget(dropTarget);
    _removeClasses(dropTarget.element, [
      TARGET_OVER_CLS,
      TARGET_OVER_VALID_CLS,
      TARGET_OVER_INVALID_CLS
    ]);
  }

  void decorateDragSource(DragSource dragSource) {
    _addClasses(dragSource.element, [SOURCE_GHOSTED_CLS]);
  }

  void clearDragSource(DragSource dragSource) {
    _removeClasses(dragSource.element, [SOURCE_GHOSTED_CLS]);
  }

  void _decorateGhostContainer() {
    List<String> classNames = new List<String>();

    if (environment.browser.type == BrowserType.Edge) {
      classNames.add('isEdge');
    }
    else if (environment.browser.type == BrowserType.IE) {
      classNames.add('isIE');

      if (environment.browser.version == new BrowserVersion('11')) {
        classNames.add('isIE11');
      }
      else if (environment.browser.version == new BrowserVersion('10')) {
        classNames.add('isIE10');
      }

    }
    else if (environment.browser.type == BrowserType.Firefox) {
      classNames.add('isFirefox');
    }
    else if (environment.browser.type == BrowserType.Safari) {
      classNames.add('isSafari');
    }
    else if (environment.browser.type == BrowserType.Chrome) {
      classNames.add('isChrome');
    }
    else if (environment.browser.type == BrowserType.Opera) {
      classNames.add('isOpera');
    }
    else if (environment.browser.type == BrowserType.Other) {
      classNames.add('isOtherBrowser');
    }

    if (environment.platform.type == UserPlatformType.Mac) {
      classNames.add('isMacPlatform');
    }
    else if (environment.platform.type == UserPlatformType.Windows) {
      classNames.add('isWindowsPlatform');
    }
    else if (environment.platform.type == UserPlatformType.Other) {
      classNames.add('isOtherPlatform');
    }

    _addClasses(ghostContainer, classNames);
  }

  void _addClasses(Element element, List<String> classNames) {
    element?.classes?.addAll(classNames);
  }

  void _removeClasses(Element element, List<String> classNames) {
    element?.classes?.removeAll(classNames);
  }

  void reset() {
    clearDropContainers();
    removeGhostElement();
  }

}

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'package:user_environment/user_environment.dart';
import 'drag_drop_manager.dart';
import 'element_manager.dart';
import 'event_queue.dart';
import 'event_manager.dart';
import 'events.dart';
import 'responsive_stream_manager.dart';


class DragDropEventManagerImpl implements DragDropEventManager {

  static const String _MS_IE_FORCE_DND_METHOD_NAME = 'dragDrop';
  static const String _MS_IE_JS_EVENT_TARGET_PROPERTY_NAME = 'target';
  static const String _MS_IE_JS_PARENT_NODE_PROPERTY_NAME = 'parentNode';
  static const String _MS_IE_JS_CORRESPONDING_ELEMENT_PROPERTY_NAME = 'correspondingElement';
  static const String _MS_IE_JS_OWNER_SVG_ELEMENT_PROPERTY_NAME = 'ownerSVGElement';

  static const List<BrowserType> _deactivateDragOnInputFocusForBrowserTypes = const <BrowserType>[BrowserType.Firefox, BrowserType.IE, BrowserType.Edge];

  final List<Element> _deactivatedDraggableElements = <Element>[];

  final DragDropElementManager _elementManager;
  final DragDropEventQueue _dragDropEventQueue;
  final Element _dragDropContainer;
  final UserEnvironment _environment;

  DragDropManager _dragDropManager;
  Element _dragStartElement;

  StreamController<DragStartEvent> _onDragStartController;
  Stream<DragStartEvent> get onDragStart {
    _onDragStartController ??= new ResponsiveStreamManager<DragStartEvent>(() {
      List<StreamSubscription> dependencies = [
        _dragDropContainer.onMouseDown.listen(_onMouseDown),
        _dragDropContainer.onMouseUp.listen(_onMouseUp),
        _dragDropContainer.onDragStart.listen(_onDragStart)
      ];
      if (_environment.browser.type == BrowserType.IE) {
        dependencies.add(
          _dragDropContainer.onSelectStart.listen(_onSelectStart)
        );
      }
      return dependencies;
    }
    ).controller;
    return _onDragStartController.stream;
  }

  StreamController<DragEnterEvent> _onDragEnterController;
  Stream<DragEnterEvent> get onDragEnter {
    _onDragEnterController ??= new ResponsiveStreamManager<DragEnterEvent>(() => [
      _dragDropContainer.onDragEnter.listen(_onDragEnter)
    ]).controller;
    return _onDragEnterController.stream;
  }

  StreamController<DragSpringEnterEvent> _onDragSpringEnterController;
  Stream<DragSpringEnterEvent> get onDragSpringEnter {
    _onDragSpringEnterController ??= new ResponsiveStreamManager<DragSpringEnterEvent>(() => [
    ]).controller;
    return _onDragSpringEnterController.stream;
  }

  StreamController<DragOverEvent> _onDragOverController;
  Stream<DragOverEvent> get onDragOver {
    _onDragOverController ??= new ResponsiveStreamManager<DragOverEvent>(() => [
      _dragDropContainer.onDragOver.listen(_onDragOver)
    ]).controller;
    return _onDragOverController.stream;
  }

  StreamController<DragLeaveEvent> _onDragLeaveController;
  Stream<DragLeaveEvent> get onDragLeave {
    _onDragLeaveController ??= new ResponsiveStreamManager<DragLeaveEvent>(() => [
      _dragDropContainer.onDragLeave.listen(_onDragLeave)
    ]).controller;
    return _onDragLeaveController.stream;
  }

  StreamController<DropEvent> _onDropController;
  Stream<DropEvent> get onDrop {
    _onDropController ??= new ResponsiveStreamManager<DropEvent>(() => [
      _dragDropContainer.onDrop.listen(_onDrop)
    ]).controller;
    return _onDropController.stream;
  }

  StreamController<DragEndEvent> _onDragEndController;
  Stream<DragEndEvent> get onDragEnd {
    _onDragEndController ??= new ResponsiveStreamManager<DragEndEvent>(() => [
      _dragDropContainer.onDragEnd.listen(_onDragEnd)
    ]).controller;
    return _onDragEndController.stream;
  }

  DragDropEventManagerImpl(this._elementManager, this._dragDropEventQueue, this._dragDropContainer, this._environment) {
    _dragDropEventQueue.stream.listen(_handleQueuedEvent);
  }

  void attachDragDropManager(DragDropManager manager) {
    if (_dragDropManager != null) {
      throw new ArgumentError.value('Always has attached DragDropManager implementation');
    }
    _dragDropManager = manager;
  }

  void detachDragDropManager() {
    _dragDropManager = null;
  }

  bool hasDragDropManagerAttached() {
    return _dragDropManager != null;
  }

  Element getEventTarget(MouseEvent event) {
    if (event.target is Element) {
      return event.target;
    }
    if (event.target is Text) {
      return (event.target as Text).parent;
    }
    if (_environment.browser.type == BrowserType.IE || _environment.browser.type == BrowserType.Edge) {
      JsObject jsEvent = new JsObject.fromBrowserObject(event);

      if (jsEvent.hasProperty(_MS_IE_JS_EVENT_TARGET_PROPERTY_NAME)) {
        JsObject jsTarget = new JsObject.fromBrowserObject(jsEvent[_MS_IE_JS_EVENT_TARGET_PROPERTY_NAME]);

        if (jsTarget.hasProperty(_MS_IE_JS_PARENT_NODE_PROPERTY_NAME)) {
          JsObject jsParentNode = new JsObject.fromBrowserObject(jsTarget[_MS_IE_JS_PARENT_NODE_PROPERTY_NAME]);

          if (jsParentNode.hasProperty(_MS_IE_JS_CORRESPONDING_ELEMENT_PROPERTY_NAME)) {
            JsObject jsElement = new JsObject.fromBrowserObject(jsParentNode[_MS_IE_JS_CORRESPONDING_ELEMENT_PROPERTY_NAME]);

            if (jsElement.hasProperty(_MS_IE_JS_OWNER_SVG_ELEMENT_PROPERTY_NAME)) {
              return jsElement[_MS_IE_JS_OWNER_SVG_ELEMENT_PROPERTY_NAME];
            }
          }
        }
      }
    }
    return null;
  }

  void _onMouseDown(MouseEvent event) {
    if (event.button == 0) {
      _dragStartElement = getEventTarget(event);

      if (_shouldDeactivateDraggableAncestors(_dragStartElement)) {
        _deactivateDraggableAncestors(_dragStartElement);
        return;
      }

      _dragDropManager?.handleBeforeDragStart(event);
    }
  }

  void _onMouseUp(MouseEvent event) {
    _dragStartElement = null;

    if (_shouldActivateDraggableAncestors()) {
      _activateDraggableAncestors();
      return;
    }

    _dragDropManager?.handleAfterDragEnd(event);
  }

  void _onSelectStart(Event event) {
    Element el = getEventTarget(event);
    if (_elementManager.isInputElement(el)) {
      return;
    }

    while (el != null) {
      if (_elementManager.isElementDraggable(el)) {
        JsObject jsEl = new JsObject.fromBrowserObject(el);
        if (jsEl.hasProperty(_MS_IE_FORCE_DND_METHOD_NAME)) {
          event.preventDefault();
          event.stopImmediatePropagation();
          jsEl.callMethod(_MS_IE_FORCE_DND_METHOD_NAME);
        }
        break;
      }
      el = _elementManager.getParentElement(el);
    }
  }

  void _onDragStart(MouseEvent event) {
    if (_dragStartElement != null && _elementManager.isInputElement(_dragStartElement)) {
      event.preventDefault();
      return;
    }
    _dragDropManager?.handleDragStart(event);
  }

  void _onDragEnter(MouseEvent event) {
    _dragDropManager?.handleDragEnter(event);
  }

  void _onDragOver(MouseEvent event) {
    _dragDropManager?.handleDragOver(event);
  }

  void _onDragLeave(MouseEvent event) {
    _dragDropManager?.handleDragLeave(event);
  }

  void _onDrop(MouseEvent event) {
    _dragDropManager?.handleDrop(event);
  }

  void _onDragEnd(MouseEvent event) {
    _dragDropManager?.handleDragEnd(event);
  }

  void addEvent(BaseDragEvent event) => _dragDropEventQueue.add(event);

  void _handleQueuedEvent(BaseDragEvent event) => _getEventSpecificController(event)?.add(event);

  StreamController<BaseDragEvent> _getEventSpecificController(BaseDragEvent event) {
    if (event is DragStartEvent) {
      return _onDragStartController;
    }
    else if (event is DragEnterEvent) {
      return _onDragEnterController;
    }
    else if (event is DragSpringEnterEvent) {
      return _onDragSpringEnterController;
    }
    else if (event is DragOverEvent) {
      return _onDragOverController;
    }
    else if (event is DragLeaveEvent) {
      return _onDragLeaveController;
    }
    else if (event is DropEvent) {
      return _onDropController;
    }
    else if (event is DragEndEvent) {
      return _onDragEndController;
    }
    return null;
  }

  bool _shouldDeactivateDraggableAncestors(Element startElement) {
    return _deactivateDragOnInputFocusForBrowserTypes.contains(_environment.browser.type) && _elementManager.isInputElement(startElement);
  }

  void _deactivateDraggableAncestors(Element startElement) {
    _deactivatedDraggableElements.addAll(
      _elementManager.makeElementAncestorsNonDraggable(startElement)
    );
  }

  bool _shouldActivateDraggableAncestors() {
    return _deactivatedDraggableElements.isNotEmpty;
  }

  void _activateDraggableAncestors() {
    _deactivatedDraggableElements.forEach((Element el) => _elementManager.makeElementDraggable(el));
    _deactivatedDraggableElements.clear();
  }

  void reset() => _dragDropEventQueue.reset();

}

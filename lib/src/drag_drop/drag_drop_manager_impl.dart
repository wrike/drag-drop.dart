import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:throttle_debounce/throttle_debounce.dart';
import 'package:user_environment/user_environment.dart';

import '../../scroll.dart';
import 'drag_drop_manager.dart';
import 'drag_drop_state.dart';
import 'drag_source.dart';
import 'drop_target.dart';
import 'element_manager.dart';
import 'element_options_reference.dart';
import 'event_manager.dart';
import 'events.dart';
import 'options/drag_options.dart';
import 'options/drop_options.dart';
import 'options/spring_options.dart';
import 'reference_manager.dart';
import 'set_timeout.dart';
import 'simple_data.dart';

class DragDropManagerImpl implements DragDropManager {

  static const String ACCEPTABLE_TARGET_DROP_EFFECT = 'move';
  static const String NON_ACCEPTABLE_TARGET_DROP_EFFECT = 'none';
  static const String PERMITTED_SOURCE_OPERATIONS = 'move';

  static final Duration _SCROLL_THROTTLE_INTERVAL = new Duration(milliseconds: 100);
  static final Duration _MOVEMENT_THROTTLE_INTERVAL = new Duration(milliseconds: 100);
  static final Duration _DRAG_START_DELAY = Duration.ZERO;

  final StreamController<DragDropState> _stateController = new StreamController<DragDropState>.broadcast();
  Stream<DragDropState> get onStateChange => _stateController.stream;

  DragDropState get state => _state;
  DragDropState _state;

  final DragDropReferenceManager _referenceManager;
  final DragDropElementManager _elementManager;
  final DragDropEventManager _eventManager;
  final MovementManager _movementManager;
  final ScrollManager _scrollManager;
  UserEnvironment get _environment => _elementManager.environment;

  Stream<DragStartEvent> get onDragStart => _eventManager.onDragStart;
  Stream<DragEnterEvent> get onDragEnter => _eventManager.onDragEnter;
  Stream<DragSpringEnterEvent> get onDragSpringEnter => _eventManager.onDragSpringEnter;
  Stream<DragOverEvent> get onDragOver  => _eventManager.onDragOver;
  Stream<DragLeaveEvent> get onDragLeave  => _eventManager.onDragLeave;
  Stream<DropEvent> get onDrop => _eventManager.onDrop;
  Stream<DragEndEvent> get onDragEnd => _eventManager.onDragEnd;

  Throttler _scrollThrottler;
  Throttler _movementThrottler;
  Timer _springEnterTargetTimer;

  Element _dragStartElement;

  MovementDetails _lastDragOverMovement;

  bool _skipNativeDragEndEvent = false;
  bool _skipNativeDragEnterEvent = false;
  bool _nativeDragEndTriggered = false;
  bool _nativeDropTriggered = false;

  DragSource _dragSource;
  bool get _hasDragSource => _dragSource != null;

  DropTarget _dropTarget;
  bool get _hasDropTarget => _dropTarget != null;
  bool get _hasAcceptableDropTarget => _dropTarget?.canAccept ?? false;

  MouseEvent _lastDragOverEvent;
  bool get _hasDragOverEvent => _lastDragOverEvent != null;

  DragDropManagerImpl(this._scrollManager, this._elementManager, this._movementManager, this._eventManager, this._referenceManager) {
    _state = new DragDropState((builder) => builder
      ..isDragging = false
      ..isEnabled = true
    );
    _scrollThrottler = new Throttler(_SCROLL_THROTTLE_INTERVAL, _scrollViewByEvent, [], true);
    _movementThrottler = new Throttler(_MOVEMENT_THROTTLE_INTERVAL, _signalDragOverDropTarget, [], true);
    _eventManager.attachDragDropManager(this);
  }

  void _cleanupBeforeDragStart(MouseEvent event) {
    _nativeDragEndTriggered = false;
    _nativeDropTriggered = false;
    event.dataTransfer.effectAllowed = PERMITTED_SOURCE_OPERATIONS;
    _eventManager.reset();
    _setDragging(true);
  }

  void _cleanupAfterDrag() {
    _cancelSpringEnterDropTarget();
    _dragSource = null;
    _dropTarget = null;
    _skipNativeDragEnterEvent = false;
    _skipNativeDragEndEvent = false;
    _lastDragOverEvent = null;
    _lastDragOverMovement = null;
    _referenceManager.reset();
    _scrollManager.reset();
    _movementManager.reset();
    _eventManager.reset();
    _elementManager.reset();
    _setDragging(false);
  }

  void handleBeforeDragStart(MouseEvent event) {
    _dragStartElement = _eventManager.getEventTarget(event);
  }

  void handleDragStart(MouseEvent event) {
    if (!state.isEnabled) {
      event.preventDefault();
      return;
    }
    /// In case of selection there will not be any event.target
    DragDropElementOptionsReference reference =
      _referenceManager.getReferenceForSourceElement(_eventManager.getEventTarget(event), _dragStartElement)
      ?? _referenceManager.getReferenceForSourceElement(_elementManager.getDragSourceElement(_dragStartElement), _dragStartElement)
        ?? _referenceManager.getReferenceForSourceElement(_dragStartElement, _dragStartElement);

    if (reference == null) {
      return;
    }

    if (reference?.isBlocked ?? false) {
      event.preventDefault();
      return;
    }

    DragSource source = _referenceManager.createDragSourceFromReference(reference, _dragStartElement);
    if (!source.options.canDrag(source)) {
      event.preventDefault();
      return;
    }

    event.stopImmediatePropagation();
    _cleanupBeforeDragStart(event);

    Element ghostElement = _initGhostOperations(source, event);
    _dragSource = source.rebuild((b) => b.ghostElement = ghostElement);

    _processEventDetailsAndStartDrag(_dragSource, event);
  }

  Element _initGhostOperations(DragSource source, MouseEvent event) {
    Element ghostElement = _elementManager.createGhostElement(source, event);
    _elementManager.setDragImage(ghostElement, event);
    return ghostElement;
  }

  void _processEventDetailsAndStartDrag(DragSource source, MouseEvent event) {
    _skipNativeDragEnterEvent = true;

    DragDropSimpleData data = new DragDropSimpleData(event.dataTransfer);
    if (_environment.browser.type == BrowserType.Firefox) {
      data.setText('');
    }
    source.options.beforeStart(source, data, event);

    // EDGE https://www.wrike.com/open.htm?id=176893612 bug fix
    if (_environment.browser.type == BrowserType.Edge) {
      setTimeout(allowInterop(() => _handleDragStartAsync(source, event)), _DRAG_START_DELAY.inMilliseconds);
    } else {
      new Timer(_DRAG_START_DELAY, () => _handleDragStartAsync(source, event));
    }
  }


  void _handleDragStartAsync(DragSource source, MouseEvent event) {
    if (_nativeDragEndTriggered) {
      _cleanupAfterDrag();
      return;
    }
    _completeGhostOperationsBeforeDragStarted(source, event);

    _eventManager.addEvent(
      new DragStartEvent(source: source, browserEvent: event)
    );
    _skipNativeDragEnterEvent = false;
    handleDragEnter(event);
  }




void _completeGhostOperationsBeforeDragStarted(DragSource source, MouseEvent event) {
    _elementManager.hideGhostElement();
    _elementManager.decorateDragSource(source);
  }

  void handleDragEnter(MouseEvent event) {
    if (_skipNativeDragEnterEvent) {
      return;
    }
    Element element = _eventManager.getEventTarget(event);
    DragDropElementOptionsReference nextReference = _referenceManager.getReferenceForTargetElement(element, _dragSource, event);
    DragDropElementOptionsReference prevReference;

    if (_hasDropTarget) {
      prevReference = _referenceManager.createReferenceFromDropTarget(_dropTarget);
    }

    bool prevReferenceExists = prevReference != null;
    bool nextReferenceExists = nextReference != null;

    if (!prevReferenceExists || _areReferencesDiffer(prevReference, nextReference)) {

      DragSource refinedSource = _dragSource;
      if (nextReferenceExists) {
        refinedSource = _referenceManager.refineDragSourceOrGetOptionsSpecific(_dragSource, nextReference.options, event);
      }

      _highlightSuitableDropContainers(element, refinedSource);

      if (prevReferenceExists) {
        _leaveDropTarget(event, prevReference);
      }

      if (nextReferenceExists) {
        if (!prevReferenceExists) {
          _cleanupBeforeDragStart(event);
        }
        _enterDropTarget(event, nextReference, refinedSource);
      }
    }

    if (_environment.browser.type == BrowserType.IE || _hasAcceptableDropTarget) {
      event.preventDefault();
    }
  }

  bool _areReferencesDiffer(DragDropElementOptionsReference previous, DragDropElementOptionsReference next) {
    if (previous == null && next != previous) {
      return true;
    }

    if (previous?.container == next?.container && previous?.options == next?.options) {
      if (previous?.target == next?.target || (next?.isBlocked == true && _elementManager.isElementAncestorOf(previous?.target, next?.target, previous?.container))) {
        return false;
      }
    }
    return true;
  }

  void _highlightSuitableDropContainers(Element element, DragSource source) {
    _elementManager.highlightDropContainers(
      _referenceManager.getSuitableDropContainerElements(element, source)
    );
  }

  void _enterDropTarget(MouseEvent event, DragDropElementOptionsReference reference, DragSource source) {
    DropTarget target;

    if (source != null) {
      target = _referenceManager.createDropTargetFromReference(reference);
      bool canAccept = (reference.options as DropOptions).canDrop(source, target);
      target = target.rebuild((builder) => builder.canAccept = canAccept);
      event.dataTransfer.dropEffect = target.canAccept ? ACCEPTABLE_TARGET_DROP_EFFECT : NON_ACCEPTABLE_TARGET_DROP_EFFECT;
      _elementManager.decorateDropTarget(target);

      _lastDragOverEvent ??= event;
      MovementDetails relativeMovement = _getDropTargetRelativeMovement(target);
      _eventManager.addEvent(
        new DragEnterEvent(source: source, target: target, browserEvent: event, movement: relativeMovement)
      );
      _runSpringEnterDropTarget(source, target, event);
    }
    _dragSource = source;
    _dropTarget = target;
  }

  void _runSpringEnterDropTarget(DragSource source, DropTarget target, MouseEvent event) {
    _cancelSpringEnterDropTarget();
    DragSpringOptions springOptions = target.options.provideSpringOptions(source);
    if (springOptions != null) {
      _springEnterTargetTimer = new Timer(springOptions.springEnterDelay, () => _springEnterDropTarget(source, target));
    }
  }

  void _springEnterDropTarget(DragSource source, DropTarget target) {
    _elementManager.decorateSpringDropTarget(target);
    MovementDetails relativeMovement = _getDropTargetRelativeMovement(target);
    _eventManager.addEvent(
      new DragSpringEnterEvent(source: source, target: target, browserEvent: _lastDragOverEvent, movement: relativeMovement)
    );
  }

  void _cancelSpringEnterDropTarget() {
    _springEnterTargetTimer?.cancel();
    _springEnterTargetTimer = null;
  }

  void _leaveDropTarget(MouseEvent event, DragDropElementOptionsReference reference) {
    if (_hasDropTarget) {
      DragSource source = _referenceManager.refineDragSourceOrGetOptionsSpecific(_dragSource, reference.options, event);
      _leaveDropTargetWithSource(event, source);
    }
  }

  void _leaveDropTargetWithSource(MouseEvent event, DragSource source, {beforeEnd: false}) {
    if (_hasDropTarget) {
      _cancelSpringEnterDropTarget();
      _elementManager.clearDropTarget(_dropTarget);
      _eventManager.addEvent(
        new DragLeaveEvent(source: source, target: _dropTarget, browserEvent: event, firedBeforeEnd: beforeEnd)
      );
      _dropTarget = null;
    }
  }

  void handleDragLeave(MouseEvent event) => null;

  void handleDragOver(MouseEvent event) {
    if (_hasDragSource) {

      if (_hasAcceptableDropTarget) {
        event.preventDefault();
      }

      _lastDragOverEvent = event;
      _movementThrottler.throttle();
      _scrollThrottler.throttle();
    }
  }

  void handleDrop(MouseEvent event) {
    if (_hasDragSource && _hasDropTarget) {
      if (_hasAcceptableDropTarget) {
        _handleAcceptableDrop(event);
      } else {
        handleDragEnd(event);
      }
    }
  }

  void _handleAcceptableDrop(MouseEvent event) {
    event.preventDefault();
    _elementManager.moveGhostElementByEvent(event);
    _skipNativeDragEndEvent = true;
    _processAcceptableDropTransition(_dragSource, _dropTarget, event);
  }

  void _processAcceptableDropTransition(DragSource source, DropTarget target, MouseEvent event) {
    DragDropSimpleData data = new DragDropSimpleData(event.dataTransfer);
    target.options.beforeDrop(source, target, data, event).then((_) => _finishAcceptableDrop(source, target, event));
  }

  void _finishAcceptableDrop(DragSource source, DropTarget target, MouseEvent event) {
    _eventManager.addEvent(
      new DropEvent(source: source, target: target, browserEvent: event)
    );
    _nativeDropTriggered = true;
    _skipNativeDragEndEvent = false;
    handleDragEnd(event);
  }

  void handleDragEnd(MouseEvent event) {
    _nativeDragEndTriggered = true;

    if (!_skipNativeDragEndEvent && _hasDragSource) {

      if (!_nativeDropTriggered && _hasDropTarget) {
        _leaveDropTargetWithSource(event, _dragSource, beforeEnd: true);
      }
      _eventManager.addEvent(
        new DragEndEvent(source: _dragSource, target: _dropTarget, browserEvent: event)
      );

      if (_hasDropTarget) {
        _elementManager.clearDropTarget(_dropTarget);
      }
      _elementManager.clearDragSource(_dragSource);
      _cleanupAfterDrag();
    }
  }

  void handleAfterDragEnd(MouseEvent event) {
    _dragStartElement = null;
  }

  void _scrollViewByEvent(_) {
    if (_hasDragOverEvent && state.isDragging) {
      _scrollManager.scrollViewByEvent(_eventManager.getEventTarget(_lastDragOverEvent), _lastDragOverEvent);
    }
  }

  void _signalDragOverDropTarget(_) {
    if (_hasDropTarget && _hasDragOverEvent && state.isDragging) {
      MovementDetails movement = _movementManager.getEventMovementDetails(_lastDragOverEvent);
      if (movement != _lastDragOverMovement) {

        _lastDragOverMovement = movement;
        MovementDetails relativeMovement = _getElementRelativeMovement(_dropTarget.element, movement);
        _eventManager.addEvent(
          new DragOverEvent(source: _dragSource, target: _dropTarget, browserEvent: _lastDragOverEvent, movement: relativeMovement)
        );
      }
    }
  }

  MovementDetails _getDropTargetRelativeMovement(DropTarget target) {
    MovementDetails relativeMovement;
    if (_hasDragOverEvent && state.isDragging) {
      relativeMovement = _getElementRelativeMovement(target.element,
        _movementManager.getEventMovementDetails(_lastDragOverEvent)
      );
    }
    return relativeMovement;
  }

  MovementDetails _getElementRelativeMovement(Element element, MovementDetails movement) {
    return new MovementDetails(
      _elementManager.getElementEventRelativePosition(element, _lastDragOverEvent),
      movement.direction
    );
  }

  void attachDropOptions(Element container, DropOptions options) => _referenceManager.attachDropOptions(container, options);

  void attachDragOptions(Element container, DragOptions options) => _referenceManager.attachDragOptions(container, options);

  void detachDropOptions(Element container, DropOptions options) => _referenceManager.detachDropOptions(container, options);

  void detachDragOptions(Element container, DragOptions options) => _referenceManager.detachDragOptions(container, options);

  void makeElementDroppable(Element element) => _elementManager.makeElementDroppable(element);

  void makeElementDraggable(Element element) => _elementManager.makeElementDraggable(element);

  void makeElementNonDraggable(Element element) => _elementManager.makeElementNonDraggable(element);

  void enable() => _setEnabled(true);

  void disable() => _setEnabled(false);

  void _setEnabled(bool isEnabled) {
    if (state.isEnabled != isEnabled) {
      _setState(_state.rebuild((b) => b.isEnabled = isEnabled));
    }
  }

  void _setDragging(bool isDragging) {
    if (state.isDragging != isDragging) {
      _setState(_state.rebuild((b) => b.isDragging = isDragging));
    }
  }

  void _setState(DragDropState state) {
    _state = state;
    _stateController?.add(_state);
  }

  void destroy() {
    _setEnabled(false);
    _cleanupAfterDrag();
  }
}


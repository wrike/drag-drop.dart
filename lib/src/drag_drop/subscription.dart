import 'dart:html';
import 'dart:async';
import 'drag_drop_manager.dart';
import 'events.dart';
import 'options/base_options.dart';
import 'options/drag_options.dart';
import 'options/drop_options.dart';


class DragDropSubscription {

  static const String NON_DRAGGABLE_ELEMENTS_SELECTOR = 'A,IMG';

  final StreamController<DragStartEvent> _dragStartController = new StreamController<DragStartEvent>.broadcast();
  final StreamController<DragEnterEvent> _dragEnterController = new StreamController<DragEnterEvent>.broadcast();
  final StreamController<DragSpringEnterEvent> _dragSpringEnterController = new StreamController<DragSpringEnterEvent>.broadcast();
  final StreamController<DragOverEvent> _dragOverController = new StreamController<DragOverEvent>.broadcast();
  final StreamController<DragLeaveEvent> _dragLeaveController = new StreamController<DragLeaveEvent>.broadcast();
  final StreamController<DropEvent> _dropController = new StreamController<DropEvent>.broadcast();
  final StreamController<DragEndEvent> _dragEndController = new StreamController<DragEndEvent>.broadcast();

  Stream<DragStartEvent> get onDragStart => _dragStartController.stream;
  Stream<DragEnterEvent> get onDragEnter => _dragEnterController.stream;
  Stream<DragSpringEnterEvent> get onDragSpringEnter => _dragSpringEnterController.stream;
  Stream<DragOverEvent> get onDragOver => _dragOverController.stream;
  Stream<DragLeaveEvent> get onDragLeave => _dragLeaveController.stream;
  Stream<DropEvent> get onDrop => _dropController.stream;
  Stream<DragEndEvent> get onDragEnd => _dragEndController.stream;

  final List<StreamSubscription> _subscriptions = new List<StreamSubscription>();

  final Element element;
  final DragDropManager dragDropManager;

  bool _isEnabled = true;
  BaseDragDropOptions _currentOptions;
  BaseDragDropOptions get options => _currentOptions;

  DragDropSubscription(this.element, BaseDragDropOptions options, this.dragDropManager) {
    setOptions(options);
  }

  void setOptions(BaseDragDropOptions options) {
    if (options != _currentOptions) {
      _detachOptions(_currentOptions);
      _attachOptions(options);
      _currentOptions = options;
    }
    updateView();
  }

  void updateView() {
    if (_currentOptions == null || element == null) {
      return;
    }

    if (_currentOptions.selector == null || _currentOptions.matchElement(element)) {
      _affectMatchedElement(element);
    }

    if (_currentOptions.selector != null) {
      element.querySelectorAll(_currentOptions.selector).forEach(_affectMatchedElement);
    }
  }

  void _affectMatchedElement(Element element) {
    if (_currentOptions is DragOptions) {
      element.querySelectorAll(NON_DRAGGABLE_ELEMENTS_SELECTOR).forEach((Element el) => dragDropManager.makeElementNonDraggable(el));
      dragDropManager.makeElementDraggable(element);
    }
    if (_currentOptions is DropOptions) {
      dragDropManager.makeElementDroppable(element);
    }
  }

  void enable() {
    _isEnabled = true;
  }

  void disable() {
    _isEnabled = false;
  }

  void destroy() {
    disable();
    _detachOptions(_currentOptions);
  }

  void _detachOptions(BaseDragDropOptions options) {
    if (options != null) {
      if (options is DragOptions) {
        dragDropManager.detachDragOptions(element, options);
      }
      if (options is DropOptions) {
        dragDropManager.detachDropOptions(element, options);
      }
    }
    _cancelSubscriptions();
  }

  void _cancelSubscriptions() {
    _subscriptions.forEach((StreamSubscription subscription) => subscription.cancel());
    _subscriptions.clear();
  }

  void _attachOptions(BaseDragDropOptions options) {
    if (options != null) {
      if (options is DragOptions) {
        dragDropManager.attachDragOptions(element, options);
        _subscriptions.addAll([
          dragDropManager.onDragStart.listen(_onDragStart),
          dragDropManager.onDragEnd.listen(_onDragEnd)
        ]);
      }
      if (options is DropOptions) {
        dragDropManager.attachDropOptions(element, options);
        _subscriptions.addAll([
          dragDropManager.onDragEnter.listen(_onDragEnter),
          dragDropManager.onDragSpringEnter.listen(_onDragSpringEnter),
          dragDropManager.onDragOver.listen(_onDragOver),
          dragDropManager.onDragLeave.listen(_onDragLeave),
          dragDropManager.onDrop.listen(_onDrop)
        ]);
      }
    }
  }

  void _onDragStart(DragStartEvent event) => _testDragEvent(event) ? _dragStartController.add(event) : null;
  void _onDragEnter(DragEnterEvent event) => _testDragDropEvent(event) ? _dragEnterController.add(event) : null;
  void _onDragSpringEnter(DragSpringEnterEvent event) => _testDragDropEvent(event) ? _dragSpringEnterController.add(event) : null;
  void _onDragOver(DragOverEvent event) => _testDragDropEvent(event) ? _dragOverController.add(event) : null;
  void _onDragLeave(DragLeaveEvent event) => _testDragDropEvent(event) ? _dragLeaveController.add(event) : null;
  void _onDrop(DropEvent event) => _testDragDropEvent(event) ? _dropController.add(event) : null;
  void _onDragEnd(DragEndEvent event) => _testDragEvent(event) ? _dragEndController.add(event) : null;

  bool _testDragEvent(BaseDragEvent event) {
    return _isEnabled && event.source?.container == element && event.source?.options == _currentOptions;
  }

  bool _testDragDropEvent(BaseDragDropEvent event) {
    return _isEnabled && event.target?.container == element && event.target?.options == _currentOptions;
  }

}

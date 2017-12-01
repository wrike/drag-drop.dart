import 'dart:async';
import 'events.dart';


class DragDropEventQueue<BaseDragEvent> implements StreamController<BaseDragEvent> {

  final List<BaseDragEvent> _events = new List();
  bool _startTriggered = false;
  bool _enterTriggered = false;
  bool _dropTriggered = false;

  Stream<BaseDragEvent> get stream => _controller.stream;
  StreamController<BaseDragEvent> _controller;

  factory DragDropEventQueue.broadcast({void onListen(), void onCancel()}) {
    return new DragDropEventQueue._internal(onListen: onListen, onCancel: onCancel);
  }

  DragDropEventQueue._internal({void onListen(), void onPause(), void onResume(), void onCancel()}) {
    _controller = new StreamController.broadcast(onListen: onListen, onCancel: onCancel, sync: false);
  }

  void addError(Object error, [StackTrace stackTrace]) => _controller.addError(error, stackTrace);
  Future addStream(Stream<BaseDragEvent> source, {bool cancelOnError: true}) => _controller.addStream(source, cancelOnError: cancelOnError);

  ControllerCallback get onListen => _controller.onListen;
  set onListen(void onListenHandler()) => null;
  bool get hasListener => _controller.hasListener;

  ControllerCallback get onPause => _controller.onPause;
  set onPause(void onPauseHandler()) => null;
  bool get isPaused => _controller.isPaused;

  ControllerCallback get onResume => _controller.onResume;
  set onResume(void onResumeHandler()) => null;

  ControllerCancelCallback get onCancel => _controller.onCancel;
  set onCancel(onCancelHandler()) => null;

  Future close() => _controller.close();
  bool get isClosed => _controller.isClosed;

  StreamSink<BaseDragEvent> get sink => _controller.sink;
  Future get done => _controller.done;

  void add(BaseDragEvent event) {
    _events.removeWhere((BaseDragEvent e) => e.runtimeType == event.runtimeType);

    if (event is DragStartEvent) {
      _onDragStartEvent(event);
    }
    else if (event is DragEnterEvent) {
      _onDragEnterEvent(event);
    }
    else if (event is DragSpringEnterEvent) {
      _onDragSpringEnterEvent(event);
    }
    else if (event is DragOverEvent) {
      _onDragOverEvent(event);
    }
    else if (event is DragLeaveEvent) {
      _onDragLeaveEvent(event);
    }
    else if (event is DropEvent) {
      _onDropEvent(event);
    }
    else if (event is DragEndEvent) {
      _onDragEndEvent(event);
    }
  }

  void _onDragStartEvent(DragStartEvent event) {
    if (!_startTriggered) {
      _startTriggered = true;
      _releaseEvent(event as BaseDragEvent);
      _releaseEventQueue();
    }
  }

  void _onDragEnterEvent(DragEnterEvent event) {
    _startTriggered = true;
    _enterTriggered = true;
    _releaseEvent(event as BaseDragEvent);
  }

  void _onDragSpringEnterEvent(DragSpringEnterEvent event) {
    if (_enterTriggered) {
      _releaseEvent(event as BaseDragEvent);
    }
  }

  void _onDragOverEvent(DragOverEvent event) {
    if (_enterTriggered) {
      _releaseEvent(event as BaseDragEvent);
    }
  }

  void _onDragLeaveEvent(DragLeaveEvent event) {
    if (_enterTriggered) {
      _enterTriggered = false;
      _releaseEvent(event as BaseDragEvent);
    }
    else {
      _events.add(event as BaseDragEvent);
    }
  }

  void _onDropEvent(DropEvent event) {
    _dropTriggered = true;
    if (_startTriggered) {
      _releaseEvent(event as BaseDragEvent);
    } else {
      _events.add(event as BaseDragEvent);
    }
  }

  void _onDragEndEvent(DragEndEvent event) {
    if (_startTriggered) {
      _releaseEventQueue();
      _releaseEvent(new DragEndEvent(
        source: event.source,
        target: event.target,
        browserEvent: event.browserEvent,
        firedAfterDrop: _dropTriggered
      ) as BaseDragEvent);
    }
    reset();
  }

  void _releaseEventQueue() {
    for (BaseDragEvent event in _events) {
      _releaseEvent(event);
    }
    _events.clear();
  }

  void _releaseEvent(BaseDragEvent event) => _controller.add(event);

  void reset() {
    _startTriggered = false;
    _enterTriggered = false;
    _dropTriggered = false;
    _events.clear();
  }

}

import 'package:user_environment/user_environment.dart';
import 'package:drag_drop/drag_drop.dart';
import '../../common.dart';

typedef void dragStartListener(DragStartEvent event);
typedef void dragEndListener(DragEndEvent event);
typedef void dragEnterListener(DragEnterEvent event);
typedef void dragSpringEnterListener(DragSpringEnterEvent event);
typedef void dragOverListener(DragOverEvent event);
typedef void dragLeaveListener(DragLeaveEvent event);
typedef void dropListener(DropEvent event);

abstract class DragDropEventReceiver {
  dragStartListener onDragStart(DragStartEvent event);
  dragEndListener onDragEnd(DragEndEvent event);
  dragEnterListener onDragEnter(DragEnterEvent event);
  dragSpringEnterListener onDragSpringEnter(DragSpringEnterEvent event);
  dragOverListener onDragOver(DragOverEvent event);
  dragLeaveListener onDragLeave(DragLeaveEvent event);
  dropListener onDrop(DropEvent event);
}

abstract class BaseDragEventReceiver {
  BaseDragEvent onEvent(BaseDragEvent event);
}

class DragDropEventsBundle {
  final DragStartEvent startEvent;
  final DragEndEvent endEvent;
  final DragEnterEvent enterEvent;
  final DragSpringEnterEvent springEnterEvent;
  final DragOverEvent overEvent;
  final DragLeaveEvent leaveEvent;
  final DropEvent dropEvent;

  DragDropEventsBundle({this.startEvent, this.endEvent, this.enterEvent, this.springEnterEvent, this.overEvent, this.leaveEvent, this.dropEvent});
}

class BaseDragDropOptionsTest extends BaseDragDropOptions {
  BaseDragDropOptionsTest({String selector, ModelProvider provideModel}): super(selector: selector, provideModel: provideModel);
}


class BaseDragDropOptionsMock extends Mock implements BaseDragDropOptions {}
class BaseDragEventMock extends Mock implements BaseDragEvent {}
class BaseDragEventReceiverMock extends Mock implements BaseDragEventReceiver {}
class DragDropElementManagerMock extends Mock implements DragDropElementManager {}
class DragDropEventQueueMock extends Mock implements DragDropEventQueue {}
class DragDropEventReceiverMock extends Mock implements DragDropEventReceiver {}
class DragDropManagerMock extends Mock implements DragDropManager {}
class DragEndEventMock extends Mock implements DragEndEvent {}
class DragEnterEventMock extends Mock implements DragEnterEvent {}
class DragSpringEnterEventMock extends Mock implements DragSpringEnterEvent {}
class DragGhostOptionsMock extends Mock implements DragGhostOptions {}
class DragLeaveEventMock extends Mock implements DragLeaveEvent {}
class DragOptionsMock extends Mock implements DragOptions {}
class DragSpringOptionsMock extends Mock implements DragSpringOptions {}
class DragOverEventMock extends Mock implements DragOverEvent {}
class DragSourceMock extends Mock implements DragSource {}
class DragStartEventMock extends Mock implements DragStartEvent {}
class DropEventMock extends Mock implements DropEvent {}
class DropOptionsMock extends Mock implements DropOptions {}
class DropTargetMock extends Mock implements DropTarget {}
class SimpleStreamSubscriptionMock<T> extends Mock implements StreamSubscription<T> {}
class UserBrowserMock extends Mock implements UserBrowser {}
class UserEnvironmentMock extends Mock implements UserEnvironment {}
class UserPlatformMock extends Mock implements UserPlatform {}
class DragDropContainerMock extends Mock implements DragDropContainer {}
class DragGhostContainerMock extends Mock implements DragGhostContainer {}

class DataTransferMock extends Mock implements DataTransfer {
  final Map<String, String> _data = new Map<String, String>();

  Element dragImage;
  Point dragImagePosition;

  void setDragImage(Element image, int x, int y) {
    dragImage = image;
    dragImagePosition = new Point(x, y);
  }

  void clearData([String format]) {
    if (format == null) {
      _data.clear();
    } else {
      _data.remove(format);
    }
  }

  void setData(String format, String value) {
    _data[ format ] = value;
  }

  String getData(String format) {
    return _data[format];
  }
}


class StreamSubscriptionMock<T> extends Mock implements StreamSubscription<T> {
  StreamMock<T> stream;
  Future cancel() {
    stream?.removeSubscription(this);
    return null;
  }
}


class StreamMock<T> extends Mock implements Stream<T> {
  Set<StreamSubscription<T>> subscriptions = new Set<StreamSubscription<T>>();
  Map<StreamSubscription<T>, Function> listeners = new Map<StreamSubscription<T>, Function>();

  void add(T event) {
    for (Function listener in listeners.values) {
      listener(event);
    }
  }

  bool get hasListener => subscriptions.isNotEmpty;
  StreamSubscription<T> listen(void onData(T event), { Function onError, void onDone(), bool cancelOnError}) {
    StreamSubscriptionMock<T> subscription = new StreamSubscriptionMock<T>();
    subscription.stream = this;
    subscriptions.add(subscription);
    listeners[ subscription ] = onData;
    return subscription;
  }

  void removeSubscription(StreamSubscription<T> subscription) {
    subscriptions.remove(subscription);
    listeners.remove(subscription);
  }
}

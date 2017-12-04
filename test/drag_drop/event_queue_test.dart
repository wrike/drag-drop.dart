@TestOn('browser')

import 'fixture/fixture.dart';


void main() {

  DragLeaveEvent leaveEvent = getDragLeaveEventMock();
  DragStartEvent startEvent = getDragStartEventMock();
  DragEnterEvent enterEvent = getDragEnterEventMock();
  DragEndEvent endEvent = getDragEndEventMock();
  DragOverEvent overEvent = getDragOverEventMock();
  DropEvent dropEvent = getDropEventMock();

  group('DragDropEventQueue add events', () {

    test('DragStartEvent should pass only once', () async {
      DragDropEventQueue queue = getDragDropEventQueue();
      DragDropEventReceiver receiver = getDragDropEventReceiverMock();

      queue.stream.listen((BaseDragEvent event) {
        if (event is DragStartEvent) {
          receiver.onDragStart(event);
        }
      });

      queue.add(startEvent);
      await queueTimeout();

      verify(receiver.onDragStart(startEvent)).called(1);

      DragStartEvent nextStartEvent = getDragStartEventMock();
      queue.add(nextStartEvent);
      await queueTimeout();

      // ignore next DragStartEvents
      verifyNever(receiver.onDragStart(nextStartEvent));
    });

    test('DragEnterEvent can be fired anytime and must not release queued events', () async {
      DragDropEventQueue queue = getDragDropEventQueue();
      DragDropEventReceiver receiver = getDragDropEventReceiverMock();

      queue.stream.listen((BaseDragEvent event) {
        if (event is DragEnterEvent) {
          receiver.onDragEnter(event);
        }
        else if (event is DragLeaveEvent) {
          receiver.onDragLeave(event);
        }
      });

      queue.add(leaveEvent);
      queue.add(enterEvent);
      await queueTimeout();

      verify(receiver.onDragEnter(enterEvent)).called(1);
      verifyNever(receiver.onDragLeave(leaveEvent));
    });

    test('DragLeaveEvent should pass only after DragEnterEvent, otherwise be queued. If passed, drop enterTriggered state', () async {
      DragDropEventQueue queue = getDragDropEventQueue();
      DragDropEventReceiver receiver = getDragDropEventReceiverMock();

      queue.stream.listen((BaseDragEvent event) {
        if (event is DragLeaveEvent) {
          receiver.onDragLeave(event);
        }
      });

      queue.add(leaveEvent);
      await queueTimeout();
      verifyNever(receiver.onDragLeave(leaveEvent));

      queue.add(enterEvent);
      await queueTimeout();

      queue.add(endEvent);
      await queueTimeout();
      verify(receiver.onDragLeave(leaveEvent)).called(1);

      queue.add(leaveEvent);
      await queueTimeout();
      // can't be fired until next enterEvent
      verifyNever(receiver.onDragLeave(leaveEvent));
    });

    test('EventQueue should drop events of the same type on adding new one', () async {
      DragDropEventQueue queue = getDragDropEventQueue();
      DragDropEventReceiver receiver = getDragDropEventReceiverMock();

      queue.stream.listen((BaseDragEvent event) {
        if (event is DragLeaveEvent) {
          receiver.onDragLeave(event);
        }
      });

      queue.add(leaveEvent);
      queue.add(leaveEvent);
      queue.add(enterEvent);

      // release queue
      queue.add(endEvent);
      await queueTimeout();
      verify(receiver.onDragLeave(leaveEvent)).called(1);
    });

    test('DragOverEvent should pass only after DragEnterEvent. It must not be queued', () async {
      DragDropEventQueue queue = getDragDropEventQueue();
      DragDropEventReceiver receiver = getDragDropEventReceiverMock();

      queue.stream.listen((BaseDragEvent event) {
        if (event is DragOverEvent) {
          receiver.onDragOver(event);
        }
      });

      queue.add(overEvent);
      await queueTimeout();
      verifyNever(receiver.onDragOver(overEvent));

      queue.add(enterEvent);
      queue.add(overEvent);
      await queueTimeout();
      verify(receiver.onDragOver(overEvent)).called(1);

      queue.add(leaveEvent);
      queue.add(overEvent);

      // release queue
      queue.add(endEvent);
      verifyNever(receiver.onDragOver(overEvent));
    });

    test('DragEndEvent should pass only after DragEnterEvent or DragStartEvent, but release queued events first. DragEndEvent always has new instance on passing queue. Cannot be queued Must reset queue', () async {
      DragDropEventQueue queue = getDragDropEventQueue();
      DragDropEventReceiver receiver = getDragDropEventReceiverMock();

      queue.stream.listen((BaseDragEvent event) {
        if (event is DragStartEvent) {
          receiver.onDragStart(event);
        }
        else if (event is DragEndEvent) {
          receiver.onDragEnd(event);
        }
        else if (event is DragLeaveEvent) {
          receiver.onDragLeave(event);
        }
      });

      queue.add(endEvent);
      await queueTimeout();
      verifyNever(receiver.onDragEnd(endEvent));

      queue.add(startEvent);
      queue.add(enterEvent);
      queue.add(endEvent);
      await queueTimeout();
      verify(receiver.onDragEnd(any)).called(1);

      // passing endEvent should reset queue
      clearInteractions(receiver);

      queue.add(startEvent);
      queue.add(leaveEvent);
      await queueTimeout();
      verify(receiver.onDragStart(startEvent)).called(1);
      verifyNever(receiver.onDragLeave(leaveEvent));
    });


    test('DropEvent should pass only after DragEnterEvent or DragStartEvent, otherwise be queued, DragStartEvent should release queued events', () async {
      DragDropEventQueue queue = getDragDropEventQueue();
      DragDropEventReceiver receiver = getDragDropEventReceiverMock();

      // verifyInOrder works in a very strange way
      List<BaseDragEvent> releaseOrder = [];

      queue.stream.listen((BaseDragEvent event) {
        if (event is DragStartEvent) {
          releaseOrder.add(event);
          receiver.onDragStart(event);
        }
        else if (event is DropEvent) {
          releaseOrder.add(event);
          receiver.onDrop(event);
        }
      });

      queue.add(dropEvent);
      await queueTimeout();
      verifyNever(receiver.onDrop(dropEvent));

      queue.add(startEvent);
      await queueTimeout();
      verify(receiver.onDrop(dropEvent)).called(1);

      expect(releaseOrder.indexOf(startEvent) < releaseOrder.indexOf(dropEvent), isTrue);

    });

  });


  test('DragDropEventQueue reset', () async {
    DragDropEventQueue queue = getDragDropEventQueue();
    DragDropEventReceiver receiver = getDragDropEventReceiverMock();

    queue.stream.listen((BaseDragEvent event) {
      if (event is DragStartEvent) {
        receiver.onDragStart(event);
      }
      else if (event is DragLeaveEvent) {
        receiver.onDragLeave(event);
      }
      else if (event is DragOverEvent) {
        receiver.onDragOver(event);
      }
    });

    queue.add(startEvent);
    queue.add(enterEvent);
    await queueTimeout();

    queue.reset();
    queue.add(startEvent);
    await queueTimeout();

    verify(receiver.onDragStart(startEvent)).called(2);

    queue.add(overEvent);
    await queueTimeout();
    verifyNever(receiver.onDragOver(overEvent));

    queue.add(leaveEvent);
    await queueTimeout();
    verifyNever(receiver.onDragLeave(leaveEvent));
  });

}

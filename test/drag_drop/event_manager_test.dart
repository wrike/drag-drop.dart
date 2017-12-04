@TestOn('browser')

import 'fixture/fixture.dart';
import 'package:user_environment/user_environment.dart';


void main() {

  test('DragDropElementManager construction. Automatically subscribe to queue\'s stream', () {
    DragDropEventQueue queue = getDragDropEventQueueMock();
    expect(queue.hasListener, isFalse);

    getDragDropEventManager(eventQueue: queue);
    expect(queue.hasListener, isTrue);
  });

  test('DragDropElementManager.reset should reset queue', () {
    DragDropEventQueue queue = getDragDropEventQueueMock();
    DragDropEventManager manager = getDragDropEventManager(eventQueue: queue);
    manager.reset();
    verify(queue.reset()).called(1);
  });

  test('DragDropEventManager should manage attachment of DragDropManager', () {
    DragDropEventManager manager = getDragDropEventManager();

    expect(manager.hasDragDropManagerAttached(), isFalse);

    DragDropManager dragDropManager = getDragDropManagerMock();
    manager.attachDragDropManager(dragDropManager);
    expect(manager.hasDragDropManagerAttached(), isTrue);

    bool errorCaught;
    try {
      manager.attachDragDropManager(dragDropManager);
    }
    on ArgumentError catch (_) {
      errorCaught = true;
    }
    expect(errorCaught, isTrue);

    manager.detachDragDropManager();
    expect(manager.hasDragDropManagerAttached(), isFalse);
  });

  test('DragDropEventManager.addEvent should bypass event to queue', () {
    DragDropEventQueue queue = getDragDropEventQueueMock();
    DragDropEventManager manager = getDragDropEventManager(eventQueue: queue);

    BaseDragEvent event = getBaseDragEventMock();
    manager.addEvent(event);

    verify(queue.add(event)).called(1);
  });

  test('DragDropEventManager.getEventTarget', () {
    MouseEventMock mouseEvent = getEventMock();
    Element targetElement = getElementMock();
    when(mouseEvent.target).thenReturn(targetElement);

    DragDropEventManager manager = getDragDropEventManager();
    expect(manager.getEventTarget(mouseEvent), targetElement);
  });


  group('DragDropEventManager should subscribe to dragDropContainer\'s events responsively', () {

    void testElementResponsiveSubscriptions(Stream managerStream, List<StreamMock> elementStreams) {
      for (StreamMock stream in elementStreams) {
        expect(stream.hasListener, isFalse);
      }

      StreamSubscription subscription = managerStream.listen((event) => null);
      for (StreamMock stream in elementStreams) {
        expect(stream.hasListener, isTrue);
      }

      subscription.cancel();
      for (StreamMock stream in elementStreams) {
        expect(stream.hasListener, isFalse);
      }
    }

    test('onDragStart responsive subscription', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testElementResponsiveSubscriptions(manager.onDragStart, [
        element.onMouseDown as StreamMock,
        element.onMouseUp as StreamMock,
        element.onDragStart as StreamMock
      ]);
    });

    test('onDragStart additional subscription for IE', () {
      /// Used to force dragStart on elements except images and links
      UserEnvironment environment = getUserEnvironmentMock(browser: getUserBrowserMock(BrowserType.IE));
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element, environment: environment);

      testElementResponsiveSubscriptions(manager.onDragStart, [
        element.onSelectStart as StreamMock
      ]);
    });

    test('onDragEnter responsive subscription', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testElementResponsiveSubscriptions(manager.onDragEnter, [
        element.onDragEnter as StreamMock
      ]);
    });

    test('onDragOver responsive subscription', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testElementResponsiveSubscriptions(manager.onDragOver, [
        element.onDragOver as StreamMock
      ]);
    });

    test('onDragLeave responsive subscription', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testElementResponsiveSubscriptions(manager.onDragLeave, [
        element.onDragLeave as StreamMock
      ]);
    });

    test('onDrop responsive subscription', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testElementResponsiveSubscriptions(manager.onDrop, [
        element.onDrop as StreamMock
      ]);
    });

    test('onDragEnd responsive subscription', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testElementResponsiveSubscriptions(manager.onDragEnd, [
        element.onDragEnd as StreamMock
      ]);
    });

  });

  group('DragDropEventManager should pass DOM events to dragDropManager', () {

    void testPassingEventsFromElementToManager(DragDropEventManager manager, Stream managerStream, List<StreamMock> elementStreams, Function testBeforePassing, Function testAfterPassing, [MouseEvent event]) {
      event ??= getEventMock();

      DragDropManager dragDropManager = getDragDropManagerMock();
      manager.attachDragDropManager(dragDropManager);

      for (StreamMock stream in elementStreams) {
        stream.add(event);
      }
      testBeforePassing(dragDropManager, event);

      StreamSubscription subscription = managerStream.listen((event) => null);

      for (StreamMock stream in elementStreams) {
        stream.add(event);
      }
      testAfterPassing(dragDropManager, event);
      subscription.cancel();
    }

    test('Pass onDragEnter', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testPassingEventsFromElementToManager(manager, manager.onDragEnter, [element.onDragEnter as StreamMock],
        (DragDropManager dragDropManager, MouseEvent event) {
          verifyNever(dragDropManager.handleDragEnter(event));
        },
        (DragDropManager dragDropManager, MouseEvent event) {
          verify(dragDropManager.handleDragEnter(event)).called(1);
        }
      );
    });

    test('Pass onDragOver', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testPassingEventsFromElementToManager(manager, manager.onDragOver, [element.onDragOver as StreamMock],
        (DragDropManager dragDropManager, MouseEvent event) {
          verifyNever(dragDropManager.handleDragOver(event));
        },
        (DragDropManager dragDropManager, MouseEvent event) {
          verify(dragDropManager.handleDragOver(event)).called(1);
        }
      );
    });

    test('Pass onDragLeave', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testPassingEventsFromElementToManager(manager, manager.onDragLeave, [element.onDragLeave as StreamMock],
        (DragDropManager dragDropManager, MouseEvent event) {
          verifyNever(dragDropManager.handleDragLeave(event));
        },
        (DragDropManager dragDropManager, MouseEvent event) {
          verify(dragDropManager.handleDragLeave(event)).called(1);
        }
      );
    });

    test('Pass onDrop', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testPassingEventsFromElementToManager(manager, manager.onDrop, [element.onDrop as StreamMock],
        (DragDropManager dragDropManager, MouseEvent event) {
          verifyNever(dragDropManager.handleDrop(event));
        },
        (DragDropManager dragDropManager, MouseEvent event) {
          verify(dragDropManager.handleDrop(event)).called(1);
        }
      );
    });

    test('Pass onDragEnd', () {
      Element element = getElementMockWithStreams();
      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element);

      testPassingEventsFromElementToManager(manager, manager.onDragEnd, [element.onDragEnd as StreamMock],
        (DragDropManager dragDropManager, MouseEvent event) {
          verifyNever(dragDropManager.handleDragEnd(event));
        },
        (DragDropManager dragDropManager, MouseEvent event) {
          verify(dragDropManager.handleDragEnd(event)).called(1);
        }
      );
    });

    test('Pass onDragStart', () {
      Element element = getElementMockWithStreams();
      MouseEvent event = getEventMock(button: LEFT_BUTTON, target: element);

      DragDropElementManagerMock elementManager = getDragDropElementManagerMock();
      when(elementManager.isInputElement(element)).thenReturn(false);

      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element, elementManager: elementManager);

      testPassingEventsFromElementToManager(manager, manager.onDragStart, [
          element.onMouseDown as StreamMock,
          element.onMouseUp as StreamMock,
          element.onDragStart as StreamMock
        ],
        (DragDropManager dragDropManager, MouseEvent event) {
          verifyNever(dragDropManager.handleBeforeDragStart(event));
          verifyNever(dragDropManager.handleAfterDragEnd(event));
          verifyNever(dragDropManager.handleDragStart(event));
        },
        (DragDropManager dragDropManager, MouseEvent event) {
          verify(dragDropManager.handleBeforeDragStart(event)).called(1);
          verify(dragDropManager.handleAfterDragEnd(event)).called(1);
          verify(dragDropManager.handleDragStart(event)).called(1);
        },
        event
      );
    });

    test('Pass onDragStart (addition for IE)', () {
      UserEnvironment environment = getUserEnvironmentMock(browser: getUserBrowserMock(BrowserType.IE));
      Element element = getElementMockWithStreams();
      MouseEvent event = getEventMock(target: element);

      DragDropElementManagerMock elementManager = getDragDropElementManagerMock();

      DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element, elementManager: elementManager, environment: environment);
      DragDropManager dragDropManager = getDragDropManagerMock();
      manager.attachDragDropManager(dragDropManager);

      StreamSubscription subscription = manager.onDragStart.listen((event) => null);

      /// Should do nothing with input elements, no scan, no examinations
      when(elementManager.isInputElement(element)).thenReturn(true);
      (element.onSelectStart as StreamMock).add(event);
      verifyNever(elementManager.getParentElement(element));

      /// For proper exit targetElement should be non-draggable
      /// Believe me, mockito does JsObject.fromBrowserObject(el) very bad

      /// Pretend it is not input, try to determine if element or it's parents are draggable
      when(elementManager.isInputElement(element)).thenReturn(false);
      when(elementManager.getParentElement(element)).thenReturn(null);
      when(elementManager.isElementDraggable(element)).thenReturn(false);
      (element.onSelectStart as StreamMock).add(event);
      verify(elementManager.isElementDraggable(element)).called(1);
      verify(elementManager.getParentElement(element)).called(1);

      subscription.cancel();
    });

  });


  group('Start drag process', () {
    Element element = getElementMockWithStreams();
    MouseEvent event = getEventMock(target: element);
    DragDropElementManagerMock elementManager = getDragDropElementManagerMock();
    UserBrowserMock userBrowser = new UserBrowserMock();
    UserPlatformMock userPlatform = new UserPlatformMock();
    UserEnvironmentMock environment = getUserEnvironmentMock(browser: userBrowser, platform: userPlatform);
    DragDropEventManager manager = getDragDropEventManager(dragDropContainer: element, elementManager: elementManager, environment: environment);
    DragDropManager dragDropManager = getDragDropManagerMock();
    manager.attachDragDropManager(dragDropManager);

    when(userBrowser.type).thenReturn(BrowserType.Chrome);
    when(userPlatform.type).thenReturn(UserPlatformType.Mac);

    void testDraggableInputAncestorsHandling(BrowserType browserType) {
      /// User pressed acceptable (left) mouse button on input element
      /// For Gecko, IE, Edge browsers we must deactivate draggable ancestors
      /// to allow user properly focusIn input element
      StreamSubscription subscription = manager.onDragStart.listen((event) => null);

      when(event.button).thenReturn(LEFT_BUTTON);
      when(userBrowser.type).thenReturn(browserType);
      when(elementManager.isInputElement(element)).thenReturn(true);
      when(elementManager.makeElementAncestorsNonDraggable(element)).thenReturn([element]);

      (element.onMouseDown as StreamMock).add(event);
      verify(elementManager.makeElementAncestorsNonDraggable(element)).called(1);
      verifyNever(dragDropManager.handleDragStart(event));

      /// All draggable ancestors whose were put on hold due to focus
      /// should be turned to draggables again
      (element.onMouseUp as StreamMock).add(event);
      verify(elementManager.makeElementDraggable(element)).called(1);
      verifyNever(dragDropManager.handleAfterDragEnd(event));

      subscription.cancel();
    }

    test('User pressed wrong mouse button', () {
      StreamSubscription subscription = manager.onDragStart.listen((event) => null);

      when(event.button).thenReturn(RIGHT_BUTTON);

      (element.onMouseDown as StreamMock).add(event);
      verifyNever(dragDropManager.handleBeforeDragStart(event));

      (element.onDragStart as StreamMock).add(event);
      verify(dragDropManager.handleDragStart(event)).called(1);

      (element.onMouseUp as StreamMock).add(event);
      verify(dragDropManager.handleAfterDragEnd(event)).called(1);

      subscription.cancel();
    });

    test('User pressed acceptable (left) mouse button on non input element', () {
      StreamSubscription subscription = manager.onDragStart.listen((event) => null);

      when(event.button).thenReturn(LEFT_BUTTON);
      when(elementManager.isInputElement(element)).thenReturn(false);

      (element.onMouseDown as StreamMock).add(event);
      verify(dragDropManager.handleBeforeDragStart(event)).called(1);

      (element.onDragStart as StreamMock).add(event);
      verify(dragDropManager.handleDragStart(event)).called(1);

      (element.onMouseUp as StreamMock).add(event);
      verify(dragDropManager.handleAfterDragEnd(event)).called(1);

      subscription.cancel();
    });

    test('User pressed acceptable (left) mouse button on input element', () {
      StreamSubscription subscription = manager.onDragStart.listen((event) => null);

      when(event.button).thenReturn(LEFT_BUTTON);
      when(elementManager.isInputElement(element)).thenReturn(true);

      (element.onMouseDown as StreamMock).add(event);
      (element.onDragStart as StreamMock).add(event);
      /// Instead of drag-start focus in sourceElement
      verifyNever(dragDropManager.handleDragStart(event));

      subscription.cancel();
    });

    test('User pressed acceptable (left) mouse button on input element in Firefox', () {
      testDraggableInputAncestorsHandling(BrowserType.Firefox);
    });

    test('User pressed acceptable (left) mouse button on input element in IE', () {
      testDraggableInputAncestorsHandling(BrowserType.IE);
    });

    test('User pressed acceptable (left) mouse button on input element in Edge', () {
      testDraggableInputAncestorsHandling(BrowserType.Edge);
    });

  });


  group('Should pass events from queue to their specific streams', () {
    DragDropEventQueue queue = getDragDropEventQueueMock();
    StreamMock queueStream = queue.stream;
    DragDropEventManager manager = getDragDropEventManager(eventQueue: queue);
    BaseDragEventReceiver receiver = getBaseDragEventReceiverMock();

    Future testQueuePassEventsToSpecificManagerStream(event, Stream managerStream) async {
      clearInteractions(receiver);
      managerStream.listen((event) => receiver.onEvent(event as BaseDragEvent));
      queueStream.add(event);
      await queueTimeout();
      verify(receiver.onEvent(event as BaseDragEvent)).called(1);
    }

    test('DragStartEvent', () async {
      await testQueuePassEventsToSpecificManagerStream(getDragStartEventMock(), manager.onDragStart);
    });

    test('DragEnterEvent', () async {
      await testQueuePassEventsToSpecificManagerStream(getDragEnterEventMock(), manager.onDragEnter);
    });

    test('DragOverEvent', () async {
      await testQueuePassEventsToSpecificManagerStream(getDragOverEventMock(), manager.onDragOver);
    });

    test('DragLeaveEvent', () async {
      await testQueuePassEventsToSpecificManagerStream(getDragLeaveEventMock(), manager.onDragLeave);
    });

    test('DragEndEvent', () async {
      await testQueuePassEventsToSpecificManagerStream(getDragEndEventMock(), manager.onDragEnd);
    });

    test('DropEvent', () async {
      await testQueuePassEventsToSpecificManagerStream(getDropEventMock(), manager.onDrop);
    });

  });

}

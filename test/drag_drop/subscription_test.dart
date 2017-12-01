import 'fixture/fixture.dart';


void testStreamMocksHaveSubscriptions(List<Stream> streams, Matcher matcher) {
  for (Stream stream in streams) {
    expect((stream as StreamMock).hasListener, matcher);
  }
}

void testReceiverDidNotGetEvents(DragDropEventReceiver receiver, DragDropEventsBundle events) {
  verifyNever(receiver.onDragStart(events.startEvent));
  verifyNever(receiver.onDragEnd(events.endEvent));
  verifyNever(receiver.onDragEnter(events.enterEvent));
  verifyNever(receiver.onDragSpringEnter(events.springEnterEvent));
  verifyNever(receiver.onDragOver(events.overEvent));
  verifyNever(receiver.onDragLeave(events.leaveEvent));
  verifyNever(receiver.onDrop(events.dropEvent));
}

void testReceiverGotDragEvents(DragDropEventReceiver receiver, DragDropEventsBundle events) {
  verify(receiver.onDragStart(events.startEvent)).called(1);
  verify(receiver.onDragEnd(events.endEvent)).called(1);
}

void testReceiverGotDropEvents(DragDropEventReceiver receiver, DragDropEventsBundle events) {
  verify(receiver.onDragEnter(events.enterEvent)).called(1);
  verify(receiver.onDragSpringEnter(events.springEnterEvent)).called(1);
  verify(receiver.onDragOver(events.overEvent)).called(1);
  verify(receiver.onDragLeave(events.leaveEvent)).called(1);
  verify(receiver.onDrop(events.dropEvent)).called(1);
}


void main() {

  test('DragDropSubscription construction in general', () {
    Element element = getElementMock();
    BaseDragDropOptions options = getBaseDragDropOptions();
    DragDropManager dragDropManager = getDragDropManagerMock();

    DragDropSubscription subscription = getDragDropSubscription(dragDropManager: dragDropManager, element: element, options: options);

    expect(subscription.element, element);
    expect(subscription.dragDropManager, dragDropManager);
    expect(subscription.options, options);
  });


  group('DragDropSubscription should automatically apply given options on creation stage and subscribe to dragDropManager\'s events', () {

    Element element = getElementMock();

    test('DragOptions', () {
      DragOptions options = getDragOptions();
      DragDropManager manager = getDragDropManagerMock();
      List<Stream> streams = [manager.onDragStart, manager.onDragEnd];

      testStreamMocksHaveSubscriptions(streams, isFalse);

      DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element, options: options);

      testStreamMocksHaveSubscriptions(streams, isTrue);
      verify(manager.attachDragOptions(element, options)).called(1);
      verify(manager.makeElementDraggable(element)).called(1);

      subscription.destroy();
    });

    test('DropOptions', () {
      DropOptions options = getDropOptions();
      DragDropManager manager = getDragDropManagerMock();
      List<Stream> streams = [manager.onDragEnter, manager.onDragSpringEnter, manager.onDragOver, manager.onDragLeave, manager.onDrop];

      testStreamMocksHaveSubscriptions(streams, isFalse);

      DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element, options: options);

      verify(manager.attachDropOptions(element, options)).called(1);
      verify(manager.makeElementDroppable(element)).called(1);
      testStreamMocksHaveSubscriptions(streams, isTrue);

      subscription.destroy();
    });

  });


  group('DragDropSubscription should detach options on destroy and clear subscriptions to DragDropManager', () {

    Element element = getElementMock();

    test('DragOptions', () {
      DragOptions options = getDragOptions();
      DragDropManager manager = getDragDropManagerMock();
      DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element, options: options);

      List<Stream> streams = [manager.onDragStart, manager.onDragEnd];
      testStreamMocksHaveSubscriptions(streams, isTrue);

      subscription.destroy();
      verify(manager.detachDragOptions(element, options)).called(1);
      testStreamMocksHaveSubscriptions(streams, isFalse);
    });

    test('DropOptions', () {
      DropOptions options = getDropOptions();
      DragDropManager manager = getDragDropManagerMock();
      DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element, options: options);

      List<Stream> streams = [manager.onDragEnter, manager.onDragSpringEnter, manager.onDragOver, manager.onDragLeave, manager.onDrop];
      testStreamMocksHaveSubscriptions(streams, isTrue);

      subscription.destroy();
      verify(manager.detachDropOptions(element, options)).called(1);
      testStreamMocksHaveSubscriptions(streams, isFalse);
    });

  });


  group('DragDropSubscription.setOptions should properly unset previous options and set new one', () {

    Element element = getElementMock();

    test('DragOptions', () {
      DragOptions options1 = getDragOptions();
      DragDropManager manager = getDragDropManagerMock();
      DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element, options: options1);

      /// No double work
      subscription.setOptions(options1);
      verifyNever(manager.detachDragOptions(element, options1));

      /// Set new options
      clearInteractions(manager);
      DragOptions options2 = getDragOptions();
      subscription.setOptions(options2);

      expect(subscription.options, options2);

      verify(manager.detachDragOptions(element, options1)).called(1);
      verify(manager.attachDragOptions(element, options2)).called(1);

      /// View is updated
      verify(manager.makeElementDraggable(element)).called(1);

      subscription.destroy();
      verify(manager.detachDragOptions(element, options2)).called(1);

      /// Subscriptions are cleared
      List<Stream> streams = [manager.onDragStart, manager.onDragEnd];
      testStreamMocksHaveSubscriptions(streams, isFalse);
    });

    test('DropOptions', () {
      DropOptions options1 = getDropOptions();
      DragDropManager manager = getDragDropManagerMock();
      DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element, options: options1);

      /// No double work
      subscription.setOptions(options1);
      verifyNever(manager.detachDropOptions(element, options1));

      /// Set new options
      clearInteractions(manager);
      DropOptions options2 = getDropOptions();
      subscription.setOptions(options2);

      expect(subscription.options, options2);

      verify(manager.detachDropOptions(element, options1)).called(1);
      verify(manager.attachDropOptions(element, options2)).called(1);

      /// View is updated
      verify(manager.makeElementDroppable(element)).called(1);

      subscription.destroy();
      verify(manager.detachDropOptions(element, options2)).called(1);

      /// Subscriptions are cleared
      List<Stream> streams = [manager.onDragEnter, manager.onDragSpringEnter, manager.onDragOver, manager.onDragLeave, manager.onDrop];
      testStreamMocksHaveSubscriptions(streams, isFalse);
    });

    test('Set to null should clear subscriptions too', () {
      DropOptions options1 = getDropOptions();
      DragDropManager manager = getDragDropManagerMock();
      DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element, options: options1);

      /// Set new options
      clearInteractions(manager);
      DropOptions options2;
      subscription.setOptions(options2);

      expect(subscription.options, options2);

      verify(manager.detachDropOptions(element, options1)).called(1);
      verifyNever(manager.attachDropOptions(element, options2));
      verifyNever(manager.makeElementDroppable(element));

      List<Stream> streams = [manager.onDragEnter, manager.onDragSpringEnter, manager.onDragOver, manager.onDragLeave, manager.onDrop];
      testStreamMocksHaveSubscriptions(streams, isFalse);
    });
  });


  group('DragDropSubscription.updateView should update view depending on options selector', () {

    Element element = getElementMock();
    DragDropManager manager = getDragDropManagerMock();
    DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element);

    Element spanElement = new SpanElement();
    Element imgElement = new ImageElement();
    Element anchorElement = new AnchorElement();
    List<Element> nonDraggableElements = [imgElement, anchorElement];
    List<Element> selectedElements = [imgElement, anchorElement, spanElement];

    const String nonDraggableSelector = DragDropSubscription.NON_DRAGGABLE_ELEMENTS_SELECTOR;
    const String optionsSelector = 'SPAN';

    when(element.matches(optionsSelector)).thenReturn(true);
    when(element.querySelectorAll(nonDraggableSelector)).thenReturn(nonDraggableElements);
    when(element.querySelectorAll(optionsSelector)).thenReturn(selectedElements);

    test('Make container draggable if selector is empty', () {
      subscription.setOptions(getDragOptions());

      verify(manager.makeElementDraggable(element)).called(1);

      /// Try to reset default drag behavior for images and links inside it
      verify(element.querySelectorAll(nonDraggableSelector)).called(1);
      for (Element el in nonDraggableElements) {
        verify(manager.makeElementNonDraggable(el)).called(1);
      }
    });

    test('DragOptions', () {
      subscription.setOptions(getDragOptions(selector: optionsSelector));

      /// Make container draggable if it is matches selector
      verify(manager.makeElementDraggable(element)).called(1);
    });

    test('DropOptions', () {
      clearInteractions(element);
      subscription.setOptions(getDropOptions(selector: optionsSelector));

      /// Make container droppable if it is matches selector
      verify(manager.makeElementDroppable(element)).called(1);

      /// Does not make sense at all
      verifyNever(element.querySelectorAll(nonDraggableSelector));

      /// Then find all children who match selector and make em droppable, even if it is an image or a link
      verify(element.querySelectorAll(optionsSelector)).called(1);
      for (Element el in selectedElements) {
        verify(manager.makeElementDroppable(el)).called(1);
      }
    });

    test('Non matching container', () {
      when(element.matches(optionsSelector)).thenReturn(false);
      subscription.setOptions(getDropOptions(selector: optionsSelector));

      verifyNever(manager.makeElementDroppable(element));
    });
  });


  group('DragDropSubscription should emit events taken from dragDropManager when enabled (by default) or kick ass when disabled', () {
    Element element = getElementMock();
    DragDropManager manager = getDragDropManagerMock();
    DragSpringOptions springOptions = getDragSpringOptionsMock();
    when(springOptions.springEnterDelay).thenReturn(Duration.ZERO);
    DragOptions dragOptions = getDragOptions();
    DropOptions dropOptions = getDropOptions(provideSpringOptions: (DragSource source) => springOptions);
    DragSource source = getDragSourceMock(options: dragOptions, container: element);
    DropTarget target = getDropTargetMock(options: dropOptions, container: element);
    DragDropEventsBundle events = getEventsBundle(source, target);

    Future testDragDropSubscriptionEnableDisableEmitting(DragDropSubscription subscription, Function testReceived) async {
      DragDropEventReceiver receiver = getDragDropEventReceiverMock();
      subscribeReceiverToDragDropSubscription(subscription, receiver);

      addEventsBundleToDragDropManagerStreams(manager, events);
      await queueTimeout();
      testReceived(receiver, events);

      subscription.disable();

      addEventsBundleToDragDropManagerStreams(manager, events);
      await queueTimeout();
      testReceiverDidNotGetEvents(receiver, events);

      subscription.enable();

      addEventsBundleToDragDropManagerStreams(manager, events);
      await queueTimeout();
      testReceived(receiver, events);
    }

    test('DragOptions', () async {
      DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element, options: dragOptions);
      await testDragDropSubscriptionEnableDisableEmitting(subscription, (DragDropEventReceiver receiver, DragDropEventsBundle events) {
        testReceiverGotDragEvents(receiver, events);
      });
    });

    test('DropOptions', () async {
      DragDropSubscription subscription = getDragDropSubscription(dragDropManager: manager, element: element, options: dropOptions);
      await testDragDropSubscriptionEnableDisableEmitting(subscription, (DragDropEventReceiver receiver, DragDropEventsBundle events) {
        testReceiverGotDropEvents(receiver, events);
      });
    });

  });


  group('DragDropSubscription alienate events from dragDropManager if they have another source or option', () {

    Future testDragDropSubscriptionEventsAlienation(DragDropSubscription subscription, Function testReceived) async {
      DragDropEventReceiver receiver = getDragDropEventReceiverMock();
      subscribeReceiverToDragDropSubscription(subscription, receiver);

      Element alienElement = getElementMock();
      DragOptions alienDragOptions = getDragOptions();
      DropOptions alienDropOptions = getDropOptions();

      /// Other options, other container
      DragSource source = getDragSourceMock(options: alienDragOptions, container: alienElement);
      DropTarget target = getDropTargetMock(options: alienDropOptions, container: alienElement);
      DragDropEventsBundle events = getEventsBundle(source, target);
      addEventsBundleToDragDropManagerStreams(subscription.dragDropManager, events);
      await queueTimeout();
      testReceiverDidNotGetEvents(receiver, events);

      /// Same container but still different options
      when(source.container).thenReturn(subscription.element);
      when(target.container).thenReturn(subscription.element);
      events = getEventsBundle(source, target);
      addEventsBundleToDragDropManagerStreams(subscription.dragDropManager, events);
      await queueTimeout();
      testReceiverDidNotGetEvents(receiver, events);

      /// Now it's ok
      if (subscription.options is DragOptions) {
        when(source.options).thenReturn(subscription.options);
      } else {
        when(target.options).thenReturn(subscription.options);
      }
      events = getEventsBundle(source, target);
      addEventsBundleToDragDropManagerStreams(subscription.dragDropManager, events);
      await queueTimeout();
      testReceived(receiver, events);
    }

    test('DragOptions', () async {
      Element element = getElementMock();
      DragDropSubscription subscription = getDragDropSubscription(options: getDragOptions(), element: element);
      await testDragDropSubscriptionEventsAlienation(subscription, (DragDropEventReceiver receiver, DragDropEventsBundle events) {
        testReceiverGotDragEvents(receiver, events);
      });
    });

    test('DropOptions', () async {
      DragDropSubscription subscription = getDragDropSubscription(options: getDropOptions());
      await testDragDropSubscriptionEventsAlienation(subscription, (DragDropEventReceiver receiver, DragDropEventsBundle events) {
        testReceiverGotDropEvents(receiver, events);
      });
    });
  });

}

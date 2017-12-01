import 'fixture/fixture.dart';


void testManagerHasNotActiveAnimations(ScrollManager manager) {
  expect(manager.hasActiveAnimations(), isFalse);
}

void testManagerAndElementAnimationsAreNotActive(ScrollManager manager, Element element) {
  expect(manager.isElementAnimated(element), isFalse);
  testManagerHasNotActiveAnimations(manager);
}

void testManagerAndElementAnimationsAreActive(ScrollManager manager, Element element) {
  expect(manager.isElementAnimated(element), isTrue);
  expect(manager.hasActiveAnimations(), isTrue);
}

void testMovementReactionIsNull(ScrollManager manager, Element element, MovementDetails movement) {
  ScrollAbility reaction = manager.scrollElementByMovement(element, movement);
  expect(reaction, isNull);
  testManagerHasNotActiveAnimations(manager);
}

void testMovementReactionIsZero(ScrollManager manager, Element element, MovementDetails movement) {
  ScrollAbility reaction = manager.scrollElementByMovement(element, movement);
  expect(reaction.nonZero, isFalse);
  testManagerHasNotActiveAnimations(manager);
}

void testScrollReactionAllTrue(ScrollAbility reaction) {
  expect(reaction.horizontal, isTrue);
  expect(reaction.vertical, isTrue);
}

ScrollAbility testElementAnimatedAndGetReaction(ScrollManager manager, Element element, MovementDetails movement) {
  ScrollAbility reaction = manager.scrollElementByMovement(element, movement);
  testManagerAndElementAnimationsAreActive(manager, element);
  return reaction;
}


void main() {

  ScrollManager manager;
  Element element;

  setUp(() {

    manager = ScrollManagerFactory(
      movementManager: getMovementManagerMock(),
      scrollContainer: getScrollContainerMock(),
      scrollOptions: new ScrollOptions()
    );

    element = getElementMock();

  });

  group('ScrollManager.scrollElementByMovement should not scroll element:', () {

    test('Movement does not make sense', () {
      MovementDetails movement = getZeroMovementDetails();

      testMovementReactionIsNull(manager, element, movement);
    });


    group('Element is unable to scroll:', () {

      test('Scroll is unnecessary', () {
        MovementDetails movement = getMovementDetailsMock();

        CssStyleDeclaration style = element.style;
        when(style.overflowX).thenReturn(ELEMENT_STYLE_OVERFLOW_SCROLL);
        when(style.overflowY).thenReturn(ELEMENT_STYLE_OVERFLOW_SCROLL);
        makeElementNonScrollable(element);

        testMovementReactionIsNull(manager, element, movement);

        when(style.overflowX).thenReturn(ELEMENT_STYLE_OVERFLOW_OTHER);
        when(style.overflowY).thenReturn(ELEMENT_STYLE_OVERFLOW_OTHER);
        makeElementScrollable(element);

        testMovementReactionIsNull(manager, element, movement);
      });

      test('Element is scrolled so far in positive directions', () {
        element.scrollLeft = 1;
        element.scrollTop = 1;

        MovementDetails movement = getMovementDetailsMock();

        testMovementReactionIsNull(manager, element, movement);
      });

      test('Element is scrolled to the zero state', () {
        MovementDetails movement = getMovementDetailsMock(direction: getAllNegativeMovementDirection());

        testMovementReactionIsNull(manager, element, movement);
      });

      test('Element is scrolled so far in mixed directions', () {
        element.scrollLeft = 0;
        element.scrollTop = 1;

        MovementDetails movement = getMovementDetailsMock();
        MovementDirection direction = movement.direction;
        when(direction.x).thenReturn(NEGATIVE_MOVEMENT_DIRECTION);
        when(direction.y).thenReturn(POSITIVE_MOVEMENT_DIRECTION);

        testMovementReactionIsNull(manager, element, movement);
      });

    });


    group('Element is able to scroll but cursor not in proper scroll-activation area:', () {

      test('All positive directions', () {
        MovementDetails movement = getMovementDetailsMock();

        testMovementReactionIsZero(manager, element, movement);
      });

      test('All negative directions', () {
        element.scrollLeft = 1;
        element.scrollTop = 1;

        MovementDetails movement = getMovementDetailsMock(direction: getAllNegativeMovementDirection(), position: getElementPositiveMovementTargetPoint(element));

        testMovementReactionIsZero(manager, element, movement);
      });

      test('Mixed directions', () {
        element.scrollLeft = 1;

        MovementDetails movement = getMovementDetailsMock();

        Point position = movement.position;
        when(position.x).thenReturn(element.clientWidth - 1);

        MovementDirection direction = movement.direction;
        when(direction.x).thenReturn(NEGATIVE_MOVEMENT_DIRECTION);

        testMovementReactionIsZero(manager, element, movement);
      });

    });


    group('Element is able to scroll but not in particular direction:', () {

      test('Mixed directions', () {
        when(element.scrollWidth).thenReturn(element.clientWidth);
        element.scrollTop = 1;

        MovementDetails movement = getMovementDetailsMock(position: getElementPositiveMovementTargetPoint(element));

        MovementDirection direction = movement.direction;
        when(direction.y).thenReturn(ZERO_MOVEMENT_DIRECTION);

        testMovementReactionIsNull(manager, element, movement);
      });

    });

  });


  group('ScrollManager.scrollElementByMovement should scroll element:', () {

    test('Element is enable to scroll in positive direction', () async {
      int initialScrollTop = element.scrollTop;
      int initialScrollLeft = element.scrollLeft;

      MovementDetails movement = getMovementDetailsMock(position: getElementPositiveMovementTargetPoint(element));

      ScrollAbility reaction = testElementAnimatedAndGetReaction(manager, element, movement);
      testScrollReactionAllTrue(reaction);

      await passFrameDelay();

      expect(element.scrollLeft > initialScrollLeft, isTrue);
      expect(element.scrollTop > initialScrollTop, isTrue);

      manager.reset();
    });

    test('Element is enable to scroll in negative direction', () async {
      element.scrollTop = 1;
      element.scrollLeft = 1;
      int initialScrollTop = element.scrollTop;
      int initialScrollLeft = element.scrollLeft;

      MovementDetails movement = getMovementDetailsMock(direction: getAllNegativeMovementDirection());

      ScrollAbility reaction = testElementAnimatedAndGetReaction(manager, element, movement);
      testScrollReactionAllTrue(reaction);

      await passFrameDelay();

      expect(element.scrollLeft < initialScrollLeft, isTrue);
      expect(element.scrollTop < initialScrollTop, isTrue);

      manager.reset();
    });

    test('Element is enable to scroll in mixed directions', () async {
      element.scrollLeft = 0;
      element.scrollTop = 1;
      int initialScrollTop = element.scrollTop;
      int initialScrollLeft = element.scrollLeft;

      MovementDetails movement = getMovementDetailsMock();

      Point position = movement.position;
      when(position.x).thenReturn(element.clientWidth - 1);
      when(position.y).thenReturn(1);

      MovementDirection direction = movement.direction;
      when(direction.x).thenReturn(POSITIVE_MOVEMENT_DIRECTION);
      when(direction.y).thenReturn(NEGATIVE_MOVEMENT_DIRECTION);

      ScrollAbility reaction = testElementAnimatedAndGetReaction(manager, element, movement);
      testScrollReactionAllTrue(reaction);

      await passFrameDelay();

      expect(element.scrollLeft > initialScrollLeft, isTrue);
      expect(element.scrollTop < initialScrollTop, isTrue);
    });

    test('Element is enable to scroll in single direction', () async {
      when(element.scrollWidth).thenReturn(element.clientWidth);
      int initialScrollTop = element.scrollTop;
      int initialScrollLeft = element.scrollLeft;

      MovementDetails movement = getMovementDetailsMock(position: getElementPositiveMovementTargetPoint(element));

      ScrollAbility reaction = testElementAnimatedAndGetReaction(manager, element, movement);

      expect(reaction.horizontal, isFalse);
      expect(reaction.vertical, isTrue);

      await passFrameDelay();

      expect(element.scrollLeft, equals(initialScrollLeft));
      expect(element.scrollTop > initialScrollTop, isTrue);

      manager.reset();
    });

  });


  group('Manage animations:', () {

    Element element = getElementMock();

    test('ScrollManager.cancelElementAnimation', () {
      MovementDetails movement = getMovementDetailsMock(position: getElementPositiveMovementTargetPoint(element));

      testElementAnimatedAndGetReaction(manager, element, movement);

      manager.cancelElementAnimation(element);
      testManagerAndElementAnimationsAreNotActive(manager, element);
    });

    test('ScrollManager.reset', () async {
      ScrollManager manager = ScrollManagerFactory(
        movementManager: getMovementManagerMock(),
        scrollContainer: getScrollContainerMock(),
        scrollOptions: new ScrollOptions()
      );

      int clientHeight = 100;
      int clientWidth = 100;

      Element element = getElementMock(
        clientHeight: clientHeight,
        clientWidth: clientWidth,
        scrollHeight: clientHeight * 10,
        scrollWidth: clientWidth * 10
      );

      MovementDetails movement = getMovementDetailsMock(
        position: new Point(clientWidth - 1, clientHeight - 1),
        direction: getMovementDirectionMock()
      );
      manager.scrollElementByMovement(element, movement);
      testManagerAndElementAnimationsAreActive(manager, element);

      manager.reset();
      testManagerAndElementAnimationsAreNotActive(manager, element);
    });

  });


  test('ScrollManager.scrollViewByEvent should get MovementDetails and pass to ScrollManager.scrollViewByMovement', () {
    MouseEvent event = getEventMock();
    MovementDetails movement = getZeroMovementDetails();

    MovementManager movementManager = getMovementManagerMock();
    when(movementManager.getEventMovementDetails(event)).thenReturn(movement);

    ScrollManager manager = ScrollManagerFactory(
      movementManager: movementManager,
      scrollContainer: getScrollContainerMock(),
      scrollOptions: new ScrollOptions()
    );

    manager.scrollViewByEvent(element, event);

    verify(movementManager.getEventMovementDetails(event)).called(1);
  });


  group('ScrollManager.scrollViewByMovement:', () {

    test('Should scroll nothing on zero movement', () {
      MovementDetails movement = getZeroMovementDetails();

      manager.scrollViewByMovement(element, movement);

      testManagerHasNotActiveAnimations(manager);
    });


    test('Should cancel previous animations on new movement', () {
      MovementDetails movement = getMovementDetailsMock(position: getElementPositiveMovementTargetPoint(element));

      // first movement and element
      manager.scrollViewByMovement(element, movement);
      testManagerAndElementAnimationsAreActive(manager, element);

      // same movement, same element
      manager.scrollElementByMovement(element, movement);
      testManagerAndElementAnimationsAreActive(manager, element);

      // next movement
      movement = getZeroMovementDetails();

      manager.scrollViewByMovement(element, movement);
      testManagerHasNotActiveAnimations(manager);

    });

    test('Should cancel previous animations on new element even if movement is the same', () {
      MovementDetails movement = getMovementDetailsMock(position: getElementPositiveMovementTargetPoint(element));

      // first movement and element
      manager.scrollViewByMovement(element, movement);
      testManagerAndElementAnimationsAreActive(manager, element);

      Element prevElement = element;

      // next element
      element = getElementMock();
      manager.scrollViewByMovement(element, movement);
      testManagerAndElementAnimationsAreActive(manager, element);

      expect(manager.isElementAnimated(prevElement), isFalse);
    });


    group('Scroll tree of elements:', () {

      ElementMock prepageStartElement() {
        Element elementB = getElementMock();
        ElementMock elementA = getElementMock(parent: elementB);
        return elementA;
      }

      void scrollViewFromStartElement(ScrollManager manager, Element element) {
        MovementDetails movement = getMovementDetailsMock(position: getElementPositiveMovementTargetPoint(element));
        manager.scrollViewByMovement(element, movement);
      }

      test('If element can be scrolled in both directions, it\'s parent should not be scrolled even if it can be', () {
        Element element = prepageStartElement();

        scrollViewFromStartElement(manager, element);
        testManagerAndElementAnimationsAreActive(manager, element);

        expect(manager.isElementAnimated(element.parent), isFalse);

        manager.reset();
      });

      test('If element can be scrolled in one direction, it\'s parent should be scrolled in another one', () {
        Element element = prepageStartElement();
        when(element.scrollWidth).thenReturn(element.clientWidth);

        scrollViewFromStartElement(manager, element);
        testManagerAndElementAnimationsAreActive(manager, element);

        expect(manager.isElementAnimated(element.parent), isTrue);

        manager.reset();
      });

      test('If element cannot be scrolled, it\'s parent should be scrolled', () {
        Element element = prepageStartElement();
        makeElementNonScrollable(element);

        scrollViewFromStartElement(manager, element);

        expect(manager.isElementAnimated(element), isFalse);
        testManagerAndElementAnimationsAreActive(manager, element.parent);

        manager.reset();
      });

      test('If element is a scrollContainer, it\'s parent should be ignored', () {
        Element element = prepageStartElement();
        makeElementNonScrollable(element);

        ScrollManager manager = ScrollManagerFactory(
          movementManager: getMovementManagerMock(),
          scrollContainer: getScrollContainerMock(element: element),
          scrollOptions: new ScrollOptions()
        );

        scrollViewFromStartElement(manager, element);

        expect(manager.isElementAnimated(element), isFalse);
        expect(manager.isElementAnimated(element.parent), isFalse);
        expect(manager.hasActiveAnimations(), isFalse);

        manager.reset();
      });

    });

    group('ScrollManager.setOptions', () {

      test('Should apply some defaults to options', () {
        ScrollManager manager = ScrollManagerFactory(scrollOptions: null);
        expect(manager.options, isNotNull);
      });

      test('Should allow to specify options on the construction stage', () {
        ScrollOptions options = new ScrollOptions();
        ScrollManager manager = ScrollManagerFactory(scrollOptions: options);
        expect(manager.options, equals(options));
      });

      test('Should allow to set new options', () {
        ScrollOptions options = new ScrollOptions();
        ScrollManager manager = ScrollManagerFactory(scrollOptions: null);
        expect(manager.options, isNot(equals(options)));

        manager.setOptions(options);
        expect(manager.options, equals(options));
      });

      test('Should always have non-null options (mean create default one each time you give it invalid input)', () {
        ScrollManager manager = ScrollManagerFactory();
        ScrollOptions options = manager.options;
        expect(options, isNotNull);

        manager.setOptions(null);
        expect(manager.options, isNotNull);

        expect(manager.options, isNot(equals(options)));
      });

    });
  });

}

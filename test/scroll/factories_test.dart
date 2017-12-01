import 'fixture/fixture.dart';


void main() {

  group('ScrollManagerFactory', () {

    test('Should return new ScrollManager each time', () {
      ScrollManager manager = ScrollManagerFactory();
      expect(manager, isNotNull);
      expect(manager, isNot(equals(ScrollManagerFactory())));
    });

    test('Should properly pass factory params to ScrollManager', () {
      MovementManager movementManager = getMovementManagerMock();
      MovementDetails movement = getMovementDetailsMock();
      MovementDirection direction = getMovementDirectionMock();
      MouseEvent mouseEvent = getEventMock();

      ScrollContainer scrollContainer = getScrollContainerMock(element: new DivElement());

      when(movementManager.getEventMovementDetails(mouseEvent)).thenReturn(movement);
      when(movement.direction).thenReturn(direction);
      when(direction.nonZero).thenReturn(true);

      ScrollManager manager = ScrollManagerFactory(
        movementManager: movementManager,
        scrollContainer: scrollContainer
      );

      expect(manager, isNotNull);

      verify(scrollContainer.element).called(1);

      manager.scrollViewByEvent(new DivElement(), mouseEvent);
      verify(movementManager.getEventMovementDetails(mouseEvent)).called(1);
    });
  });

  group('ScrollContainerFactory', () {

    test('Should return new ScrollContainer each time', () {
      ScrollContainer container = ScrollContainerFactory();
      expect(container, isNotNull);
      expect(container, isNot(equals(ScrollContainerFactory())));
    });

    test('Should use default value', () {
      MovementOptions defaultOptions = new MovementOptions();
      MovementOptions options = MovementOptionsFactory();

      expect(options.minPointerOffsetToDiffer, defaultOptions.minPointerOffsetToDiffer);
    });

  });

  group('ScrollOptionsFactory', () {

    test('Should return new ScrollOptions each time', () {
      ScrollOptions options = ScrollOptionsFactory();
      expect(options, isNotNull);
      expect(options, isNot(equals(ScrollOptionsFactory())));
    });

    test('Should use default value', () {
      ScrollOptions defaultOptions = new ScrollOptions();
      ScrollOptions options = ScrollOptionsFactory();

      expect(options.minScrollAreaSize, defaultOptions.minScrollAreaSize);
      expect(options.maxScrollAreaSize, defaultOptions.maxScrollAreaSize);
      expect(options.maxScrollStep, defaultOptions.maxScrollStep);
      expect(options.animationFrameDuration, defaultOptions.animationFrameDuration);

      expect(options.animationFrameDuration, defaultOptions.animationFrameDuration);
    });

    test('Default values should be correct', () {
      ScrollOptions options = ScrollOptionsFactory();

      expect(options.minScrollAreaSize, lessThan(options.maxScrollAreaSize));
      expect(options.minScrollAreaSize, greaterThan(0));
      expect(options.maxScrollStep, greaterThan(0));
      expect(options.animationFrameDuration, greaterThan(0));
    });

  });
}

@TestOn('browser')

import 'fixture/fixture.dart';


void testMovementDirection(MovementDetails movement, MovementDirection direction) {
  expect(movement.direction.x, equals(direction.x));
  expect(movement.direction.y, equals(direction.y));
}


void main() {

  MouseEvent event;
  MovementManager manager;

  setUp(() {
    event = getEventMock();
    manager = MovementManagerFactory();
  });

  group('MovementManager.getEventMovementDetails', () {

    test('First event always has zero directions', () {
      MovementDetails movement = manager.getEventMovementDetails(event);
      expect(movement.direction.nonZero, isFalse);
    });

    test('Should return new MovementDetails only if position changed significantly', () {
      MovementDetails movement1 = manager.getEventMovementDetails(event);

      when(event.page).thenReturn(getNotFarPoint(movement1.position));
      MovementDetails movement2 = manager.getEventMovementDetails(event);
      expect(movement2, equals(movement1));

      when(event.page).thenReturn(getFarPoint(movement2.position));
      MovementDetails movement3 = manager.getEventMovementDetails(event);
      expect(movement3, isNot(equals(movement2)));

      when(event.page).thenReturn(getPartiallyFarPoint(movement3.position));
      MovementDetails movement4 = manager.getEventMovementDetails(event);
      expect(movement4, isNot(equals(movement3)));
    });

    test('Direction calucaltion', () {
      MovementDetails movement1 = manager.getEventMovementDetails(event);

      when(event.page).thenReturn(getFarPoint(movement1.position));
      MovementDetails movement2 = manager.getEventMovementDetails(event);
      testMovementDirection(movement2, new MovementDirection(MovementDirectionType.positive, MovementDirectionType.positive));

      when(event.page).thenReturn(movement1.position);
      MovementDetails movement3 = manager.getEventMovementDetails(event);
      testMovementDirection(movement3, new MovementDirection(MovementDirectionType.negative, MovementDirectionType.negative));

      when(event.page).thenReturn(getNotFarPoint(movement2.position));
      MovementDetails movement4 = manager.getEventMovementDetails(event);
      testMovementDirection(movement4, movement2.direction);

      when(event.page).thenReturn(new Point(movement4.position.x, -getFarCoordinate(movement4.position.y)));
      MovementDetails movement5 = manager.getEventMovementDetails(event);
      testMovementDirection(movement5, new MovementDirection(MovementDirectionType.zero, MovementDirectionType.negative));
    });
  });

  group('MovementManager.getEventMovementDetails', () {

    test('Should return new MovementDetails after reset event if position did not change significantly', () {
      MovementDetails movement1 = manager.getEventMovementDetails(event);
      MovementDetails movement2 = manager.getEventMovementDetails(event);
      expect(movement2, equals(movement1));

      manager.reset();

      MovementDetails movement3 = manager.getEventMovementDetails(event);
      expect(movement3, isNot(equals(movement2)));
    });
  });

  group('MovementManager.setOptions', () {

    test('Should apply some defaults to options', () {
      MovementManager manager = new MovementManager(null);
      expect(manager.options, isNotNull);
    });

    test('Should allow to specify options on the construction stage', () {
      MovementOptions options = new MovementOptions();
      MovementManager manager = new MovementManager(options);
      expect(manager.options, equals(options));
    });

    test('Should allow to set new options', () {
      MovementOptions options = new MovementOptions();
      MovementManager manager = new MovementManager(null);
      expect(manager.options, isNot(equals(options)));

      manager.setOptions(options);
      expect(manager.options, equals(options));
    });

    test('Should always have non-null options (mean create default one each time you give it invalid input)', () {
      MovementManager manager = new MovementManager(null);
      MovementOptions options = manager.options;
      expect(options, isNotNull);

      manager.setOptions(null);
      expect(manager.options, isNotNull);

      expect(manager.options, isNot(equals(options)));
    });

  });
}

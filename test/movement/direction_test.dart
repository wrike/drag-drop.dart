import 'fixture/fixture.dart';

void main() {

  group('MovementDirection', () {

    test('Should be nonZero if both x and y movements are non-zero', () {
      MovementDirection direction = new MovementDirection(MovementDirectionType.positive, MovementDirectionType.negative);
      expect(direction.nonZero, isTrue);
    });

    test('Should be nonZero if at least one dimension movement was non-zero', () {
      MovementDirection direction = new MovementDirection(MovementDirectionType.zero, MovementDirectionType.positive);
      expect(direction.nonZero, isTrue);
    });

    test('Should be zero if both direction movements are zero', () {
      MovementDirection direction = new MovementDirection(MovementDirectionType.zero, MovementDirectionType.zero);
      expect(direction.nonZero, isFalse);
    });
  });

}

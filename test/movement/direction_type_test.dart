@TestOn('browser')

import 'fixture/fixture.dart';

void main() {

  group('MovementDirection', () {

    test('Negative direction sign', () {
      expect(MovementDirectionType.negative.sign, -1);
    });

    test('Positive direction sign', () {
      expect(MovementDirectionType.positive.sign, 1);
    });

    test('Zero direction sign', () {
      expect(MovementDirectionType.zero.sign, 0);
    });

    test('Should calculate direction by the difference if coordinates', () {
      expect(MovementDirectionType.getByDifference(-100), MovementDirectionType.negative);
      expect(MovementDirectionType.getByDifference(-1), MovementDirectionType.negative);
      expect(MovementDirectionType.getByDifference(0), MovementDirectionType.zero);
      expect(MovementDirectionType.getByDifference(1), MovementDirectionType.positive);
      expect(MovementDirectionType.getByDifference(100), MovementDirectionType.positive);
    });
  });

}

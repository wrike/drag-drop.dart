import 'fixture/fixture.dart';


void main() {

  group('MovementManagerFactory', () {

    test('Should return new MovementManager', () {
      MovementManager manager = MovementManagerFactory();
      expect(manager, isNotNull);
    });
  });

  group('MovementOptionsFactory', () {

    test('Should return new MovementOptions', () {
      MovementOptions options = MovementOptionsFactory();
      expect(options, isNotNull);
    });

    test('Should use default value', () {
      MovementOptions defaultOptions = new MovementOptions();
      MovementOptions options = MovementOptionsFactory();

      expect(options.minPointerOffsetToDiffer, defaultOptions.minPointerOffsetToDiffer);
    });

    test('Default values should be correct', () {
      MovementOptions options = MovementOptionsFactory();

      expect(options.minPointerOffsetToDiffer, greaterThan(0));
    });

  });

}

import 'fixture/fixture.dart';


void main() {

  test('DragSpringOptions construct', () {
    Duration duration = new Duration(seconds: 1);

    DragSpringOptions options = new DragSpringOptions(
      springEnterDelay: duration
    );

    expect(options.springEnterDelay, equals(duration));
  });

  test('DragSpringOptions construct with default value', () {
    DragSpringOptions options = new DragSpringOptions();

    expect(options.springEnterDelay, new isInstanceOf<Duration>());
  });

}

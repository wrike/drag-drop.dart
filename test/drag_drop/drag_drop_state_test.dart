import 'fixture/fixture.dart';
import 'package:quiver/core.dart';


void main() {

  test('DragDropState construct and rebuild', () {

    const bool isDragging = false;
    const bool isEnabled = false;

    DragDropState state = new DragDropState((builder) => builder
      ..isDragging = isDragging
      ..isEnabled = isEnabled
    );

    expect(state.isDragging, isDragging);
    expect(state.isEnabled, isEnabled);

    DragDropState prevState = state;

    state = state.rebuild((b) => b.isDragging = !isDragging);
    expect(state, isNot(prevState));
    expect(state.isDragging, !isDragging);
    expect(state.isEnabled, prevState.isEnabled);
  });

  group('DragDropState serialization', () {

    const bool isDragging = false;
    const bool isEnabled = false;

    DragDropState state = new DragDropState((builder) => builder
      ..isDragging = isDragging
      ..isEnabled = isEnabled
    );
    test('toString', () {
      String toStringValue = 'DragDropState {\n'
        '  isDragging=${state.isDragging.toString()},\n'
        '  isEnabled=${state.isEnabled.toString()},\n'
        '}';
      expect(state.toString(), equals(toStringValue));
    });


    test('hashCode', () {
      int hashCodeValue = hashObjects([state.isDragging, state.isEnabled]);
      expect(state.hashCode, equals(hashCodeValue));
    });
  });

}

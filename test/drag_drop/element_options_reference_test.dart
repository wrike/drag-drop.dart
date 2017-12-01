import 'fixture/fixture.dart';

import 'package:quiver/core.dart';


void main() {

  test('DragDropElementOptionsReference.DragDropElementOptionsReference', () {

    final BaseDragDropOptions options = getBaseDragDropOptions();
    final Element source = new DivElement();
    final Element target = new DivElement();
    final Element container = new DivElement();
    const bool isBlocked = null;

    DragDropElementOptionsReference reference = new DragDropElementOptionsReference((builder) => builder
      ..source = source
      ..target = target
      ..container = container
      ..options = options
    );

    expect(reference.source, source);
    expect(reference.target, target);
    expect(reference.container, container);
    expect(reference.options, options);
    expect(reference.isBlocked, isBlocked);

    DragDropElementOptionsReference prevReference = reference;
    const bool nextIsBlockedValue = false;

    reference = reference.rebuild((b) => b.isBlocked = nextIsBlockedValue);
    expect(reference, isNot(prevReference));
    expect(reference.target, prevReference.target);
    expect(reference.container, prevReference.container);
    expect(reference.options, prevReference.options);
    expect(reference.isBlocked, nextIsBlockedValue);

  });

  group('DragDropElementOptionsReference serialization', () {
    final BaseDragDropOptions options = getBaseDragDropOptions();
    final Element source = new DivElement();
    final Element target = new DivElement();
    final Element container = new DivElement();

    DragDropElementOptionsReference reference = new DragDropElementOptionsReference((builder) => builder
      ..source = source
      ..target = target
      ..container = container
      ..options = options
    );

    test('toString', () {
      String toStringValue = 'DragDropElementOptionsReference {\n'
         '  options=${reference.options.toString()},\n'
         '  source=${reference.source.toString()},\n'
         '  target=${reference.target.toString()},\n'
         '  container=${reference.container.toString()},\n'
         '}';
        expect(reference.toString(), equals(toStringValue));
    });


    test('hashCode', () {
      int hashCodeValue = hashObjects([reference.options, reference.source, reference.target, reference.container, reference.isBlocked]);
      expect(reference.hashCode, equals(hashCodeValue));
    });
  });
}

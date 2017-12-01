import 'fixture/fixture.dart';
import 'package:quiver/core.dart';


void main() {

  test('DropTarget construct and rebuild', () {

    final Element element = getElementMock();
    final Element container = getElementMock();
    final DropOptions options = getDropOptionsMock();

    const int model1 = null;
    const int model2 = 1;

    const bool canAccept1 = null;
    const bool canAccept2 = false;

    DropTarget target = new DropTarget((builder) => builder
      ..element = element
      ..container = container
      ..options = options
    );

    expect(target.element, element);
    expect(target.container, container);
    expect(target.options, options);
    expect(target.model, model1);
    expect(target.canAccept, canAccept1);

    DropTarget prevTarget = target;

    target = target.rebuild((b) => b
      ..model = model2
      ..canAccept = canAccept2
    );

    expect(target, isNot(prevTarget));
    expect(target.element, prevTarget.element);
    expect(target.container, prevTarget.container);
    expect(target.options, prevTarget.options);
    expect(target.model, model2);
    expect(target.canAccept, canAccept2);
  });

  group('DropTarget serialization', () {

    final Element element = getElementMock();
    final Element container = getElementMock();
    final DropOptions options = getDropOptionsMock();

    DropTarget target = new DropTarget((builder) => builder
      ..element = element
      ..container = container
      ..options = options
    );

    test('toString', () {
      String toStringValue = 'DropTarget {\n'
        '  element=${target.element.toString()},\n'
        '  container=${target.container.toString()},\n'
        '  options=${target.options.toString()},\n'
        '}';
      expect(target.toString(), equals(toStringValue));
    });


    test('hashCode', () {
      int hashCodeValue = hashObjects([target.element, target.container, target.options, target.model, target.canAccept]);
      expect(target.hashCode, equals(hashCodeValue));
    });
  });
}

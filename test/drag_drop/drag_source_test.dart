import 'fixture/fixture.dart';
import 'package:quiver/core.dart';


void main() {

  test('DragSource construct and rebuild', () {

    final Element element = getElementMock();
    final Element container = getElementMock();
    final Element ghostElement = getElementMock();
    final Element sourceElement = getElementMock();
    final DragOptions options = getDragOptionsMock();

    const int model1 = null;
    const int model2 = 1;

    DragSource source = new DragSource((builder) => builder
      ..element = element
      ..container = container
      ..options = options
      ..ghostElement = ghostElement
      ..sourceElement = sourceElement
    );

    expect(source.element, element);
    expect(source.container, container);
    expect(source.options, options);
    expect(source.ghostElement, ghostElement);
    expect(source.sourceElement, sourceElement);
    expect(source.model, model1);

    DragSource prevSource = source;

    source = source.rebuild((b) => b.model = model2);
    expect(source, isNot(prevSource));
    expect(source.element, element);
    expect(source.container, container);
    expect(source.options, options);
    expect(source.ghostElement, ghostElement);
    expect(source.sourceElement, sourceElement);
    expect(source.model, model2);

  });

  group('DragSource serialization', () {

    final Element element = getElementMock();
    final Element container = getElementMock();
    final Element ghostElement = getElementMock();
    final Element sourceElement = getElementMock();
    final DragOptions options = getDragOptionsMock();

    DragSource source = new DragSource((builder) => builder
      ..element = element
      ..container = container
      ..options = options
      ..ghostElement = ghostElement
      ..sourceElement = sourceElement
    );

    test('toString', () {
      String toStringValue = 'DragSource {\n'
        '  element=${source.element.toString()},\n'
        '  container=${source.container.toString()},\n'
        '  options=${source.options.toString()},\n'
        '  ghostElement=${source.ghostElement.toString()},\n'
        '  sourceElement=${source.sourceElement.toString()},\n'
        '}';
      expect(source.toString(), equals(toStringValue));
    });


    test('hashCode', () {
      int hashCodeValue = hashObjects([source.element, source.container, source.options, source.model, source.ghostElement, source.sourceElement]);
      expect(source.hashCode, equals(hashCodeValue));
    });
  });
}


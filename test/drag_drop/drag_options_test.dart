import 'fixture/fixture.dart';


void main() {

  final Element divElement = new DivElement();
  final Element anchorElement = new AnchorElement();
  final DragSource dragSource = getDragSourceMock();

  test('DragOptions construct', () {
    expect(getDragOptions(), new isInstanceOf<BaseDragDropOptions>());
  });


  group('DragOptions providing options for drag-ghost', () {

    test('Not providing', () {
      DragOptions options = getDragOptions();

      expect(options.provideGhost(dragSource), isNull);
    });

    test('Providing', () {
      DragGhostOptions ghostOptions = getDragGhostOptionsMock();
      DragOptions options = getDragOptions(provideGhost: (DragSource source) => ghostOptions);

      expect(options.provideGhost(dragSource), ghostOptions);
    });

  });


  group('DragOptions matching drag-handle', () {

    test('Not matching', () {
      DragOptions options = getDragOptions();

      expect(options.matchHandleElement(divElement), isTrue);
      expect(options.matchHandleElement(anchorElement), isTrue);
    });

    test('Matching', () {
      DragOptions options = getDragOptions(handleSelector: 'div');

      expect(options.matchHandleElement(divElement), isTrue);
      expect(options.matchHandleElement(anchorElement), isFalse);
    });

  });


  group('DragOptions handling something before drag actually start', () {

    final DragDropSimpleData simpleData = getDragDropSimpleData();
    final MouseEvent browserEvent = getEventMock();
    const String value = 'Hello';

    test('Not handling', () {
      expect(simpleData.getText(), isNull);

      DragOptions options = getDragOptions();
      options.beforeStart(dragSource, simpleData, browserEvent);

      expect(simpleData.getText(), isNull);
    });

    test('Handling', () {
      DragOptions options = getDragOptions(beforeStart: (DragSource source, DragDropSimpleData data, MouseEvent event) {
        data.setText(value);
      });
      options.beforeStart(dragSource, simpleData, browserEvent);

      expect(simpleData.getText(), value);
    });

  });


  group('DragOptions manage ability to drag', () {

    final DragSource dragSource1 = dragSource;
    final DragSource dragSource2 = getDragSourceMock();

    test('Not managing', () {
      DragOptions options = getDragOptions();

      expect(options.canDrag(dragSource1), isTrue);
      expect(options.canDrag(dragSource2), isTrue);
    });

    test('Handling', () {
      DragOptions options = getDragOptions(canDrag: (DragSource source) => source.element.nodeName == divElement.nodeName);

      when(dragSource1.element).thenReturn(divElement);
      when(dragSource2.element).thenReturn(anchorElement);

      expect(options.canDrag(dragSource1), isTrue);
      expect(options.canDrag(dragSource2), isFalse);
    });

  });
}

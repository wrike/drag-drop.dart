import 'fixture/fixture.dart';


void main() {

  final Element divElement = new DivElement();
  final Element anchorElement = new AnchorElement();

  final DragSource dragSource = getDragSourceMock();
  final DropTarget dropTarget = getDropTargetMock();

  group('DropOptions handling something before drop', () {

    final DragDropSimpleData simpleData = getDragDropSimpleData();
    final MouseEvent browserEvent = getEventMock();

    test('Not handling', () async {
      DropOptions options = getDropOptions();

      dynamic result = await options.beforeDrop(dragSource, dropTarget, simpleData, browserEvent);
      expect(result, isNull);
    });

    test('Handling', () async {
      DropOptions options = getDropOptions(beforeDrop: (DragSource source, DropTarget target, DragDropSimpleData data, MouseEvent event) {
        return new Future.delayed(new Duration(milliseconds: 20), () => divElement);
      });

      dynamic result = await options.beforeDrop(dragSource, dropTarget, simpleData, browserEvent);
      expect(result, divElement);
    });

  });


  group('DropOptions providing model from raw event dataTransfer', () {

    DataTransfer dataTransfer = getDataTransferMock();

    test('Not providing', () {
      DropOptions options = getDropOptions();
      expect(options.provideRawDataModel(dataTransfer), isNull);
    });

    test('Providing', () {
      DropOptions options = getDropOptions(provideRawDataModel: (DataTransfer data) => divElement);
      expect(options.provideRawDataModel(dataTransfer), divElement);
    });

  });


  group('DropOptions providing spring options', () {

    DragSpringOptions springOptions = getDragSpringOptionsMock();

    test('Not providing', () {
      DropOptions options = getDropOptions();
      expect(options.provideSpringOptions(dragSource), isNull);
    });

    test('Providing', () {
      DropOptions options = getDropOptions(provideSpringOptions: (DragSource source) => springOptions);
      expect(options.provideSpringOptions(dragSource), springOptions);
    });

  });

  group('DropOptions manage ability to enter to the container while dragging', () {

    final DragSource dragSource1 = dragSource;
    final DragSource dragSource2 = getDragSourceMock();

    test('Not managing', () {
      DropOptions options = getDropOptions();

      expect(options.canEnter(dragSource1), isTrue);
      expect(options.canEnter(dragSource2), isTrue);
    });

    test('Managing', () {
      DropOptions options = getDropOptions(canEnter: (DragSource source) => source.element.nodeName == divElement.nodeName);

      when(dragSource1.element).thenReturn(divElement);
      when(dragSource2.element).thenReturn(anchorElement);

      expect(options.canEnter(dragSource1), isTrue);
      expect(options.canEnter(dragSource2), isFalse);
    });

  });


  group('DropOptions manage ability to drop', () {

    final DropTarget dropTarget = getDropTargetMock();
    final DragSource dragSource = getDragSourceMock();

    test('Not managing', () {
      DropOptions options = getDropOptions();

      when(dropTarget.model).thenReturn(divElement);
      when(dragSource.model).thenReturn(divElement);
      expect(options.canDrop(dragSource, dropTarget), isFalse);

      when(dragSource.model).thenReturn(anchorElement);
      expect(options.canDrop(dragSource, dropTarget), isTrue);

      when(dragSource.model).thenReturn(null);
      expect(options.canDrop(dragSource, dropTarget), isTrue);

      when(dropTarget.model).thenReturn(null);
      expect(options.canDrop(dragSource, dropTarget), isTrue);

      when(dragSource.model).thenReturn(anchorElement);
      expect(options.canDrop(dragSource, dropTarget), isTrue);
    });

    test('Managing', () {
      final Element spanElement = new SpanElement();

      DropOptions options = getDropOptions(canDrop: (DragSource source, DropTarget target) {
        Element sourceElement = source.model;
        return sourceElement?.nodeName == spanElement.nodeName;
      });

      when(dropTarget.model).thenReturn(spanElement);
      when(dragSource.model).thenReturn(new SpanElement());
      expect(options.canDrop(dragSource, dropTarget), isTrue);

      when(dragSource.model).thenReturn(null);
      expect(options.canDrop(dragSource, dropTarget), isFalse);

      when(dragSource.model).thenReturn(anchorElement);
      expect(options.canDrop(dragSource, dropTarget), isFalse);
    });

  });
}

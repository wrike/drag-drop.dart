import 'fixture/fixture.dart';

void main() {

  group('BaseDragEvent', () {

    test('Event types', () {
      expect(new DragStartEvent(), new isInstanceOf<BaseDragEvent>());
    });

    test('BaseDragEvent creation', () {
      DragSource source = getDragSourceMock();
      MouseEvent browserEvent = getEventMock();

      BaseDragEvent event = new DragStartEvent(source: source, browserEvent: browserEvent);

      expect(event.source, equals(source));
      expect(event.browserEvent, equals(browserEvent));
    });

  });


  group('BaseDragDropEvent', () {

    test('Event types', () {
      expect(new DragEnterEvent(), new isInstanceOf<BaseDragDropEvent>());
      expect(new DragOverEvent(), new isInstanceOf<BaseDragDropEvent>());
      expect(new DragLeaveEvent(), new isInstanceOf<BaseDragDropEvent>());
      expect(new DropEvent(), new isInstanceOf<BaseDragDropEvent>());
      expect(new DragEndEvent(), new isInstanceOf<BaseDragDropEvent>());
    });

    test('BaseDragDropEvent is BaseDragEvent', () {
      expect(new DragEnterEvent(), new isInstanceOf<BaseDragEvent>());
    });

    test('BaseDragDropEvent creation', () {
      DragSource source = getDragSourceMock();
      DropTarget target = getDropTargetMock();
      MouseEvent browserEvent = getEventMock();

      BaseDragDropEvent event = new DragEnterEvent(source: source, target: target, browserEvent: browserEvent);

      expect(event.source, equals(source));
      expect(event.target, equals(target));
      expect(event.browserEvent, equals(browserEvent));
    });

    test('DragEndEvent specific', () {
      DragSource source = getDragSourceMock();
      DropTarget target = getDropTargetMock();
      MouseEvent browserEvent = getEventMock();
      bool firedAfterDrop = false;
      DragEndEvent event = new DragEndEvent(source: source, target: target, browserEvent: browserEvent, firedAfterDrop: firedAfterDrop);

      expect(event.firedAfterDrop, firedAfterDrop);
    });

    test('DragOverEvent specific', () {
      DragSource source = getDragSourceMock();
      DropTarget target = getDropTargetMock();
      MouseEvent browserEvent = getEventMock();
      MovementDetails movement = getMovementDetailsMock();

      DragOverEvent event = new DragOverEvent(source: source, target: target, browserEvent: browserEvent, movement: movement);
      expect(event.movement, equals(movement));
    });

  });

}

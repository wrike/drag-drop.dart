@TestOn('browser')

import 'fixture/fixture.dart';


void main() {

  group('DragDropModelStorage', () {

    final Element element1 = getElementMock();
    final Element element2 = getElementMock();
    final Element element3 = getElementMock();

    final int model1 = 1;
    final int model2 = 2;
    final int model3 = 3;

    void testModelAndRefAttached(DragDropModelStorage storage, Element element, model) {
      expect(storage.getModel(element), model);
    }

    void testModelAndRefDetached(DragDropModelStorage storage, Element element) {
      expect(storage.getModel(element), isNull);
    }

    void testAttachElement(DragDropModelStorage storage, Element element, dynamic model) {
      storage.attach(element, model);
      testModelAndRefAttached(storage, element, model);
    }

    void testDetachElement(DragDropModelStorage storage, Element element) {
      storage.detach(element);
      testModelAndRefDetached(storage, element);
    }


    test('Attach model to element should return it', () {
      DragDropModelStorage storage = getDragDropModelStorage();

      testAttachElement(storage, element1, model1);
      testAttachElement(storage, element2, model2);
      testAttachElement(storage, element1, model3);
    });

    test('Model should be properly detached', () {
      DragDropModelStorage storage = new DragDropModelStorage();

      testAttachElement(storage, element1, model1);
      testAttachElement(storage, element2, model2);
      testDetachElement(storage, element1);

      testModelAndRefAttached(storage, element2, model2);
    });

    test('Detach multiple elements', () {
      DragDropModelStorage storage = new DragDropModelStorage();

      testAttachElement(storage, element1, model1);
      testAttachElement(storage, element2, model2);
      testAttachElement(storage, element3, model3);

      storage.detachElements(<Element>[element1, element2]);
      testModelAndRefDetached(storage, element1);
      testModelAndRefDetached(storage, element2);

      testModelAndRefAttached(storage, element3, model3);
    });

  });

}

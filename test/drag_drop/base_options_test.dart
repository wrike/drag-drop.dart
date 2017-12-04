@TestOn('browser')

import 'fixture/fixture.dart';


void main() {

  Element divElement = new DivElement();
  Element anchorElement = new AnchorElement();

  group('BaseDragOptions matching elements', () {

    test('Not matching', () {
      BaseDragDropOptions options = getBaseDragDropOptions();

      expect(options.matchElement(divElement), isTrue);
      expect(options.matchElement(anchorElement), isTrue);
    });

    test('Matching', () {
      BaseDragDropOptions options = getBaseDragDropOptions(selector: 'div');

      expect(options.matchElement(divElement), isTrue);
      expect(options.matchElement(anchorElement), isFalse);
    });

  });

  group('BaseDragOptions providing model', () {

    test('Not providing', () {
      BaseDragDropOptions options = getBaseDragDropOptions();

      expect(options.provideModel(divElement), isNull);
      expect(options.provideModel(anchorElement), isNull);
    });

    test('Providing', () {
      BaseDragDropOptions options = getBaseDragDropOptions(provideModel: (Element element) => element.nodeName);

      expect(options.provideModel(divElement), divElement.nodeName);
      expect(options.provideModel(anchorElement), anchorElement.nodeName);
    });

  });

}

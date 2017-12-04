@TestOn('browser')

import 'fixture/fixture.dart';


void main() {

  test('DragGhostOptions construct', () {
    Element element = getElementMock();
    Point offset = getPointMock();

    DragGhostOptions options = new DragGhostOptions(element: element, offset: offset);

    expect(options.element, element);
    expect(options.offset, offset);
  });

}

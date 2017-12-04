import 'dart:html';


class DragDropModelStorage {

  final Map<Element, dynamic> _modelByElement = new Map<Element, dynamic>();

  dynamic getModel(Element element) {
    return _modelByElement[element];
  }

  void attach(Element element, dynamic model) {
    _modelByElement[element] = model;
  }

  void detach(Element element) {
    _modelByElement.remove(element);
  }

  void detachElements(Iterable<Element> elements) {
    for (Element element in elements) {
      detach(element);
    }
  }

}

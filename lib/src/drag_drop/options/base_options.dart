import 'dart:html';


typedef dynamic ModelProvider<T>(Element element);

abstract class BaseDragDropOptions {

  final String selector;
  final ModelProvider _provideModel;

  BaseDragDropOptions({this.selector, ModelProvider provideModel}):
    _provideModel = provideModel
  ;

  bool matchElement(Element element) {
    return selector == null ? true : element.matches(selector);
  }

  dynamic provideModel(Element element) {
    return _provideModel == null ? null : _provideModel(element);
  }

}

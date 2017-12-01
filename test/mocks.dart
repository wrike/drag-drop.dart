import 'dart:html';
import 'package:mockito/mockito.dart';

class ElementMock extends Mock implements Element {
  int scrollLeft = 0;
  int scrollTop = 0;
}

class CssStyleDeclarationMock extends Mock implements CssStyleDeclaration {
  String scrollBehaviour;
}

class CssClassSetMock extends Mock implements CssClassSet {
  final Set<String> _classes = new Set<String>();

  bool frozen = false;
  bool toggle(String value, [bool shouldAdd]) => false;
  bool contains(Object value) => _classes.contains(value);
  bool add(String value) => _classes.add(value);
  bool remove(Object value) => _classes.remove(value);
  void addAll(Iterable<String> iterable) => _classes.addAll(iterable);
  void removeAll(Iterable<Object> iterable) => _classes.removeAll(iterable);
  void toggleAll(Iterable<String> iterable, [bool shouldAdd]) => null;
}

class MouseEventMock extends Mock implements MouseEvent {
}

class PointMock extends Mock implements Point {
}

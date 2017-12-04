@TestOn('browser')

import 'dart:async';
import 'dart:html';
import 'package:mockito/mockito.dart';
import 'mocks.dart';
import 'package:test/test.dart';

const int ELEMENT_WIDTH = 120;
const int ELEMENT_HEIGHT = 120;
const String ELEMENT_STYLE_OVERFLOW_AUTO = 'auto';
const String ELEMENT_STYLE_OVERFLOW_SCROLL = 'scroll';
const String ELEMENT_STYLE_OVERFLOW_OTHER = 'hidden';
const int ELEMENT_SCROLL_OFFSET = 0;
const int ZERO_POSITION = 0;
const int ZERO_ELEMENT_SIZE = 0;

final MILLISECONDS_PER_FRAME = (1000 / 60).ceil();
final DOUBLE_FRAME_DURATION = new Duration(milliseconds: MILLISECONDS_PER_FRAME * 2);

Future passFrameDelay() {
  return new Future.delayed(DOUBLE_FRAME_DURATION);
}

Element getElementMock({CssClassSet classes, CssStyleDeclaration style, Element parent, Node parentNode, int clientHeight, int clientWidth, int scrollWidth, int scrollHeight, int scrollLeft, int scrollTop, int offsetTop, int offsetLeft, Rectangle<num> rectangle}) {
  Element element = new ElementMock();

  style ??= getElementStyleMock();
  when(element.style).thenReturn(style);
  when(element.getComputedStyle()).thenReturn(style);

  classes ??= getCssClassSetMock();
  when(element.classes).thenReturn(classes);

  when(element.clientHeight).thenReturn(clientHeight ?? ELEMENT_HEIGHT);
  when(element.clientWidth).thenReturn(clientWidth ?? ELEMENT_WIDTH);
  element.scrollLeft = scrollLeft ?? ELEMENT_SCROLL_OFFSET;
  element.scrollTop = scrollTop ?? ELEMENT_SCROLL_OFFSET;

  when(element.parent).thenReturn(parent);
  when(element.parentNode).thenReturn(parentNode);

  when(element.offsetLeft).thenReturn(offsetLeft ?? ZERO_POSITION);
  when(element.offsetTop).thenReturn(offsetTop ?? ZERO_POSITION);
  when(element.scrollWidth).thenReturn(scrollWidth ?? (element.clientWidth + 1));
  when(element.scrollHeight).thenReturn(scrollHeight ?? (element.clientHeight + 1));

  when(element.querySelectorAll(any)).thenReturn([]);

  rectangle ??= new Rectangle<num>(
    element.offsetTop ?? ZERO_POSITION,
    element.offsetLeft ?? ZERO_POSITION,
    element.clientWidth ?? ZERO_ELEMENT_SIZE,
    element.clientHeight ?? ZERO_ELEMENT_SIZE
  );
  when(element.getBoundingClientRect()).thenReturn(rectangle);

  return element;
}

CssStyleDeclaration getElementStyleMock({String overflowX: ELEMENT_STYLE_OVERFLOW_AUTO, String overflowY: ELEMENT_STYLE_OVERFLOW_AUTO}) {
  CssStyleDeclaration style = new CssStyleDeclarationMock();
  when(style.overflowX).thenReturn(overflowX);
  when(style.overflowY).thenReturn(overflowY);
  return style;
}

CssClassSetMock getCssClassSetMock() {
  return new CssClassSetMock();
}

MouseEvent getEventMock({Point position, Element target, int button}) {
  MouseEvent event = new MouseEventMock();
  position ??= getPointMock();
  target ??= getElementMock();
  button ??= 0;
  when(event.page).thenReturn(position);
  when(event.target).thenReturn(target);
  when(event.button).thenReturn(button);
  return event;
}

Point getPointMock([int x = ZERO_POSITION + 1, int y = ZERO_POSITION + 1]) {
  Point point = new PointMock();
  when(point.x).thenReturn(x);
  when(point.y).thenReturn(y);
  return point;
}

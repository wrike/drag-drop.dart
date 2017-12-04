@TestOn('browser')

import 'package:drag_drop/scroll.dart';
import 'package:drag_drop/movement.dart';
import '../../movement/fixture/fixture.dart';
import '../../common.dart';
import 'mocks.dart';


final MovementDirectionType NEGATIVE_MOVEMENT_DIRECTION = MovementDirectionType.negative;
final MovementDirectionType POSITIVE_MOVEMENT_DIRECTION = MovementDirectionType.positive;
final MovementDirectionType ZERO_MOVEMENT_DIRECTION = MovementDirectionType.zero;


void setElementScroll(Element element, {int x, int y}) {
  element.scrollLeft ??= x;
  element.scrollTop ??= y;
}

void makeElementNonScrollable(ElementMock element) {
  when(element.scrollWidth).thenReturn(element.clientWidth);
  when(element.scrollHeight).thenReturn(element.clientHeight);
}

void makeElementScrollable(ElementMock element) {
  when(element.scrollWidth).thenReturn(element.clientWidth + 1);
  when(element.scrollHeight).thenReturn(element.clientHeight + 1);
}

Point getElementPositiveMovementTargetPoint(Element element) =>
  getPointMock(element.clientWidth - 1, element.clientHeight - 1);


Point getElementNegativeMovementTargetPoint(Element element) =>
  getPointMock(element.offsetLeft + 1, element.offsetTop + 1);


MovementDirection getAllNegativeMovementDirection() =>
  getMovementDirectionMock(x: NEGATIVE_MOVEMENT_DIRECTION, y: NEGATIVE_MOVEMENT_DIRECTION);


MovementDirection getZeroMovementDirection() =>
  getMovementDirectionMock(x: ZERO_MOVEMENT_DIRECTION, y: ZERO_MOVEMENT_DIRECTION, nonZero: false);


MovementDetails getZeroMovementDetails({Point position}) =>
  getMovementDetailsMock(direction: getZeroMovementDirection(), position: position);


MovementDirection getMovementDirectionMock({MovementDirectionType x, MovementDirectionType y, bool nonZero: true}) {
  MovementDirection direction = new MovementDirectionMock();
  when(direction.x).thenReturn(x ?? POSITIVE_MOVEMENT_DIRECTION);
  when(direction.y).thenReturn(y ?? POSITIVE_MOVEMENT_DIRECTION);
  when(direction.nonZero).thenReturn(nonZero);
  return direction;
}

MovementDetails getMovementDetailsMock({Point position, MovementDirection direction}) {
  MovementDetailsMock details = new MovementDetailsMock();
  position ??= getPointMock();
  direction ??= getMovementDirectionMock();
  when(details.position).thenReturn(position);
  when(details.direction).thenReturn(direction);
  return details;
}

MovementManagerMock getMovementManagerMock() =>
  new MovementManagerMock();


ScrollContainer getScrollContainerMock({Element element}) {
  ScrollContainerMock container = new ScrollContainerMock();
  element ??= getElementMock();
  when(container.element).thenReturn(element);
  return container;
}

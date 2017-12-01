import 'package:drag_drop/movement.dart';
import '../../common.dart';


final int MIN_POINTER_OFFSET_TO_DIFFER = new MovementOptions().minPointerOffsetToDiffer;


Point getPoint([int x = ZERO_POSITION, int y = ZERO_POSITION]) =>
  new Point(x, y);


num getFarCoordinate(num coord) =>
  coord + MIN_POINTER_OFFSET_TO_DIFFER + 1;


num getNotFarCoordinate(num coord) =>
  coord + MIN_POINTER_OFFSET_TO_DIFFER - 1;


Point getFarPoint(Point fromPoint) =>
  new Point(
    getFarCoordinate(fromPoint.x),
    getFarCoordinate(fromPoint.y)
  );


Point getNotFarPoint(Point fromPoint) =>
  new Point(
    getNotFarCoordinate(fromPoint.x),
    getNotFarCoordinate(fromPoint.y)
  );


Point getPartiallyFarPoint(Point fromPoint) =>
  new Point(
    getNotFarCoordinate(fromPoint.x),
    getFarCoordinate(fromPoint.y)
  );


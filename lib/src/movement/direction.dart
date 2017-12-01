import 'direction_type.dart';


class MovementDirection {

  final MovementDirectionType x;
  final MovementDirectionType y;

  bool get nonZero => x != MovementDirectionType.zero || y != MovementDirectionType.zero;

  MovementDirection(this.x, this.y);
}

class MovementDirectionType {

  final int sign;

  static final MovementDirectionType negative = new MovementDirectionType._(-1);
  static final MovementDirectionType positive = new MovementDirectionType._(1);
  static final MovementDirectionType zero = new MovementDirectionType._(0);

  MovementDirectionType._(this.sign);

  static MovementDirectionType getByDifference(num difference) {
    if (difference > 0) {
      return positive;
    }
    else if (difference < 0) {
      return negative;
    }
    return zero;
  }

}

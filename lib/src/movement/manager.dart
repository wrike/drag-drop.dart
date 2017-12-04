import 'dart:html';
import 'details.dart';
import 'direction_type.dart';
import 'direction.dart';
import 'options.dart';


class MovementManager {

  MovementDetails _lastMovement;
  MovementOptions _options;
  MovementOptions get options => _options;

  MovementManager(MovementOptions options) {
    setOptions(options);
  }

  void setOptions(MovementOptions options) {
    _options = options ?? new MovementOptions();
  }

  MovementDetails getEventMovementDetails(MouseEvent event) {
    MovementDirection direction;
    if (_lastMovement == null) {
      direction = new MovementDirection(MovementDirectionType.zero, MovementDirectionType.zero);
    }
    else if (_wasPositionChanged(event.page)) {
      direction = _getDirectionToPosition(event.page);
    }
    if (direction != null) {
      _lastMovement = new MovementDetails(event.page, direction);
    }

    return _lastMovement;
  }

  bool _wasPositionChanged(Point position) {
    return _areCoordinatesDiffer(position.x, _lastMovement.position.x) ||
      _areCoordinatesDiffer(position.y, _lastMovement.position.y);
  }

  bool _areCoordinatesDiffer(num x1, num x2) {
    return (x1 - x2).abs() > _options.minPointerOffsetToDiffer;
  }

  MovementDirection _getDirectionToPosition(Point position) {
    return new MovementDirection(
      MovementDirectionType.getByDifference(position.x - _lastMovement.position.x),
      MovementDirectionType.getByDifference(position.y - _lastMovement.position.y)
    );
  }

  void reset() {
    _lastMovement = null;
  }
}

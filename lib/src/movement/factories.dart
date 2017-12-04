import 'manager.dart';
import 'options.dart';


MovementManager MovementManagerFactory({
  MovementOptions movementOptions
}) {
  return new MovementManager(movementOptions);
}

MovementOptions MovementOptionsFactory() {
  return new MovementOptions();
}

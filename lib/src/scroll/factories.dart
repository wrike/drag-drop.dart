import '../../movement.dart';
import 'container.dart';
import 'manager.dart';
import 'options.dart';


ScrollManager ScrollManagerFactory({
  MovementManager movementManager,
  ScrollContainer scrollContainer,
  ScrollOptions scrollOptions
}) {
  movementManager ??= MovementManagerFactory();
  scrollContainer ??= new ScrollContainer();

  return new ScrollManager(movementManager, scrollContainer.element, scrollOptions);
}

ScrollContainer ScrollContainerFactory() {
  return new ScrollContainer();
}

ScrollOptions ScrollOptionsFactory() {
  return new ScrollOptions();
}

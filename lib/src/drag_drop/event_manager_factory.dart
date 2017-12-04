import 'package:user_environment/user_environment.dart';
import 'drag_drop_container.dart';
import 'element_manager.dart';
import 'element_manager_factory.dart';
import 'event_manager.dart';
import 'event_manager_impl.dart';
import 'event_queue.dart';
import 'factories.dart';


DragDropEventManager DragDropEventManagerFactory({
  UserEnvironment environment,
  DragDropElementManager elementManager,
  DragDropContainer dragDropContainer,
  DragDropEventQueue eventQueue
}) {
  environment ??= UserEnvironmentFactory();
  dragDropContainer ??= DragDropContainerFactory();
  elementManager ??= DragDropElementManagerFactory(dragDropContainer: dragDropContainer, environment: environment);
  eventQueue ??= DragDropEventQueueFactory();

  return new DragDropEventManagerImpl(elementManager, eventQueue, dragDropContainer.element, environment);
}

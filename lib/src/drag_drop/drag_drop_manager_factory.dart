import 'package:user_environment/user_environment.dart';

import '../../movement.dart';
import '../../scroll.dart';
import 'drag_drop_container.dart';
import 'drag_drop_manager.dart';
import 'drag_drop_manager_impl.dart';
import 'drag_ghost_container.dart';
import 'element_manager.dart';
import 'element_manager_factory.dart';
import 'event_manager.dart';
import 'event_manager_factory.dart';
import 'factories.dart';
import 'model_storage.dart';
import 'reference_manager.dart';
import 'reference_manager_factory.dart';


DragDropManager DragDropManagerFactory({
  ScrollManager scrollManager,
  DragDropElementManager elementManager,
  MovementManager movementManager,
  DragDropEventManager eventMananger,
  DragDropReferenceManager referenceManager,
  DragDropContainer dragDropContainer,
  DragGhostContainer ghostContainer,
  UserEnvironment environment,
  DragDropModelStorage modelStorage
}) {
  modelStorage ??= DragDropModelStorageFactory();
  dragDropContainer ??= DragDropContainerFactory();
  ghostContainer ??= DragGhostContainerFactory();
  environment ??= UserEnvironmentFactory();
  movementManager ??= MovementManagerFactory();
  scrollManager ??= ScrollManagerFactory(movementManager: movementManager);
  elementManager ??= DragDropElementManagerFactory(dragDropContainer: dragDropContainer, ghostContainer: ghostContainer);
  referenceManager ??= DragDropReferenceManagerFactory(elementManager: elementManager, modelStorage: modelStorage);
  eventMananger ??= DragDropEventManagerFactory(environment: environment, elementManager: elementManager, dragDropContainer: dragDropContainer);

  return new DragDropManagerImpl(scrollManager, elementManager, movementManager, eventMananger, referenceManager);
}

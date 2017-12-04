import 'drag_drop_container.dart';
import 'drag_drop_manager.dart';
import 'drag_ghost_container.dart';
import 'event_queue.dart';
import 'model_storage.dart';
import 'subscription_factory.dart';


DragDropSubscriptionFactory DragDropSubscriptionFactoryFactory({
  DragDropManager dragDropManager
}) {
  return new DragDropSubscriptionFactory(dragDropManager);
}

DragDropContainer DragDropContainerFactory() {
  return new DragDropContainer();
}

DragGhostContainer DragGhostContainerFactory() {
  return new DragGhostContainer();
}

DragDropModelStorage DragDropModelStorageFactory() {
  return new DragDropModelStorage();
}

DragDropEventQueue DragDropEventQueueFactory() {
  return new DragDropEventQueue.broadcast();
}

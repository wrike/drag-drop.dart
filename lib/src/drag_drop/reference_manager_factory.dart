import 'element_manager.dart';
import 'element_manager_factory.dart';
import 'factories.dart';
import 'model_storage.dart';
import 'reference_manager.dart';
import 'reference_manager_impl.dart';


DragDropReferenceManager DragDropReferenceManagerFactory({
  DragDropElementManager elementManager,
  DragDropModelStorage modelStorage
}) {
  return new DragDropReferenceManagerImpl(
    elementManager ??= DragDropElementManagerFactory(),
    modelStorage ??= DragDropModelStorageFactory()
  );
}

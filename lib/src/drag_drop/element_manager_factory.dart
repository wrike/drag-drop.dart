import 'package:user_environment/user_environment.dart';
import 'drag_drop_container.dart';
import 'drag_ghost_container.dart';
import 'element_manager.dart';
import 'element_manager_impl.dart';
import 'factories.dart';


DragDropElementManager DragDropElementManagerFactory({
  DragDropContainer dragDropContainer,
  DragGhostContainer ghostContainer,
  UserEnvironment environment
}) {
  return new DragDropElementManagerImpl(
    (dragDropContainer ??= DragDropContainerFactory()).element,
    (ghostContainer ??= DragGhostContainerFactory()).element,
    environment ??= UserEnvironmentFactory()
  );
}

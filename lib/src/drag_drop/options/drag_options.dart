import 'dart:html';
import '../drag_source.dart';
import '../simple_data.dart';
import 'base_options.dart';
import 'ghost_options.dart';


typedef bool CanDragHandler(DragSource source);
typedef void BeforeDragStartHandler(DragSource source, DragDropSimpleData data, MouseEvent event);
typedef DragGhostOptions GhostOptionsProvider(DragSource source);

class DragOptions extends BaseDragDropOptions {

  final CanDragHandler _canDrag;
  final BeforeDragStartHandler _beforeStart;
  final GhostOptionsProvider _provideGhost;
  final String _handleSelector;

  DragOptions({
    String selector,
    String handleSelector,
    ModelProvider provideModel,
    GhostOptionsProvider provideGhost,
    BeforeDragStartHandler beforeStart,
    CanDragHandler canDrag
  }):

    _canDrag = canDrag,
    _beforeStart = beforeStart,
    _provideGhost = provideGhost,
    _handleSelector = handleSelector,

  super(
    selector: selector,
    provideModel: provideModel
  );

  void beforeStart(DragSource source, DragDropSimpleData data, MouseEvent event) {
    if (_beforeStart != null) {
      _beforeStart(source, data, event);
    }
  }

  bool matchHandleElement(Element element) {
    return _handleSelector == null || element.matches(_handleSelector);
  }

  bool canDrag(DragSource source) {
    return _canDrag == null || _canDrag(source);
  }

  DragGhostOptions provideGhost(DragSource source) {
    return _provideGhost == null ? null : _provideGhost(source);
  }
}



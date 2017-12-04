import 'dart:html';
import 'drag_drop_manager.dart';
import 'options/base_options.dart';
import 'subscription.dart';


class DragDropSubscriptionFactory {

  final DragDropManager _dragDropManager;

  DragDropSubscriptionFactory(this._dragDropManager);

  DragDropSubscription getSubscription(Element element, BaseDragDropOptions options) {
    return new DragDropSubscription(element, options, _dragDropManager);
  }
}

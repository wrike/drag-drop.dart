import 'dart:async';


typedef List<StreamSubscription> SubscriptionsProvider();

class ResponsiveStreamManager<T> {

  final List<StreamSubscription> _subscriptions = <StreamSubscription>[];
  StreamController<T> _controller;
  StreamController<T> get controller => _controller;

  ResponsiveStreamManager([SubscriptionsProvider provide]) {
    _controller = new StreamController<T>.broadcast(
      onListen: () {
        if (provide != null) {
          _subscriptions.addAll(provide());
        }
      },
      onCancel: () {
        _subscriptions.forEach((StreamSubscription subscription) => subscription.cancel());
        _subscriptions.clear();
      }
    );
  }
}


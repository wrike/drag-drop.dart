import 'fixture/fixture.dart';

void main() {

  test('DragDropSubscriptionFactory', () {
    DragDropManager dragDropManager = getDragDropManagerMock();
    DragDropSubscriptionFactory subscriptionFactory = new DragDropSubscriptionFactory(dragDropManager);
    Element element = getElementMock();
    BaseDragDropOptions options = getBaseDragDropOptions();
    DragDropSubscription subscription = subscriptionFactory.getSubscription(element, options);

    expect(subscription.dragDropManager, dragDropManager);
    expect(subscription.element, element);
    expect(subscription.options, options);
  });

}

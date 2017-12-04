@TestOn('browser')

import 'fixture/fixture.dart';

void main() {

  test('ResponsiveStreamManager create stream controller with dependant on-demand subscriptions', () {
    SimpleStreamSubscriptionMock dependantSubscription1 = new SimpleStreamSubscriptionMock();
    SimpleStreamSubscriptionMock dependantSubscription2 = new SimpleStreamSubscriptionMock();

    int providerCallTimes = 0;

    List<StreamSubscription> realProvider() => <StreamSubscription>[
      dependantSubscription1,
      dependantSubscription2
    ];
    List<StreamSubscription> testProvider() {
      providerCallTimes++;
      return realProvider();
    }

    StreamController controller = new ResponsiveStreamManager(testProvider).controller;

    expect(providerCallTimes, isZero);

    StreamSubscription subscription = controller.stream.listen((_) => null);
    expect(providerCallTimes, 1);

    subscription.cancel();
    verify(dependantSubscription1.cancel()).called(1);
    verify(dependantSubscription2.cancel()).called(1);

    subscription = controller.stream.listen((_) => null);
    expect(providerCallTimes, 2);

  });

}

@TestOn('browser')

import 'fixture/fixture.dart';


void main() {

  group('ScrollAbility', () {

    test('Should be nonZero if both dimensions are not disabled', () {
      ScrollAbility ability = new ScrollAbility(horizontal: true, vertical: true);
      expect(ability.nonZero, isTrue);
    });

    test('Should be nonZero if at least one dimension is not disabled', () {
      ScrollAbility ability = new ScrollAbility(horizontal: false, vertical: true);
      expect(ability.nonZero, isTrue);
    });

    test('Should be zero if both directions disabled', () {
      ScrollAbility ability = new ScrollAbility(horizontal: false, vertical: false);
      expect(ability.nonZero, isFalse);
    });
  });

}

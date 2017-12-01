import 'fixture/fixture.dart';


void main() {

  group('DragDropSimpleData', () {

    test('Setting and getting data', () {
      const String format = 'VDFGHJKMNBHKLMNkyuyghjkljhnmuhgyuiktghjkl';
      const String value = 'Would you like some wine?';
      const String nextValue = 'We haven not any and you are too young.';

      DragDropSimpleData data = getDragDropSimpleData();

      data.setData(format, value);
      expect(data.getData(format), equals(value));

      data.setData(format, nextValue);
      expect(data.getData(format), equals(nextValue));
      expect(data.getData(format), isNot(value));
    });

    test('Setting and getting text', () {
      const String value = 'Would you tell me, please, which way I ought to go from here?';
      const String nextValue = 'That depends a good deal on where you want to get to.';

      DragDropSimpleData data = getDragDropSimpleData();
      data.setText(value);
      expect(data.getText(), equals(value));

      data.setText(nextValue);
      expect(data.getText(), equals(nextValue));
      expect(data.getText(), isNot(value));
    });

    test('Setting and getting link', () {
      const String value = 'https://www.goodreads.com/work/quotes/2933712-alice-s-adventures-in-wonderland';
      const String nextValue = 'http://www.gradesaver.com/alice-in-wonderland/study-guide/bibliography';

      DragDropSimpleData data = getDragDropSimpleData();
      data.setLink(value);
      expect(data.getLink(), equals(value));

      data.setLink(nextValue);
      expect(data.getLink(), equals(nextValue));
      expect(data.getLink(), isNot(value));

      // double that
      expect(data.getText(), equals(nextValue));
    });

    test('Clearing', () {
      const String value = 'http://www.gradesaver.com/alice-in-wonderland/study-guide/bibliography';
      const String format1 = 'VDFGHJKMNBHKLMNkyuyghjkljhnmuhgyuiktghjkl';
      const String format2 = 'buzza';
      const String format3 = '9234902345';

      DragDropSimpleData data = getDragDropSimpleData();

      data.setData(format1, value);
      data.setData(format2, value);
      data.setData(format3, value);
      expect(data.getData(format1), value);

      data.clearData(format1);
      expect(data.getData(format1), isNull);

      data.clearData();
      expect(data.getData(format2), isNull);
      expect(data.getData(format3), isNull);
    });

  });

}

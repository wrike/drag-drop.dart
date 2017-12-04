class ScrollAbility {

  final bool vertical;
  final bool horizontal;

  bool get nonZero => vertical || horizontal;

  ScrollAbility({this.horizontal, this.vertical});
}

class ScrollOptions {
  final num minScrollAreaSize;
  final num maxScrollAreaSize;
  final num maxScrollStep;
  final num animationFrameDuration;

  ScrollOptions({
    this.minScrollAreaSize: 5,
    this.maxScrollAreaSize: 200,
    this.maxScrollStep: 150,
    this.animationFrameDuration: (1000 / 60)
  });
}

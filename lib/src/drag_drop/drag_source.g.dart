// GENERATED CODE - DO NOT MODIFY BY HAND

part of drag_source;

// **************************************************************************
// Generator: BuiltValueGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides
class _$DragSource extends DragSource {
  @override
  final Element element;
  @override
  final Element container;
  @override
  final DragOptions options;
  @override
  final Object model;
  @override
  final Element ghostElement;
  @override
  final Element sourceElement;

  factory _$DragSource([void updates(DragSourceBuilder b)]) =>
      (new DragSourceBuilder()..update(updates)).build();

  _$DragSource._(
      {this.element,
      this.container,
      this.options,
      this.model,
      this.ghostElement,
      this.sourceElement})
      : super._();

  @override
  DragSource rebuild(void updates(DragSourceBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  DragSourceBuilder toBuilder() => new DragSourceBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! DragSource) return false;
    return element == other.element &&
        container == other.container &&
        options == other.options &&
        model == other.model &&
        ghostElement == other.ghostElement &&
        sourceElement == other.sourceElement;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, element.hashCode), container.hashCode),
                    options.hashCode),
                model.hashCode),
            ghostElement.hashCode),
        sourceElement.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('DragSource')
          ..add('element', element)
          ..add('container', container)
          ..add('options', options)
          ..add('model', model)
          ..add('ghostElement', ghostElement)
          ..add('sourceElement', sourceElement))
        .toString();
  }
}

class DragSourceBuilder implements Builder<DragSource, DragSourceBuilder> {
  _$DragSource _$v;

  Element _element;
  Element get element => _$this._element;
  set element(Element element) => _$this._element = element;

  Element _container;
  Element get container => _$this._container;
  set container(Element container) => _$this._container = container;

  DragOptions _options;
  DragOptions get options => _$this._options;
  set options(DragOptions options) => _$this._options = options;

  Object _model;
  Object get model => _$this._model;
  set model(Object model) => _$this._model = model;

  Element _ghostElement;
  Element get ghostElement => _$this._ghostElement;
  set ghostElement(Element ghostElement) => _$this._ghostElement = ghostElement;

  Element _sourceElement;
  Element get sourceElement => _$this._sourceElement;
  set sourceElement(Element sourceElement) =>
      _$this._sourceElement = sourceElement;

  DragSourceBuilder();

  DragSourceBuilder get _$this {
    if (_$v != null) {
      _element = _$v.element;
      _container = _$v.container;
      _options = _$v.options;
      _model = _$v.model;
      _ghostElement = _$v.ghostElement;
      _sourceElement = _$v.sourceElement;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DragSource other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$DragSource;
  }

  @override
  void update(void updates(DragSourceBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$DragSource build() {
    final _$result = _$v ??
        new _$DragSource._(
            element: element,
            container: container,
            options: options,
            model: model,
            ghostElement: ghostElement,
            sourceElement: sourceElement);
    replace(_$result);
    return _$result;
  }
}

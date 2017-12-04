// GENERATED CODE - DO NOT MODIFY BY HAND

part of drop_target;

// **************************************************************************
// Generator: BuiltValueGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides
class _$DropTarget extends DropTarget {
  @override
  final Element element;
  @override
  final Element container;
  @override
  final DropOptions options;
  @override
  final Object model;
  @override
  final bool canAccept;

  factory _$DropTarget([void updates(DropTargetBuilder b)]) =>
      (new DropTargetBuilder()..update(updates)).build();

  _$DropTarget._(
      {this.element, this.container, this.options, this.model, this.canAccept})
      : super._() {
    if (element == null) throw new ArgumentError.notNull('element');
    if (container == null) throw new ArgumentError.notNull('container');
    if (options == null) throw new ArgumentError.notNull('options');
  }

  @override
  DropTarget rebuild(void updates(DropTargetBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  DropTargetBuilder toBuilder() => new DropTargetBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! DropTarget) return false;
    return element == other.element &&
        container == other.container &&
        options == other.options &&
        model == other.model &&
        canAccept == other.canAccept;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc(0, element.hashCode), container.hashCode),
                options.hashCode),
            model.hashCode),
        canAccept.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('DropTarget')
          ..add('element', element)
          ..add('container', container)
          ..add('options', options)
          ..add('model', model)
          ..add('canAccept', canAccept))
        .toString();
  }
}

class DropTargetBuilder implements Builder<DropTarget, DropTargetBuilder> {
  _$DropTarget _$v;

  Element _element;
  Element get element => _$this._element;
  set element(Element element) => _$this._element = element;

  Element _container;
  Element get container => _$this._container;
  set container(Element container) => _$this._container = container;

  DropOptions _options;
  DropOptions get options => _$this._options;
  set options(DropOptions options) => _$this._options = options;

  Object _model;
  Object get model => _$this._model;
  set model(Object model) => _$this._model = model;

  bool _canAccept;
  bool get canAccept => _$this._canAccept;
  set canAccept(bool canAccept) => _$this._canAccept = canAccept;

  DropTargetBuilder();

  DropTargetBuilder get _$this {
    if (_$v != null) {
      _element = _$v.element;
      _container = _$v.container;
      _options = _$v.options;
      _model = _$v.model;
      _canAccept = _$v.canAccept;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DropTarget other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$DropTarget;
  }

  @override
  void update(void updates(DropTargetBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$DropTarget build() {
    final _$result = _$v ??
        new _$DropTarget._(
            element: element,
            container: container,
            options: options,
            model: model,
            canAccept: canAccept);
    replace(_$result);
    return _$result;
  }
}

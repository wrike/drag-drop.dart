// GENERATED CODE - DO NOT MODIFY BY HAND

part of element_options_reference;

// **************************************************************************
// Generator: BuiltValueGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides
class _$DragDropElementOptionsReference
    extends DragDropElementOptionsReference {
  @override
  final BaseDragDropOptions options;
  @override
  final Element source;
  @override
  final Element target;
  @override
  final Element container;
  @override
  final bool isBlocked;

  factory _$DragDropElementOptionsReference(
          [void updates(DragDropElementOptionsReferenceBuilder b)]) =>
      (new DragDropElementOptionsReferenceBuilder()..update(updates)).build();

  _$DragDropElementOptionsReference._(
      {this.options, this.source, this.target, this.container, this.isBlocked})
      : super._() {
    if (options == null) throw new ArgumentError.notNull('options');
    if (source == null) throw new ArgumentError.notNull('source');
    if (target == null) throw new ArgumentError.notNull('target');
    if (container == null) throw new ArgumentError.notNull('container');
  }

  @override
  DragDropElementOptionsReference rebuild(
          void updates(DragDropElementOptionsReferenceBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  DragDropElementOptionsReferenceBuilder toBuilder() =>
      new DragDropElementOptionsReferenceBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! DragDropElementOptionsReference) return false;
    return options == other.options &&
        source == other.source &&
        target == other.target &&
        container == other.container &&
        isBlocked == other.isBlocked;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc(0, options.hashCode), source.hashCode),
                target.hashCode),
            container.hashCode),
        isBlocked.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('DragDropElementOptionsReference')
          ..add('options', options)
          ..add('source', source)
          ..add('target', target)
          ..add('container', container)
          ..add('isBlocked', isBlocked))
        .toString();
  }
}

class DragDropElementOptionsReferenceBuilder
    implements
        Builder<DragDropElementOptionsReference,
            DragDropElementOptionsReferenceBuilder> {
  _$DragDropElementOptionsReference _$v;

  BaseDragDropOptions _options;
  BaseDragDropOptions get options => _$this._options;
  set options(BaseDragDropOptions options) => _$this._options = options;

  Element _source;
  Element get source => _$this._source;
  set source(Element source) => _$this._source = source;

  Element _target;
  Element get target => _$this._target;
  set target(Element target) => _$this._target = target;

  Element _container;
  Element get container => _$this._container;
  set container(Element container) => _$this._container = container;

  bool _isBlocked;
  bool get isBlocked => _$this._isBlocked;
  set isBlocked(bool isBlocked) => _$this._isBlocked = isBlocked;

  DragDropElementOptionsReferenceBuilder();

  DragDropElementOptionsReferenceBuilder get _$this {
    if (_$v != null) {
      _options = _$v.options;
      _source = _$v.source;
      _target = _$v.target;
      _container = _$v.container;
      _isBlocked = _$v.isBlocked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DragDropElementOptionsReference other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$DragDropElementOptionsReference;
  }

  @override
  void update(void updates(DragDropElementOptionsReferenceBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$DragDropElementOptionsReference build() {
    final _$result = _$v ??
        new _$DragDropElementOptionsReference._(
            options: options,
            source: source,
            target: target,
            container: container,
            isBlocked: isBlocked);
    replace(_$result);
    return _$result;
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of drag_drop_state;

// **************************************************************************
// Generator: BuiltValueGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides
class _$DragDropState extends DragDropState {
  @override
  final bool isDragging;
  @override
  final bool isEnabled;

  factory _$DragDropState([void updates(DragDropStateBuilder b)]) =>
      (new DragDropStateBuilder()..update(updates)).build();

  _$DragDropState._({this.isDragging, this.isEnabled}) : super._() {
    if (isDragging == null) throw new ArgumentError.notNull('isDragging');
    if (isEnabled == null) throw new ArgumentError.notNull('isEnabled');
  }

  @override
  DragDropState rebuild(void updates(DragDropStateBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  DragDropStateBuilder toBuilder() => new DragDropStateBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! DragDropState) return false;
    return isDragging == other.isDragging && isEnabled == other.isEnabled;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, isDragging.hashCode), isEnabled.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('DragDropState')
          ..add('isDragging', isDragging)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class DragDropStateBuilder
    implements Builder<DragDropState, DragDropStateBuilder> {
  _$DragDropState _$v;

  bool _isDragging;
  bool get isDragging => _$this._isDragging;
  set isDragging(bool isDragging) => _$this._isDragging = isDragging;

  bool _isEnabled;
  bool get isEnabled => _$this._isEnabled;
  set isEnabled(bool isEnabled) => _$this._isEnabled = isEnabled;

  DragDropStateBuilder();

  DragDropStateBuilder get _$this {
    if (_$v != null) {
      _isDragging = _$v.isDragging;
      _isEnabled = _$v.isEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DragDropState other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$DragDropState;
  }

  @override
  void update(void updates(DragDropStateBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$DragDropState build() {
    final _$result = _$v ??
        new _$DragDropState._(isDragging: isDragging, isEnabled: isEnabled);
    replace(_$result);
    return _$result;
  }
}

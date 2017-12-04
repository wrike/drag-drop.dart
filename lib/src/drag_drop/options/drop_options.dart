import 'dart:async';
import 'dart:html';
import '../drag_source.dart';
import '../drop_target.dart';
import '../simple_data.dart';
import 'base_options.dart';
import 'spring_options.dart';


typedef dynamic RawDataModelProvider<T>(DataTransfer data);
typedef bool AcceptModelHandler(DragSource source, DropTarget target);
typedef Future BeforeDropHandler(DragSource source, DropTarget target, DragDropSimpleData data, MouseEvent event);
typedef bool CanEnterHandler(DragSource source);
typedef DragSpringOptions SpringOptionsProvider(DragSource source);

class DropOptions extends BaseDragDropOptions {

  final RawDataModelProvider _provideRawDataModel;
  final AcceptModelHandler _canDrop;
  final CanEnterHandler _canEnter;
  final BeforeDropHandler _beforeDrop;
  final SpringOptionsProvider _provideSpringOptions;

  DropOptions({
    String selector,
    ModelProvider provideModel,
    RawDataModelProvider provideRawDataModel,
    AcceptModelHandler canDrop,
    CanEnterHandler canEnter,
    BeforeDropHandler beforeDrop,
    SpringOptionsProvider provideSpringOptions
  }):
    _provideRawDataModel = provideRawDataModel,
    _canDrop = canDrop,
    _canEnter = canEnter,
    _beforeDrop = beforeDrop,
    _provideSpringOptions = provideSpringOptions,
  super (
    selector: selector,
    provideModel: provideModel
  );

  DragSpringOptions provideSpringOptions(DragSource source) {
    return _provideSpringOptions == null ? null : _provideSpringOptions(source);
  }

  dynamic provideRawDataModel(DataTransfer data) {
    return _provideRawDataModel == null ? null : _provideRawDataModel(data);
  }

  Future beforeDrop(DragSource source, DropTarget target, DragDropSimpleData data, MouseEvent event) {
    dynamic result;
    if (_beforeDrop != null) {
      result = _beforeDrop(source, target, data, event);
    }
    return new Future.delayed(Duration.ZERO, () => result);
  }

  bool canEnter(DragSource source) {
    return _canEnter == null ? true : _canEnter(source);
  }

  bool canDrop(DragSource source, DropTarget target) {
    if (_areModelsEqual(source?.model, target?.model)) {
      return false;
    }
    return _canDrop == null ? true : _canDrop(source, target);
  }

  static bool _areModelsEqual(dynamic source, dynamic target) {
    return source != null && source == target;
  }
}

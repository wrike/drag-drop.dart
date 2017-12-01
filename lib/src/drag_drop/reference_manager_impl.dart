import 'dart:html';
import 'drag_source.dart';
import 'drop_target.dart';
import 'element_manager.dart';
import 'element_options_reference.dart';
import 'model_storage.dart';
import 'options/base_options.dart';
import 'options/drag_options.dart';
import 'options/drop_options.dart';
import 'reference_manager.dart';


class DragDropReferenceManagerImpl implements DragDropReferenceManager {

  final DragDropElementManager _elementManager;
  final DragDropModelStorage _modelStorage;

  final Map<Element, Set<DragOptions>> _dragOptions = new Map<Element, Set<DragOptions>>();
  final Map<Element, Set<DropOptions>> _dropOptions = new Map<Element, Set<DropOptions>>();
  final Map<DropOptions, DragSource> _optionsSpecificSources = new Map<DropOptions, DragSource>();

  DragDropReferenceManagerImpl(this._elementManager, this._modelStorage);

  void attachDropOptions(Element container, DropOptions options) {
    _attachOptions(container, options, _dropOptions);
  }

  void attachDragOptions(Element container, DragOptions options) {
    _attachOptions(container, options, _dragOptions);
  }

  void _attachOptions(Element container, BaseDragDropOptions options, Map<Element, Set<BaseDragDropOptions>> storage) {
    storage.putIfAbsent(container, () => new Set()).add(options);
  }

  void detachDropOptions(Element container, DropOptions options) {
    _detachOptions(container, options, _dropOptions);
  }

  void detachDragOptions(Element container, DragOptions options) {
    _detachOptions(container, options, _dragOptions);
  }

  void _detachOptions(Element container, BaseDragDropOptions options, Map<Element, Set<BaseDragDropOptions>> storage) {
    Set<BaseDragDropOptions> storedOptions = storage[container];
    if (storedOptions != null) {
      storedOptions.remove(options);
      if (storedOptions?.isEmpty ?? false) {
        storage.remove(container);
      }
    }
  }

  DragDropElementOptionsReference getReferenceForTargetElement(Element startElement, DragSource source, MouseEvent event) {
    /// event.target can be a far-deep-descendant of real 'droppable' or be non droppable at all
    Element dropElement = _elementManager.getDropTargetElement(startElement);
    if (dropElement != null) {
      bool isBlocked = false;

      DragDropElementOptionsReference reference = _getReferenceForElement(dropElement, _dropOptions, (BaseDragDropOptions options) {
        DragSource optionsSpecificSource = _refineDragSource(source, isSpecific: () => _proceedWithOptionsSpecificSource(options, event.dataTransfer));
        bool canEnter = (options as DropOptions).canEnter(optionsSpecificSource);
        if (!canEnter) {
          isBlocked = true;
        }
        return canEnter;
      });

      if (reference != null) {
        /// recreate Reference with real source element
        return reference.rebuild((builder) => builder
          ..source = startElement
          ..isBlocked = isBlocked
        );
      }
    }
    return null;
  }

  DragDropElementOptionsReference getReferenceForSourceElement(Element startElement, [Element dragStartElement]) {
    DragDropElementOptionsReference reference = _getReferenceForElement(startElement, _dragOptions);
    if (reference != null && dragStartElement != null) {
      /// recreate Reference with real source element
      reference = reference.rebuild((builder) => builder.source = dragStartElement);

      /// test possible handle element
      bool isBlocked = _isReferenceSourceElementBlocked(reference);
      return reference.rebuild((builder) => builder.isBlocked = isBlocked);
    }
    return reference;
  }

  bool _isReferenceSourceElementBlocked(DragDropElementOptionsReference reference) {
    DragOptions options = reference.options;
    Element el = reference.source;
    while (el != null) {
      if (options.matchHandleElement(el)) {
        return false;
      }
      if (el == reference.target) {
        break;
      }
      el = _elementManager.getParentElement(el);
    }
    return true;
  }

  DragDropElementOptionsReference _getReferenceForElement(Element startElement, Map<Element, Set<BaseDragDropOptions>> containerOptions, [BaseDragDropOptionsMatcher optionsMatcher]) {
    /// Get nearest to the element ancestor as a Container with associated Options which match startElement
    Element el = startElement;
    while (el != null) {
      if (containerOptions.containsKey(el)) {
        BaseDragDropOptions options = containerOptions[el].firstWhere((BaseDragDropOptions option) => _optionsMatchAgainstElement(option, startElement, optionsMatcher), orElse: () => null);
        if (options != null) {
          return new DragDropElementOptionsReference((builder) => builder
            ..options = options
            ..source = startElement
            ..target = startElement
            ..container = el
          );
        }
      }
      el = _elementManager.getParentElement(el);
    }
    return null;
  }

  bool _optionsMatchAgainstElement(BaseDragDropOptions option, Element element, [BaseDragDropOptionsMatcher optionsMatcher]) {
    return option.matchElement(element) && (optionsMatcher == null || optionsMatcher(option));
  }

  List<Element> getSuitableDropContainerElements(Element startElement, DragSource source) {
    List<Element> result = <Element>[];
    if (source != null) {

      for (Element container in _getDropContainerElements(startElement)) {
        if (_dropOptions[ container ].firstWhere((DropOptions options) => options.canEnter(source), orElse: () => null) != null) {
          result.add(container);
        }
      }

    }
    return result;
  }

  Iterable<Element> _getDropContainerElements(Element startElement) {
    Iterable<Element> dropContainers = _dropOptions.keys;
    List<Element> ancestors = <Element>[];
    Element el = startElement;

    while (el != null) {
      ancestors.add(el);
      el = _elementManager.getParentElement(el);
    }
    return ancestors.where((Element el) => dropContainers.contains(el));
  }

  DragSource refineDragSourceOrGetOptionsSpecific(DragSource source, DropOptions options, MouseEvent event) => _refineDragSource(source, isSpecific: () => _proceedWithOptionsSpecificSource(options, event.dataTransfer));

  DragSource _refineDragSource(DragSource source, {OptionsSpecificSourceProvider isSpecific}) {
    if (source == null || _isRawDragSource(source)) {
      if (isSpecific != null) {
        return isSpecific();
      }
      return null;
    }
    return source;
  }

  bool _isRawDragSource(DragSource source) {
    /// Source made from raw/unregistered events
    return source.options == null;
  }

  DragSource _proceedWithOptionsSpecificSource(DropOptions options, DataTransfer data) {
    DragSource source = _getOptionsSpecificSource(options);
    if (source == null) {
      source = _createDragSourceFromEventData(options, data);
      if (source != null) {
        _storeOptionsSpecificSource(options, source);
      }
    }
    return source;
  }

  DragSource _getOptionsSpecificSource(DropOptions options) {
    return _optionsSpecificSources[options];
  }

  DragSource _createDragSourceFromEventData(DropOptions options, DataTransfer data) {
    dynamic model = options?.provideRawDataModel(data);
    return model == null ? null : new DragSource((builder) => builder.model = model);
  }

  void _storeOptionsSpecificSource(DropOptions options, DragSource rawSource) {
    _optionsSpecificSources[ options ] = rawSource;
  }

  DragDropElementOptionsReference createReferenceFromDropTarget(DropTarget target) => new DragDropElementOptionsReference((builder) => builder
    ..options = target.options
    ..source = target.element
    ..target = target.element
    ..container = target.container
    ..isBlocked = target.canAccept == false
  );

  DropTarget createDropTargetFromReference(DragDropElementOptionsReference reference) => new DropTarget((builder) => builder
    ..element = reference.target
    ..container = reference.container
    ..options = reference.options
    ..model = _getModelByReference(reference)
  );

  DragSource createDragSourceFromReference(DragDropElementOptionsReference reference, [Element dragStartElement]) => new DragSource((builder) => builder
    ..element = reference.target
    ..container = reference.container
    ..options = reference.options
    ..model = _getModelByReference(reference)
    ..sourceElement = dragStartElement ?? reference.source
  );

  dynamic _getModelByReference(DragDropElementOptionsReference reference) {
    return reference.options.provideModel(reference.target) ?? _modelStorage.getModel(reference.target);
  }

  void reset() {
    _optionsSpecificSources.clear();
  }

}

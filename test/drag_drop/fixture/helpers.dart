import 'package:drag_drop/drag_drop.dart';

import '../../common.dart';
import 'mocks.dart';

const int LEFT_BUTTON = 0;
const int RIGHT_BUTTON = 1;


RegExp _parseNumRE = new RegExp(r'^([-+]?\d+)');

num parseNum(String sourceString) =>
  int.parse(_parseNumRE.firstMatch(sourceString).group(0), radix: 10);

Future queueTimeout() =>
  new Future.delayed(new Duration(microseconds: 10));

Point getElementPosition(Element element) =>
  new Point<num>(
    parseNum(element.style.left),
    parseNum(element.style.top)
  );

BaseDragDropOptionsMock getBaseDragDropOptionsMock() =>
  new BaseDragDropOptionsMock();

DragDropEventQueue getDragDropEventQueue() =>
  new DragDropEventQueue.broadcast();

BaseDragEventMock getBaseDragEventMock() =>
  new BaseDragEventMock();

DropEventMock getDropEventMock() =>
  new DropEventMock();

DragEndEventMock getDragEndEventMock() =>
  new DragEndEventMock();

DragEnterEventMock getDragEnterEventMock() =>
  new DragEnterEventMock();

DragLeaveEventMock getDragLeaveEventMock() =>
  new DragLeaveEventMock();

DragOverEventMock getDragOverEventMock() =>
  new DragOverEventMock();

DragStartEventMock getDragStartEventMock() =>
  new DragStartEventMock();

DragDropEventReceiverMock getDragDropEventReceiverMock() =>
  new DragDropEventReceiverMock();

BaseDragEventReceiverMock getBaseDragEventReceiverMock() =>
  new BaseDragEventReceiverMock();

DataTransferMock getDataTransferMock() =>
  new DataTransferMock();

DragDropSimpleData getDragDropSimpleData({DataTransfer dataTransfer}) =>
  new DragDropSimpleData(dataTransfer ?? getDataTransferMock());

DragDropModelStorage getDragDropModelStorage() =>
  new DragDropModelStorage();

DropOptionsMock getDropOptionsMock() =>
  new DropOptionsMock();

DragSpringOptionsMock getDragSpringOptionsMock() =>
  new DragSpringOptionsMock();

BaseDragDropOptions getBaseDragDropOptions({String selector, ModelProvider provideModel}) =>
  new BaseDragDropOptionsTest(selector: selector, provideModel: provideModel);

DragOptions getDragOptions({
    String selector, ModelProvider provideModel, String handleSelector, GhostOptionsProvider provideGhost,
    BeforeDragStartHandler beforeStart, CanDragHandler canDrag}) =>
  new DragOptions(selector: selector, handleSelector: handleSelector, provideModel: provideModel,
    provideGhost: provideGhost, beforeStart: beforeStart, canDrag: canDrag);

DropOptions getDropOptions({
  String selector,
  ModelProvider provideModel,
  RawDataModelProvider provideRawDataModel,
  SpringOptionsProvider provideSpringOptions,
  AcceptModelHandler canDrop, CanEnterHandler canEnter, BeforeDropHandler beforeDrop}) =>
  new DropOptions(selector: selector,
    provideModel: provideModel,
    provideRawDataModel: provideRawDataModel,
    provideSpringOptions: provideSpringOptions,
    canDrop: canDrop,
    canEnter: canEnter,
    beforeDrop: beforeDrop);

UserEnvironment getUserEnvironment([Window mockedWindow]) =>
  UserEnvironmentFromWindowFactory(mockedWindow ?? window);



DragSourceMock getDragSourceMock({Element element, DragOptions options, Element container}) {
  element ??= getElementMock();
  container ??= getElementMock();
  options ??= getDragOptionsMock();
  DragSourceMock source = new DragSourceMock();
  when(source.element).thenReturn(element);
  when(source.container).thenReturn(container);
  when(source.options).thenReturn(options);
  return source;
}

DropTargetMock getDropTargetMock({
    Element element, bool canAccept, DropOptions options, Element container}) {
  element ??= getElementMock();
  container ??= getElementMock();
  options ??= getDropOptionsMock();
  canAccept ??= true;
  DropTargetMock target = new DropTargetMock();
  when(target.element).thenReturn(element);
  when(target.container).thenReturn(container);
  when(target.canAccept).thenReturn(canAccept);
  when(target.options).thenReturn(options);
  return target;
}

DragOptionsMock getDragOptionsMock({
    String selector, ModelProvider provideModel, String handleSelector, GhostOptionsProvider provideGhost,
    BeforeDragStartHandler beforeStart, CanDragHandler canDrag}) {

  selector ??= selector;
  handleSelector ??= handleSelector;
  provideModel ??= provideModel;
  provideGhost ??= provideGhost;
  beforeStart ??= beforeStart;
  canDrag ??= canDrag;

  DragOptions realOptions = new DragOptions(selector: selector,
    handleSelector: handleSelector,
    provideModel: provideModel,
    provideGhost: provideGhost,
    beforeStart: beforeStart,
    canDrag: canDrag);
  DragOptionsMock options = new DragOptionsMock();

  when(options.selector).thenReturn(realOptions.selector);
  when(options.matchElement(any)).thenAnswer((Invocation invocation) =>
    realOptions.matchElement(
      invocation.positionalArguments[0]
    ));
  when(options.provideModel(any)).thenAnswer((Invocation invocation) =>
    realOptions.provideModel(
      invocation.positionalArguments[0]
    ));
  when(options.beforeStart(any, any, any)).thenAnswer((Invocation invocation) =>
    realOptions.beforeStart(
      invocation.positionalArguments[0],
      invocation.positionalArguments[1],
      invocation.positionalArguments[2]
    ));
  when(options.matchHandleElement(any)).thenAnswer((Invocation invocation) =>
    realOptions.matchHandleElement(
      invocation.positionalArguments[0]
    ));
  when(options.canDrag(any)).thenAnswer((Invocation invocation) =>
    realOptions.canDrag(
      invocation.positionalArguments[0]
    ));
  when(options.provideGhost(any)).thenAnswer((Invocation invocation) =>
    realOptions.provideGhost(
      invocation.positionalArguments[0]
    ));
  return options;
}

DragGhostOptionsMock getDragGhostOptionsMock({Element element, Point offset}) {
  DragGhostOptionsMock options = new DragGhostOptionsMock();
  when(options.element).thenReturn(element);
  when(options.offset).thenReturn(offset);
  return options;
}

Element getDragDropContainerMock({
    CssClassSet classes, CssStyleDeclaration style, Element parent, Node parentNode,
    int clientHeight, int clientWidth, int scrollWidth, int scrollHeight, int scrollLeft,
    int scrollTop, int offsetTop, int offsetLeft, Rectangle<num> rectangle}) =>
  getElementMock(
    classes: classes,
    style: style,
    parent: parent,
    parentNode: parentNode,
    clientHeight: clientHeight,
    clientWidth: clientWidth,
    scrollWidth: scrollWidth,
    scrollHeight: scrollHeight,
    scrollLeft: scrollLeft,
    scrollTop: scrollTop,
    offsetTop: offsetTop,
    offsetLeft: offsetLeft,
    rectangle: rectangle
  );

Element getGhostContainerMock({
    CssClassSet classes, CssStyleDeclaration style, Element parent, Node parentNode,
    int clientHeight, int clientWidth, int scrollWidth, int scrollHeight, int scrollLeft,
    int scrollTop, int offsetTop, int offsetLeft, Rectangle<num> rectangle}) =>
  getElementMock(
    classes: classes,
    style: style,
    parent: parent,
    parentNode: parentNode,
    clientHeight: clientHeight,
    clientWidth: clientWidth,
    scrollWidth: scrollWidth,
    scrollHeight: scrollHeight,
    scrollLeft: scrollLeft,
    scrollTop: scrollTop,
    offsetTop: offsetTop,
    offsetLeft: offsetLeft,
    rectangle: rectangle
  );

DragGhostContainer getDragGhostContainerWrapperMock(Element element) {
  DragGhostContainerMock container = new DragGhostContainerMock();
  when(container.element).thenReturn(element);
  return container;
}

DragDropContainer getDragDropContainerWrapperMock(Element element) {
  DragDropContainerMock container = new DragDropContainerMock();
  when(container.element).thenReturn(element);
  return container;
}

DragDropElementManager getElementManager({
    Element dragDropContainer, Element ghostContainer, UserEnvironment environment}) =>
// todo
  DragDropElementManagerFactory(
    dragDropContainer: getDragDropContainerWrapperMock(dragDropContainer ?? getDragDropContainerMock()),
    ghostContainer: getDragGhostContainerWrapperMock(ghostContainer ?? getGhostContainerMock()),
    environment: environment ?? getUserEnvironment()
  );
/*
  DragDropContainer dragDropContainer,
  DragGhostContainer ghostContainer,
  UserEnvironment environment
}) {
  return new DragDropElementManagerImpl(
    (dragDropContainer ??= DragDropContainerFactory()).element,
    (ghostContainer ??= DragGhostContainerFactory()).element,
    environment ??= UserEnvironmentFactory()
  );
 */
DragDropManagerMock getDragDropManagerMock() {
  DragDropManager manager = new DragDropManagerMock();

  StreamMock onDragStart = new StreamMock<DragStartEvent>();
  StreamMock onDragEnter = new StreamMock<DragEnterEvent>();
  StreamMock onDragSpringEnter = new StreamMock<DragSpringEnterEvent>();
  StreamMock onDragOver = new StreamMock<DragOverEvent>();
  StreamMock onDragLeave = new StreamMock<DragLeaveEvent>();
  StreamMock onDrop = new StreamMock<DropEvent>();
  StreamMock onDragEnd = new StreamMock<DragEndEvent>();

  when(manager.onDragStart).thenReturn(onDragStart);
  when(manager.onDragEnter).thenReturn(onDragEnter);
  when(manager.onDragSpringEnter).thenReturn(onDragSpringEnter);
  when(manager.onDragOver).thenReturn(onDragOver);
  when(manager.onDragLeave).thenReturn(onDragLeave);
  when(manager.onDrop).thenReturn(onDrop);
  when(manager.onDragEnd).thenReturn(onDragEnd);

  return manager;
}

DragDropEventQueueMock getDragDropEventQueueMock({StreamMock<BaseDragEvent> stream}) {
  DragDropEventQueueMock queue = new DragDropEventQueueMock();
  stream ??= new StreamMock<BaseDragEvent>();
  when(queue.stream).thenReturn(stream);
  when(queue.hasListener).thenAnswer((_) => stream.subscriptions.isNotEmpty);
  return queue;
}

DragDropElementManagerMock getDragDropElementManagerMock({
    Element dragDropContainer, Element ghostContainer, UserEnvironment environment}) {
  dragDropContainer ??= getElementMock();
  ghostContainer ??= getElementMock();
  environment ??= getUserEnvironment();

  DragDropElementManagerMock manager = new DragDropElementManagerMock();
  when(manager.dragDropContainer).thenReturn(dragDropContainer);
  when(manager.ghostContainer).thenReturn(ghostContainer);
  when(manager.environment).thenReturn(environment);
  return manager;
}

DragDropEventManager getDragDropEventManager({
    DragDropElementManager elementManager, DragDropEventQueue eventQueue,
    Element dragDropContainer, UserEnvironment environment}) {
  eventQueue ??= getDragDropEventQueueMock();
  dragDropContainer ??= getElementMockWithStreams();
  environment ??= getUserEnvironment();
  elementManager ??= getDragDropElementManagerMock(dragDropContainer: dragDropContainer, environment: environment);
  return DragDropEventManagerFactory(
    environment: environment,
    elementManager: elementManager,
    dragDropContainer: getDragDropContainerWrapperMock(dragDropContainer),
    eventQueue: eventQueue
  );
}

ElementMock getElementMockWithStreams() {
  Element element = spy(new ElementMock(), new DivElement());

  StreamMock<MouseEventMock> onMouseDown = new StreamMock<MouseEventMock>();
  StreamMock<MouseEventMock> onMouseUp = new StreamMock<MouseEventMock>();
  StreamMock<MouseEventMock> onSelectStart = new StreamMock<MouseEventMock>();
  StreamMock<MouseEventMock> onDragStart = new StreamMock<MouseEventMock>();
  StreamMock<MouseEventMock> onDragEnter = new StreamMock<MouseEventMock>();
  StreamMock<MouseEventMock> onDragOver = new StreamMock<MouseEventMock>();
  StreamMock<MouseEventMock> onDragLeave = new StreamMock<MouseEventMock>();
  StreamMock<MouseEventMock> onDrop = new StreamMock<MouseEventMock>();
  StreamMock<MouseEventMock> onDragEnd = new StreamMock<MouseEventMock>();

  when(element.onMouseDown).thenReturn(onMouseDown);
  when(element.onMouseUp).thenReturn(onMouseUp);
  when(element.onSelectStart).thenReturn(onSelectStart);
  when(element.onDragStart).thenReturn(onDragStart);
  when(element.onDragEnter).thenReturn(onDragEnter);
  when(element.onDragOver).thenReturn(onDragOver);
  when(element.onDragLeave).thenReturn(onDragLeave);
  when(element.onDrop).thenReturn(onDrop);
  when(element.onDragEnd).thenReturn(onDragEnd);

  return element;
}

UserBrowserMock getUserBrowserMock(BrowserType type) {
  UserBrowserMock browser = new UserBrowserMock();
  when(browser.type).thenReturn(type);
  return browser;
}

UserPlatformMock getUserPlatformMock(UserPlatformType type) {
  UserPlatformMock platform = new UserPlatformMock();
  when(platform.type).thenReturn(type);
  return platform;
}

UserEnvironmentMock getUserEnvironmentMock({UserBrowser browser, UserPlatform platform}) {
  browser ??= getUserBrowserMock(BrowserType.Chrome);
  platform ??= getUserPlatformMock(UserPlatformType.Mac);
  UserEnvironmentMock environment = new UserEnvironmentMock();
  when(environment.browser).thenReturn(browser);
  when(environment.platform).thenReturn(platform);
  return environment;
}

DragDropSubscription getDragDropSubscription({
    Element element, BaseDragDropOptions options, DragDropManager dragDropManager}) {
  options ??= getBaseDragDropOptionsMock();
  element ??= getElementMockWithStreams();
  dragDropManager ??= getDragDropManagerMock();
  return new DragDropSubscription(element, options, dragDropManager);
}

DragDropEventsBundle getEventsBundle(DragSource source, DropTarget target) {
  DragStartEvent startEvent = new DragStartEventMock();
  when(startEvent.source).thenReturn(source);

  DragEndEvent endEvent = new DragEndEventMock();
  when(endEvent.source).thenReturn(source);

  DragEnterEvent enterEvent = new DragEnterEventMock();
  when(enterEvent.target).thenReturn(target);

  DragSpringEnterEvent springEnterEvent = new DragSpringEnterEventMock();
  when(springEnterEvent.target).thenReturn(target);

  DragOverEvent overEvent = new DragOverEventMock();
  when(overEvent.target).thenReturn(target);

  DragLeaveEvent leaveEvent = new DragLeaveEventMock();
  when(leaveEvent.target).thenReturn(target);

  DropEvent dropEvent = new DropEventMock();
  when(dropEvent.target).thenReturn(target);

  return new DragDropEventsBundle(
    startEvent: startEvent,
    endEvent: endEvent,
    enterEvent: enterEvent,
    springEnterEvent: springEnterEvent,
    overEvent: overEvent,
    leaveEvent: leaveEvent,
    dropEvent: dropEvent
  );
}

void addBaseDragEventToStreamMock(Stream stream, BaseDragEvent event) {
  if (event != null) {
    (stream as StreamMock).add(event);
  }
}

void addEventsBundleToDragDropManagerStreams(DragDropManager manager, DragDropEventsBundle events) {
  addBaseDragEventToStreamMock(manager.onDragStart, events.startEvent);
  addBaseDragEventToStreamMock(manager.onDragEnd, events.endEvent);
  addBaseDragEventToStreamMock(manager.onDragEnter, events.enterEvent);
  addBaseDragEventToStreamMock(manager.onDragSpringEnter, events.springEnterEvent);
  addBaseDragEventToStreamMock(manager.onDragOver, events.overEvent);
  addBaseDragEventToStreamMock(manager.onDragLeave, events.leaveEvent);
  addBaseDragEventToStreamMock(manager.onDrop, events.dropEvent);
}

void subscribeReceiverToDragDropEvents(dynamic source, DragDropEventReceiver receiver) {
  source.onDragStart.listen((DragStartEvent event) => receiver.onDragStart(event));
  source.onDragEnd.listen((DragEndEvent event) => receiver.onDragEnd(event));
  source.onDragEnter.listen((DragEnterEvent event) => receiver.onDragEnter(event));
  source.onDragSpringEnter.listen((DragSpringEnterEvent event) => receiver.onDragSpringEnter(event));
  source.onDragOver.listen((DragOverEvent event) => receiver.onDragOver(event));
  source.onDragLeave.listen((DragLeaveEvent event) => receiver.onDragLeave(event));
  source.onDrop.listen((DropEvent event) => receiver.onDrop(event));
}

void subscribeReceiverToDragDropSubscription(DragDropSubscription subscription, DragDropEventReceiver receiver) {
  subscribeReceiverToDragDropEvents(subscription, receiver);
}


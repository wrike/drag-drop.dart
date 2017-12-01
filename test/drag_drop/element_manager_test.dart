import 'fixture/fixture.dart';
import 'package:browser_detect/browser_detect.dart';
import 'package:user_environment/user_environment.dart';


void testGhostElement(DragDropElementManager manager, Element ghostElement, Element dragElement) {
  expect(ghostElement, new isInstanceOf<Element>());
  expect(ghostElement, isNot(dragElement));
}

void testGhostElementContainer(DragDropElementManager manager, Element ghostContainer, Rectangle dragRect, Point offset) {
  expect(ghostContainer, new isInstanceOf<Element>());
  expect(ghostContainer.style.left, "${dragRect.left + offset.x}px");
  expect(ghostContainer.style.top, "${dragRect.top + offset.y}px");
  expect(ghostContainer.classes.contains(DragDropElementManager.SOURCE_GHOST_WRAPPER), isTrue);
  expect(manager.ghostContainer, ghostContainer.parent);
}

void testDataTransferDragImagePosition(DragDropElementManager manager, Element ghostElement, MouseEvent mouseEvent, Point cursorPosition, Point matchOffset) {
  when(mouseEvent.page).thenReturn(cursorPosition);
  manager.setDragImage(ghostElement, mouseEvent);
  DataTransferMock dataTransfer = mouseEvent.dataTransfer;
  expect(dataTransfer.dragImagePosition.x, matchOffset.x);
  expect(dataTransfer.dragImagePosition.y, matchOffset.y);
}


void main() {

  test('DragDropElementManager construction', () {
    Element ghostContainer = getElementMock();
    Element dragDropContainer = getElementMock();
    UserEnvironment environment = getUserEnvironment();

    DragDropElementManager manager = getElementManager(ghostContainer: ghostContainer, dragDropContainer: dragDropContainer, environment: environment);

    expect(manager.dragDropContainer, dragDropContainer);
    expect(manager.ghostContainer, ghostContainer);
    expect(manager.environment, environment);
  });


  group('DragDropElementManager manage participants of drag drop process', () {

    test('Decorate ghostContainer right after construction stage', () {
      Element ghostContainer = getElementMock();
      DragDropElementManager manager = getElementManager(ghostContainer: ghostContainer);

      expect(manager.ghostContainer, ghostContainer);

      UserEnvironment environment = manager.environment;
      CssClassSet classes = ghostContainer.classes;

      if (environment.browser.type == BrowserType.IE) {
        expect(classes.contains('isIE'), isTrue);
        if (environment.browser.version == new BrowserVersion('11')) {
          expect(classes.contains('isIE11'), isTrue);
        }
        else if (environment.browser.version == new BrowserVersion('10')) {
          expect(classes.contains('isIE10'), isTrue);
        }
      }
      expect(classes.contains('isEdge'), environment.browser.type == BrowserType.Edge);
      expect(classes.contains('isGecko'), environment.browser.type == BrowserType.Firefox);
      expect(classes.contains('isSafari'), environment.browser.type == BrowserType.Safari);
      expect(classes.contains('isOpera'), environment.browser.type == BrowserType.Opera);
      expect(classes.contains('isOtherBrowser'), environment.browser.type == BrowserType.Other);
      expect(classes.contains('isMacPlatform'), environment.platform.type == UserPlatformType.Mac);
      expect(classes.contains('isWindowsPlatform'), environment.platform.type == UserPlatformType.Windows);
      expect(classes.contains('isOtherPlatform'), environment.platform.type == UserPlatformType.Other);
    });

    test('Properly decorate/clear dropTarget depending on "canAccept" boolean value', () {
      DragDropElementManager manager = getElementManager();

      DropTarget dropTarget = getDropTargetMock();
      CssClassSet classes = dropTarget.element.classes;

      manager.decorateDropTarget(dropTarget);
      expect(classes.contains(DragDropElementManager.TARGET_OVER_CLS), isTrue);
      expect(classes.contains(DragDropElementManager.TARGET_OVER_VALID_CLS), isTrue);
      expect(classes.contains(DragDropElementManager.TARGET_OVER_INVALID_CLS), isFalse);

      when(dropTarget.canAccept).thenReturn(false);
      manager.decorateDropTarget(dropTarget);
      expect(classes.contains(DragDropElementManager.TARGET_OVER_CLS), isTrue);
      expect(classes.contains(DragDropElementManager.TARGET_OVER_VALID_CLS), isFalse);
      expect(classes.contains(DragDropElementManager.TARGET_OVER_INVALID_CLS), isTrue);

      manager.clearDropTarget(dropTarget);
      expect(classes.contains(DragDropElementManager.TARGET_OVER_CLS), isFalse);
      expect(classes.contains(DragDropElementManager.TARGET_OVER_VALID_CLS), isFalse);
      expect(classes.contains(DragDropElementManager.TARGET_OVER_INVALID_CLS), isFalse);
    });

    test('Properly decorate/clear dragSource', () {
      DragDropElementManager manager = getElementManager();

      DragSource dragSource = getDragSourceMock();
      CssClassSet classes = dragSource.element.classes;

      manager.decorateDragSource(dragSource);
      expect(classes.contains(DragDropElementManager.SOURCE_GHOSTED_CLS), isTrue);

      manager.clearDragSource(dragSource);
      expect(classes.contains(DragDropElementManager.SOURCE_GHOSTED_CLS), isFalse);
    });

    test('Properly decorate/clear dropContainer', () {
      DragDropElementManager manager = getElementManager();
      Element dropContainer = getElementMock();
      CssClassSet classes = dropContainer.classes;

      manager.decorateDropContainer(dropContainer);
      expect(classes.contains(DragDropElementManager.CONTAINER_OVER_CLS), isTrue);

      manager.clearDropContainer(dropContainer);
      expect(classes.contains(DragDropElementManager.CONTAINER_OVER_CLS), isFalse);
    });

    test('Should properly decorate dropContainers, clear dropContainers before highlight next set of containers, support intersection of sets', () {
      DragDropElementManager manager = getElementManager();

      List<Element> containers = new List.generate(10, (int index) => getElementMock());

      manager.highlightDropContainers(containers);
      for (Element container in containers) {
        expect(container.classes.contains(DragDropElementManager.CONTAINER_OVER_CLS), isTrue);
      }

      List<Element> nextContainers = new List.generate(10, (int index) => getElementMock());
      // next set contains 5 containers from previous one
      nextContainers.addAll(containers.getRange(0, 5));

      manager.highlightDropContainers(nextContainers);
      for (Element container in nextContainers) {
        expect(container.classes.contains(DragDropElementManager.CONTAINER_OVER_CLS), isTrue);
      }

      // all unmatched containers from previous set should be cleared
      for (Element container in containers.getRange(6, containers.length)) {
        expect(container.classes.contains(DragDropElementManager.CONTAINER_OVER_CLS), isFalse);
      }

      manager.clearDropContainers();
      for (Element container in nextContainers) {
        expect(container.classes.contains(DragDropElementManager.CONTAINER_OVER_CLS), isFalse);
      }
    });

  });


  group('DragDropElementManager matching draggable/droppable elements', () {

    test('Make element draggable and know if it is true', () {
      DragDropElementManager manager = getElementManager();

      Element element = new DivElement();
      expect(manager.isElementDraggable(element), isFalse);

      manager.makeElementDraggable(element);
      expect(manager.isElementDraggable(element), isTrue);

      element = new DivElement();
      element.draggable = true;
      expect(manager.isElementDraggable(element), isTrue);
    });

    test('Make element non-draggable and know if it is true', () {
      DragDropElementManager manager = getElementManager();

      Element element = new DivElement();
      element.draggable = true;
      expect(manager.isElementDraggable(element), isTrue);

      manager.makeElementNonDraggable(element);
      expect(manager.isElementDraggable(element), isFalse);
      expect(element.draggable, isFalse);
    });

    test('Make element droppable and know if it is true', () {
      DragDropElementManager manager = getElementManager();

      Element element = new DivElement();
      expect(manager.isElementDroppable(element), isFalse);

      manager.makeElementDroppable(element);
      expect(manager.isElementDroppable(element), isTrue);

      element.setAttribute(DragDropElementManager.ELEMENT_DROPPABLE_ATTRIBUTE, 'false');
      expect(manager.isElementDroppable(element), isFalse);

      element.setAttribute(DragDropElementManager.ELEMENT_DROPPABLE_ATTRIBUTE, 'nonfalsevalue');
      expect(manager.isElementDroppable(element), isTrue);
    });

    test('Make element and it\'s ancestors non-draggable and know if it is true', () {

      Element element = new DivElement();
      element.draggable = true;

      Element parentElement = new DivElement();
      parentElement.draggable = false;
      parentElement.append(element);

      Element grandElement = new DivElement();
      grandElement.draggable = true;
      grandElement.append(parentElement);

      Element outsideScopeElement = new DivElement();
      outsideScopeElement.draggable = true;
      outsideScopeElement.append(grandElement);

      DragDropElementManager manager = getElementManager(dragDropContainer: grandElement);

      expect(manager.isElementDraggable(element), isTrue);
      expect(manager.isElementDraggable(parentElement), isFalse);
      expect(manager.isElementDraggable(grandElement), isTrue);
      expect(manager.isElementDraggable(outsideScopeElement), isTrue);

      List<Element> affectedElements = manager.makeElementAncestorsNonDraggable(element);

      expect(affectedElements.length, 2);
      expect(affectedElements.contains(element), isTrue);
      expect(affectedElements.contains(grandElement), isTrue);

      expect(manager.isElementDraggable(element), isFalse);
      expect(manager.isElementDraggable(parentElement), isFalse);
      expect(manager.isElementDraggable(grandElement), isFalse);
      expect(manager.isElementDraggable(outsideScopeElement), isTrue);
    });

    //makeElementAncestorsNonDraggable
  });


  group('DragDropElementManager manage input elements', () {

    test('isInputElement (except contentEditable) should match input elements', () {
      DragDropElementManager manager = getElementManager();

      List<Element> inputElements = [
        new InputElement(),
        new CheckboxInputElement(),
        new RadioButtonInputElement(),
        new ButtonInputElement(),
        new TextInputElement(),
        new FileUploadInputElement(),
        new TextAreaElement(),
        new SelectElement(),
        new SubmitButtonInputElement(),
        new ImageButtonInputElement(),
        new ImageButtonInputElement()
      ];

      for (Element element in inputElements) {
        expect(manager.isInputElement(element), isTrue);
      }

      expect(manager.isInputElement(new DivElement()), isFalse);
    });

    test('isInputElement should match contentEditable elements WITHOUT restriction by dragDropContainer', () {
      Element f = new DivElement();
      Element e = new DivElement();
      Element d = new DivElement();
      Element c = new DivElement();
      Element b = new DivElement();
      Element a = new DivElement();
      f.append(e);
      e.append(d);
      d.append(c);
      c.append(b);
      b.append(a);

      DragDropElementManager manager = getElementManager(dragDropContainer: e);

      expect(manager.isInputElement(a), isFalse);

      c.contentEditable = 'true';
      expect(manager.isInputElement(a), isTrue);
      expect(manager.isInputElement(d), isFalse);

      f.contentEditable = 'true';
      expect(manager.isInputElement(d), isTrue);
    });

  });


  group('DragDropElementManager traverse tree of elements', () {
    Element d = new DivElement();
    Element c = new DivElement();
    Element b = new DivElement();
    Element a = new DivElement();
    d.append(c);
    c.append(b);
    b.append(a);

    DragDropElementManager manager = getElementManager(dragDropContainer: c);

    test('getParentElement should get parent element restricted by dragDropContainer', () {
      expect(manager.getParentElement(a), b);
      expect(manager.getParentElement(b), c);
      expect(manager.getParentElement(c), isNull);
    });

    test('getDropTargetElement should get first droppable element in the tree, restricted by dragDropContainer', () {
      expect(manager.getDropTargetElement(a), isNull);

      manager.makeElementDroppable(d);
      expect(manager.getDropTargetElement(a), isNull);

      manager.makeElementDroppable(c);
      expect(manager.getDropTargetElement(a), c);

      manager.makeElementDroppable(b);
      expect(manager.getDropTargetElement(a), b);
      expect(manager.getDropTargetElement(b), b);

      manager.makeElementDroppable(a);
      expect(manager.getDropTargetElement(a), a);
    });

  });


  test('DragDropElementManager.getElementEventRelativePosition should return event position relative to element boundaries and restricted by them', () {
    DragDropElementManager manager = getElementManager();

    Element element = getElementMock();
    Rectangle rect = element.getBoundingClientRect();
    Point position;

    num minX = rect.left;
    num maxX = rect.left + rect.width;
    num minY = rect.top;
    num maxY = rect.top + rect.height;

    position = manager.getElementEventRelativePosition(element, getEventMock(position: new Point(minX - 1, minY - 1)));
    expect(position.x, 0);
    expect(position.y, 0);

    position = manager.getElementEventRelativePosition(element, getEventMock(position: new Point(minX, minY)));
    expect(position.x, 0);
    expect(position.y, 0);

    position = manager.getElementEventRelativePosition(element, getEventMock(position: new Point(minX + 1, minY + 1)));
    expect(position.x, 1);
    expect(position.y, 1);

    position = manager.getElementEventRelativePosition(element, getEventMock(position: new Point(maxX - 1, maxY - 1)));
    expect(position.x, rect.width - 1);
    expect(position.y, rect.height - 1);

    position = manager.getElementEventRelativePosition(element, getEventMock(position: new Point(maxX, maxY)));
    expect(position.x, rect.width);
    expect(position.y, rect.height);

    position = manager.getElementEventRelativePosition(element, getEventMock(position: new Point(maxX + 1, maxY + 1)));
    expect(position.x, rect.width);
    expect(position.y, rect.height);
  });


  group('DragDropElementManager.createGhostElement', () {
    MouseEvent mouseEvent = getEventMock();
    DragSource dragSource = getDragSourceMock();
    DragDropElementManager manager = getElementManager(ghostContainer: new DivElement());
    Element dragElement = getElementMock();

    when(dragElement.clone(true)).thenReturn(new DivElement());

    test('Should handle null', () {
      when(dragSource.element).thenReturn(null);
      expect(manager.createGhostElement(dragSource, mouseEvent), isNull);
    });

    test('Should handle default values (no DragGhostOptions custom provided)', () {
      when(dragSource.element).thenReturn(dragElement);
      Element ghostElement = manager.createGhostElement(dragSource, mouseEvent);

      testGhostElement(manager, ghostElement, dragElement);
      testGhostElementContainer(manager, ghostElement.parent, dragElement.getBoundingClientRect(), DragDropElementManager.DEFAULT_GHOST_OFFSET);
    });

    test('Should handle custom DragGhostOptions options', () {
      when(dragSource.element).thenReturn(dragElement);
      DragGhostOptionsMock ghostOptions = getDragGhostOptionsMock(element: dragElement, offset: new Point(10, 10));
      DragOptions dragOptions = dragSource.options;
      when(dragOptions.provideGhost(dragSource)).thenReturn(ghostOptions);
      Element ghostElement = manager.createGhostElement(dragSource, mouseEvent);

      testGhostElement(manager, ghostElement, dragElement);
      testGhostElementContainer(manager, ghostElement.parent, dragElement.getBoundingClientRect(), ghostOptions.offset);
    });

  });


  test('DragDropElementManager.setDragImage should always put image at the cursor position', () {
    DragDropElementManager manager = getElementManager();
    Element ghostElement = getElementMock();
    MouseEvent mouseEvent = getEventMock();
    DataTransferMock dataTransfer = getDataTransferMock();
    when(mouseEvent.dataTransfer).thenReturn(dataTransfer);

    Rectangle rect = ghostElement.getBoundingClientRect();
    num minX = rect.left;
    num maxX = rect.left + rect.width;
    num minY = rect.top;
    num maxY = rect.top + rect.height;

    Point minOffset = DragDropElementManager.MINIMUM_DRAG_IMAGE_OFFSET;
    Point stablePosition = minOffset;

    testDataTransferDragImagePosition(manager, ghostElement, mouseEvent, new Point(minX, minY), stablePosition);
    testDataTransferDragImagePosition(manager, ghostElement, mouseEvent, new Point(minX + 1, minY + 1), stablePosition);

    stablePosition = new Point(minX + minOffset.x + 1, minY + minOffset.y + 1);
    testDataTransferDragImagePosition(manager, ghostElement, mouseEvent, stablePosition, stablePosition);

    stablePosition = new Point(maxX - minOffset.x - 1, maxY - minOffset.y - 1);
    testDataTransferDragImagePosition(manager, ghostElement, mouseEvent, stablePosition, stablePosition);

    stablePosition = new Point(maxX - minOffset.x, maxY - minOffset.y);
    testDataTransferDragImagePosition(manager, ghostElement, mouseEvent, stablePosition, stablePosition);

    testDataTransferDragImagePosition(manager, ghostElement, mouseEvent, new Point(maxX - minOffset.x + 1, maxY - minOffset.y + 1), stablePosition);
    testDataTransferDragImagePosition(manager, ghostElement, mouseEvent, new Point(maxX - 1, maxY - 1), stablePosition);
    testDataTransferDragImagePosition(manager, ghostElement, mouseEvent, new Point(maxX, maxY), stablePosition);
  });


  group('DragDropElementManager manage ghostElement', () {
    MouseEvent mouseEvent = getEventMock();
    Element dragElement = getElementMock();
    when(dragElement.clone(true)).thenReturn(new DivElement());
    DragSource dragSource = getDragSourceMock(element: dragElement);
    DragDropElementManager manager = getElementManager(ghostContainer: new DivElement());

    test('DragDropElementManager.moveGhostElementByEvent should move ghost in the same directions and to the same distance as cursor moves', () {
      Point cursorPosition = new Point(0, 0);
      Point elementPosition = cursorPosition;
      Point prevElementPosition;
      Point prevCursorPosition;

      when(mouseEvent.page).thenReturn(cursorPosition);
      Element ghostElement = manager.createGhostElement(dragSource, mouseEvent);
      elementPosition = getElementPosition(ghostElement.parent);

      List<Point> cursorPositions = [
        new Point(20, 200),
        new Point(-10020, 10200),
        new Point(1, 1),
        new Point(499, 599),
        new Point(0, 0)
      ];

      for (Point currentCursorPosition in cursorPositions) {
        prevCursorPosition = cursorPosition;
        cursorPosition = currentCursorPosition;
        when(mouseEvent.page).thenReturn(cursorPosition);
        manager.moveGhostElementByEvent(mouseEvent);
        prevElementPosition = elementPosition;
        elementPosition = getElementPosition(ghostElement.parent);
        expect(elementPosition.x - prevElementPosition.x, cursorPosition.x - prevCursorPosition.x);
        expect(elementPosition.y - prevElementPosition.y, cursorPosition.y - prevCursorPosition.y);
      }
    });

    test('Should be able to hideGhostElement and showGhostElement', () {
      Element ghostElement = manager.createGhostElement(dragSource, mouseEvent);
      CssStyleDeclaration parentStyle = ghostElement.parent.style;

      manager.hideGhostElement();
      expect(parentStyle.display, 'none');

      manager.showGhostElement();
      expect(parentStyle.display, 'block');
    });

    test('Should be able to removeGhostElement', () {
      Element ghostElement = manager.createGhostElement(dragSource, mouseEvent);
      expect(manager.ghostContainer.children.contains(ghostElement.parent), isTrue);

      manager.removeGhostElement();
      expect(manager.ghostContainer.children.contains(ghostElement.parent), isFalse);
    });
  });

}

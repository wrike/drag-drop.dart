import 'dart:html';
import 'dart:math';
import '../../movement.dart';
import 'ability.dart';
import 'options.dart';

class ScrollManager {

  static const List<String> _CSS_OVERFLOW_SCROLLABLE_VALUES = const ['scroll', 'auto'];

  final MovementManager _movementManager;
  final Element _scrollContainer;

  final Map<Element, int> _animations = new Map<Element, int>();
  final Set<Element> _allowedElements = new Set<Element>();

  ScrollOptions _options;
  ScrollOptions get options => _options;
  MovementDetails _lastMovement;
  Element _lastStartElement;

  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  ScrollManager(this._movementManager, this._scrollContainer, ScrollOptions options) {
    setOptions(options);
  }

  void setOptions(ScrollOptions options) {
    _options = options ?? new ScrollOptions();
  }

  void scrollViewByEvent(Element startElement, MouseEvent event) {
    scrollViewByMovement(startElement, _movementManager.getEventMovementDetails(event));
  }

  void scrollViewByMovement(Element startElement, MovementDetails movement) {
    if (!_isEnabled || (movement == _lastMovement && startElement == _lastStartElement)) {
      return;
    }
    _lastMovement = movement;
    _lastStartElement = startElement;
    _cancelAnimations();

    if (movement.direction.nonZero) {
      MovementDetails nextMovement = movement;
      Element el = startElement;
      while (el != null) {
        ScrollAbility reaction = scrollElementByMovement(el, nextMovement);
        if (reaction != null) {
          nextMovement = _getNextMovementAfterReaction(reaction, nextMovement);
        }
        el = _getParentElement(el);
      }
    }
  }

  MovementDetails _getNextMovementAfterReaction(ScrollAbility reaction, MovementDetails movement) {
    return new MovementDetails(
      movement.position,
      new MovementDirection(
        reaction.horizontal ? MovementDirectionType.zero : movement.direction.x,
        reaction.vertical ? MovementDirectionType.zero : movement.direction.y
      )
    );
  }

  ScrollAbility scrollElementByMovement(Element element, MovementDetails movement) {
    if (_isEnabled && movement.direction.nonZero) {
      ScrollAbility ability = _getElementMovementAbility(element, movement);
      MovementDetails localMovement = _constrainMovementByAbility(ability, movement);
      if (localMovement.direction.nonZero) {
        return _scrollElement(element, localMovement);
      }
    }
    return null;
  }

  ScrollAbility _getElementMovementAbility(Element element, MovementDetails movement) {
    ScrollAbility ability = _getElementScrollAbility(element);
    bool abilityX = ability.horizontal;
    bool abilityY = ability.vertical;

    if (abilityX) {
      abilityX = _canMoveInDirection(movement.direction.x, element.scrollLeft, element.scrollWidth, element.clientWidth);
    }
    if (abilityY) {
      abilityY = _canMoveInDirection(movement.direction.y, element.scrollTop, element.scrollHeight, element.clientHeight);
    }
    return new ScrollAbility(horizontal: abilityX, vertical: abilityY);
  }

  ScrollAbility _getElementScrollAbility(Element element) {
    CssStyleDeclaration style = element.getComputedStyle();
    return new ScrollAbility(
      horizontal: _isScrollableStyleValue(style.overflowX) && element.scrollWidth != element.clientWidth,
      vertical: _isScrollableStyleValue(style.overflowY) && element.scrollHeight != element.clientHeight
    );
  }

  bool _isScrollableStyleValue(String value) => _CSS_OVERFLOW_SCROLLABLE_VALUES.contains(value?.toLowerCase());

  bool _canMoveInDirection(MovementDirectionType direction, num scrollOffset, num scrollSize, num viewSize) {
    if (direction == MovementDirectionType.positive) {
      return (scrollOffset + viewSize) < scrollSize;
    }
    else if (direction == MovementDirectionType.negative) {
      return scrollOffset > 0;
    }
    return false;
  }

  MovementDetails _constrainMovementByAbility(ScrollAbility ability, MovementDetails movement) {
    return new MovementDetails(
      movement.position,
      new MovementDirection(
        ability.horizontal ? movement.direction.x : MovementDirectionType.zero,
        ability.vertical ? movement.direction.y : MovementDirectionType.zero
      )
    );
  }

  ScrollAbility _scrollElement(Element element, MovementDetails movement) {
    Point<num> scrollStep = _calculateScrollStep(element, movement);
    bool moveX = scrollStep.x != 0;
    bool moveY = scrollStep.y != 0;
    if (moveX || moveY) {
      _allowedElements.add(element);
      element.style.scrollBehavior = 'unset';
      _scheduleElementScrollAnimation(element, _calculateAnimationScrollStep(scrollStep));
    }
    return new ScrollAbility(horizontal: moveX, vertical: moveY);
  }

  Point<num> _calculateScrollStep(Element element, MovementDetails movement) {
    Rectangle<num> rect = _getElementPageClientRect(element);
    return new Point(
      _calculateDirectionalStep(element.clientWidth, rect.left, rect.left + rect.width, movement.position.x, movement.direction.x),
      _calculateDirectionalStep(element.clientHeight, rect.top, rect.top + rect.height, movement.position.y, movement.direction.y)
    );
  }

  Rectangle<num> _getElementPageClientRect(Element element) {
    Rectangle<num> rect = element.getBoundingClientRect();
    return new Rectangle<num>(rect.left + window.scrollX, rect.top + window.scrollY, rect.width, rect.height);
  }

  num _calculateDirectionalStep(num viewArea, num minBound, num maxBound, num cursorPosition, MovementDirectionType movementDirection) {
    num activationArea = _calculateScrollActivationArea(viewArea);
    num offsetInActivationArea;
    num step = 0;

    if (movementDirection == MovementDirectionType.positive) {
      if (cursorPosition < maxBound && cursorPosition > (maxBound - activationArea)) {
        offsetInActivationArea = maxBound - cursorPosition;
      }
    }
    else if (movementDirection == MovementDirectionType.negative) {
      if (cursorPosition > minBound && cursorPosition < (minBound + activationArea)) {
        offsetInActivationArea = cursorPosition - minBound;
      }
    }

    if (offsetInActivationArea != null) {
      step = (offsetInActivationArea + (offsetInActivationArea / activationArea)) * movementDirection.sign;
    }
    return step;
  }

  num _calculateScrollActivationArea(num viewArea) {
    num sideArea = viewArea ~/ 3;
    num area = sideArea.clamp(_options.minScrollAreaSize, _options.maxScrollAreaSize);
    return max(area, 1);
  }

  Point<int> _calculateAnimationScrollStep(Point<num> scrollStep) {
    return new Point(
      _calculateMaxFrameStep(scrollStep.x).toInt(),
      _calculateMaxFrameStep(scrollStep.y).toInt()
    );
  }

  num _calculateMaxFrameStep(num step) {
    return step.sign * ( min(_options.maxScrollStep, step.abs()) / (max(_options.animationFrameDuration, 1))).ceil();
  }

  void _scheduleElementScrollAnimation(Element element, Point<int> step) {
    if (!_allowedElements.contains(element)) {
      return;
    }
    _animations[element] = window.requestAnimationFrame((num timestamp) {
      if (_updateElementScrollPosition(element, step)) {
        _scheduleElementScrollAnimation(element, step);
      }
    });
  }

  bool _updateElementScrollPosition(Element element, Point<int> step) {
    int scrollLeft = element.scrollLeft;
    int scrollTop = element.scrollTop;
    element.scrollLeft = scrollLeft + step.x;
    element.scrollTop = scrollTop + step.y;
    return element.scrollLeft != scrollLeft || element.scrollTop != scrollTop;
  }

  Element _getParentElement(el) {
    return el == _scrollContainer ? null : _getNonRestrictedParentElement(el);
  }

  Element _getNonRestrictedParentElement(Element element) {
    return element.parentNode == document ? null : element.parent;
  }

  bool isElementAnimated(Element element) {
    return _animations.containsKey(element);
  }

  bool hasActiveAnimations() {
    return _animations.keys.isNotEmpty;
  }

  void cancelElementAnimation(Element element) {
    _allowedElements.remove(element);
    _animations.remove(element);
  }

  void _cancelAnimations() {
    _allowedElements.clear();
    _animations.clear();
  }

  void setEnabled(bool isEnabled) {
    _isEnabled = isEnabled;
    if (!_isEnabled) {
      reset();
    }
  }

  void reset() {
    _lastMovement = null;
    _lastStartElement = null;
    _cancelAnimations();
  }
}

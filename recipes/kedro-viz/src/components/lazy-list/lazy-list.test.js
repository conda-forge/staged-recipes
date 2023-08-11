import React from 'react';
import LazyList, {
  range,
  rangeUnion,
  rangeEqual,
  thresholds,
} from './lazy-list';
import { setup } from '../../utils/state.mock';

describe('LazyList', () => {
  it('renders expected visible child items with padding for non-visible items', () => {
    // Settings for all test items
    const itemCount = 500;
    const itemHeight = 30;

    // The specific range of items to make visible in this test
    const visibleStart = 10;
    const visibleEnd = 40;
    const visibleCount = visibleEnd - visibleStart;

    // Configure test to include some clipping and scroll conditions
    const test = setupTest({
      itemCount,
      itemHeight,
      visibleCount,
      // Viewport to fit exactly desired number of visible items
      viewportHeight: itemHeight * visibleCount,
      // Container larger than viewport to test clipping
      containerHeight: itemHeight * visibleCount * 2,
      // Container scrolled half way to desired start item to test
      containerScrollY: itemHeight * visibleStart * 0.5,
      // Viewport scrolled remaining half way to desired start item
      viewportScrollY: itemHeight * visibleStart * 0.5,
    });

    const wrapper = setup.mount(
      <LazyList
        buffer={0}
        dispose={true}
        height={test.itemHeights}
        total={test.items.length}
        container={(element) => element?.parentElement}
      >
        {test.listRender}
      </LazyList>
    );

    // Generate expected items text for visible range
    const expectedItemsText = Array.from(
      { length: visibleCount },
      (_, i) => `Item ${visibleStart + i}`
    );

    // Get actual rendered items text
    const actualItemsText = wrapper
      .find('.test-item')
      .map((element) => element.text());

    // Test the items are exactly as expected
    expect(actualItemsText).toEqual(expectedItemsText);

    // Sanity check that not all items were rendered
    expect(actualItemsText.length).toBe(visibleCount);
    expect(actualItemsText.length).toBeLessThan(itemCount);

    // Test element pads the remaining non-visible items
    const listElementStyle = wrapper.find('.test-list').get(0).props.style;
    expect(listElementStyle.paddingTop).toBe(visibleStart * itemHeight);
    expect(listElementStyle.height).toBe(itemCount * itemHeight);
  });

  it('range(from, to, min, max) returns [max(from, min), min(to, max)]', () => {
    expect(range(0, 1, 0, 1)).toEqual([0, 1]);
    expect(range(-1, 1, 0, 1)).toEqual([0, 1]);
    expect(range(-1, 2, 0, 1)).toEqual([0, 1]);
  });

  it('rangeUnion(a, b) returns [min(a[0], b[0]), max(a[1], b[1])]', () => {
    expect(rangeUnion([3, 7], [2, 10])).toEqual([2, 10]);
    expect(rangeUnion([2, 10], [3, 7])).toEqual([2, 10]);
    expect(rangeUnion([1, 7], [2, 10])).toEqual([1, 10]);
    expect(rangeUnion([3, 11], [2, 10])).toEqual([2, 11]);
    expect(rangeUnion([1, 11], [2, 10])).toEqual([1, 11]);
  });

  it('rangeEqual(a, b) returns true if a[0] = b[0] && a[1] = b[1]', () => {
    expect(rangeEqual([1, 2], [1, 2])).toBe(true);
    expect(rangeEqual([1, 2], [1, 3])).toBe(false);
    expect(rangeEqual([1, 2], [3, 1])).toBe(false);
  });

  it('thresholds(t) returns [0, ...n / t] except t = `0` returns `[0]`', () => {
    expect(thresholds(0)).toEqual([0]);
    expect(thresholds(1)).toEqual([0, 1]);
    expect(thresholds(2)).toEqual([0, 1 / 2, 1]);
    expect(thresholds(3)).toEqual([0, 1 / 3, 2 / 3, 1]);
    expect(thresholds(4)).toEqual([0, 1 / 4, 2 / 4, 3 / 4, 1]);
  });
});

// Sets up the test data and environment
const setupTest = ({
  itemCount,
  itemHeight,
  visibleCount,
  viewportHeight,
  viewportScrollY,
  containerHeight,
  containerScrollY,
}) => {
  // Generate test data and settings
  const items = Array.from({ length: itemCount }, (_, i) => i);
  const itemHeights = (start, end) => (end - start) * itemHeight;
  const itemWidth = itemHeight * 5;
  const containerWidth = itemWidth;
  const listWidth = itemWidth;

  // List render function
  const listRender = ({
    start,
    end,
    listRef,
    upperRef,
    lowerRef,
    listStyle,
    upperStyle,
    lowerStyle,
  }) => (
    <>
      {/* Scroll container */}
      <div
        style={{
          overflowY: 'scroll',
          height: containerHeight,
          width: containerWidth,
        }}
      >
        {/* List container */}
        <ul
          className="test-list"
          ref={listRef}
          style={{ ...listStyle, width: listWidth }}
        >
          {/* Upper placeholder */}
          <li ref={upperRef} style={upperStyle} />
          {/* Lower placeholder */}
          <li ref={lowerRef} style={lowerStyle} />
          {/* List items in visible range */}
          {items.slice(start, end).map((i) => (
            <li key={i} className="test-item">
              Item {i}
            </li>
          ))}
        </ul>
      </div>
    </>
  );

  // Emulate the browser window viewport height
  window.innerHeight = viewportHeight;

  // Emulate RAF with immediate callback
  window.requestAnimationFrame = (callback) => callback(0);

  // Emulate IntersectionObserver with immediate callback
  window.IntersectionObserver = function (callback) {
    return {
      observe: () => callback(),
      disconnect: () => null,
    };
  };

  // Gets the React instance for a React node
  const getInstance = (node) => {
    const key = Object.keys(node).find((key) => key.startsWith('__reactFiber'));
    return node[key];
  };

  // Emulate element bounds as if rendered
  window.Element.prototype.getBoundingClientRect = function () {
    const instance = getInstance(this);

    // Check which element this is (list or container)
    const isList = instance?.type === 'ul';

    // Set by `style` in `listRender`
    const width = Number.parseInt(this.style.width) || 0;
    const height = Number.parseInt(this.style.height) || 0;

    // Find offset for viewport scroll and container scroll
    const offsetY = -viewportScrollY - (isList ? containerScrollY : 0);

    // Return bounds in screen space as expected
    return {
      x: 0,
      y: offsetY,
      top: offsetY,
      bottom: offsetY + height,
      left: 0,
      right: width,
      width: width,
      height: height,
    };
  };

  // Return the test setup
  return {
    items,
    visibleCount,
    itemHeights,
    listRender,
  };
};

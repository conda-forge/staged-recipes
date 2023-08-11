import { useState, useLayoutEffect, useRef, useMemo, useCallback } from 'react';

/**
 * A component that renders only the children currently visible on screen.
 * Renders all children if not supported by browser or is disabled via the `lazy` prop.
 * @param {Function} height A `function(start, end)` returning the pixel height for any given range of items
 * @param {Number} total The total count of all items in the list
 * @param {Function} children A `function(props)` rendering the list and items (see `childProps`)
 * @param {?Number} [buffer=0.5] A number [0...1] as a % of the visible region to render additionally
 * @param {?Boolean} [lazy=true] Toggles the lazy functionality
 * @param {?Boolean} [dispose=false] Toggles disposing items when they lose visibility
 * @param {?Function} onChange Optional change callback
 * @param {?Function} container Optional, default scroll container is `element.offsetParent`
 * @return {Object} The rendered children
 **/
const LazyList = ({
  height,
  total,
  children,
  lazy = true,
  dispose = false,
  buffer = 0.5,
  onChange,
  container = (element) => element?.offsetParent,
}) => {
  // Required browser feature checks
  const supported = typeof window.IntersectionObserver !== 'undefined';

  // Active only if supported and enabled else renders all children
  const active = lazy && supported;

  // The range of items currently rendered
  const [range, setRange] = useState([0, 0]);
  const rangeRef = useRef([0, 0]);

  // List container element
  const listRef = useRef();

  // Upper placeholder element
  const upperRef = useRef();

  // Lower placeholder element
  const lowerRef = useRef();

  // Height of a single item
  const itemHeight = useMemo(() => height(0, 1), [height]);

  // Height of all items
  const totalHeight = useMemo(() => height(0, total), [height, total]);

  // Height of items above the rendered range
  const upperHeight = useMemo(() => height(0, range[0]), [height, range]);

  // Height of items below the rendered range
  const lowerHeight = useMemo(
    () => height(range[1], total),
    [height, range, total]
  );

  // Allows an update only once per frame
  const requestUpdate = useRequestFrameOnce(
    // Memoise the frame callback
    useCallback(() => {
      // Get the range of items visible in this frame
      const visibleRange = visibleRangeOf(
        // The list container
        listRef.current,
        // The list's scrolling parent container
        container(listRef.current),
        buffer,
        total,
        itemHeight
      );

      // Merge ranges
      const effectiveRange =
        // If dispose, render visible range only
        dispose
          ? visibleRange
          : // If not dispose, expand current range with visible range
            rangeUnion(rangeRef.current, visibleRange);

      // Avoid duplicate render calls as state is not set immediate
      if (!rangeEqual(rangeRef.current, effectiveRange)) {
        // Store the update in a ref immediately
        rangeRef.current = effectiveRange;

        // Apply the update in the next render
        setRange(effectiveRange);
      }
    }, [buffer, total, itemHeight, dispose, container])
  );

  // Memoised observer options
  const observerOptions = useMemo(
    () => ({
      // Create a threshold point for every item
      threshold: thresholds(total),
    }),
    [total]
  );

  // Updates on changes in visibility at the given thresholds (intersection ratios)
  useIntersection(listRef, observerOptions, requestUpdate);
  useIntersection(upperRef, observerOptions, requestUpdate);
  useIntersection(lowerRef, observerOptions, requestUpdate);

  // Updates on changes in item dimensions
  useLayoutEffect(
    () => requestUpdate(),
    [total, itemHeight, totalHeight, requestUpdate]
  );

  // Memoised child props for user to apply as needed
  const childProps = useMemo(
    () => ({
      listRef,
      upperRef,
      lowerRef,
      total,
      start: active ? range[0] : 0,
      end: active ? range[1] : total,
      listStyle: {
        // Relative for placeholder positioning
        position: 'relative',
        // List must always have the correct height
        height: active ? totalHeight : undefined,
        // List must always pad missing items (upper at least)
        paddingTop: active ? upperHeight : undefined,
      },
      upperStyle: {
        position: 'absolute',
        display: !active ? 'none' : undefined,
        height: upperHeight,
        width: '100%',
        // Upper placeholder must always snap to top edge
        top: '0',
      },
      lowerStyle: {
        position: 'absolute',
        display: !active ? 'none' : undefined,
        height: lowerHeight,
        width: '100%',
        // Lower placeholder must always snap to bottom edge
        bottom: '0',
      },
    }),
    [
      active,
      range,
      total,
      listRef,
      upperRef,
      lowerRef,
      totalHeight,
      upperHeight,
      lowerHeight,
    ]
  );

  // Optional change callback
  onChange && onChange(childProps);

  // Render the children
  return children(childProps);
};

/**
 * Returns a range in the form `[start, end]` clamped inside `[min, max]`
 * @param {Number} start The start of the range
 * @param {Number} end The end of the range
 * @param {Number} min The range minimum
 * @param {Number} max The range maximum
 * @returns {Array} The clamped range
 */
export const range = (start, end, min, max) => [
  Math.max(Math.min(start, max), min),
  Math.max(Math.min(end, max), min),
];

/**
 * Returns the union of both ranges
 * @param {Array} rangeA The first range `[start, end]`
 * @param {Array} rangeB The second range `[start, end]`
 * @returns {Array} The range union
 */
export const rangeUnion = (rangeA, rangeB) => [
  Math.min(rangeA[0], rangeB[0]),
  Math.max(rangeA[1], rangeB[1]),
];

/**
 * Returns true if the ranges have the same `start` and `end` values
 * @param {Array} rangeA The first range `[start, end]`
 * @param {Array} rangeB The second range `[start, end]`
 * @returns {Boolean} True if ranges are equal else false
 */
export const rangeEqual = (rangeA, rangeB) =>
  rangeA[0] === rangeB[0] && rangeA[1] === rangeB[1];

/**
 * Gets the range of items inside the container's screen bounds.
 * Assumes a single fixed height for all child items.
 * Only considers visibility along the vertical y-axis (i.e. only top, bottom bounds).
 * @param {HTMLElement} element The target element (e.g. list container)
 * @param {?HTMLElement} container The clipping container of the target (e.g. scroll container)
 * @param {Number} buffer A number [0...1] as a % of the container to render additionally
 * @param {Number} childTotal The total count of all children in the target (e.g. list row count)
 * @param {Number} childHeight Height of a single child element (e.g. height of one list row)
 * @returns {Array} The calculated range of visible items as `[start, end]`
 */
const visibleRangeOf = (
  element,
  container,
  buffer,
  childTotal,
  childHeight
) => {
  // Check element exists
  if (!element) {
    return [0, 0];
  }

  // If no container use the element itself
  if (!container) {
    container = element;
  }

  // Find the clipping container bounds (e.g. scroll container)
  const clip = container.getBoundingClientRect();

  // Find element bounds (e.g. list container inside scroll container)
  const list = element.getBoundingClientRect();

  // Find the number of items to buffer
  const bufferCount = Math.ceil((buffer * clip.height) / childHeight);

  // When clip is fully above viewport or element is fully above clip
  if (clip.bottom < 0 || list.bottom < clip.top) {
    // Only bottom part of the buffer in range
    return range(childTotal - bufferCount, childTotal, 0, childTotal);
  }

  // Get the viewport bounds
  const viewport = {
    top: 0,
    bottom: window.innerHeight || document.documentElement.clientHeight,
  };

  // When clip is fully below viewport or element is fully below clip
  if (clip.top > viewport.bottom || list.top > clip.bottom) {
    // Only top part of the buffer in range
    return range(0, bufferCount, 0, childTotal);
  }

  // Find intersection of clip and viewport now overlap guaranteed
  const top = Math.max(clip.top, viewport.top);
  const bottom = Math.min(clip.bottom, viewport.bottom);

  // Find unbounded item range within the intersection
  const start = Math.floor((top - list.top) / childHeight);
  const end = Math.ceil((bottom - list.top) / childHeight);

  // Apply buffer and clamp unbounded range to list bounds
  return range(start - bufferCount, end + bufferCount, 0, childTotal);
};

/**
 * A hook to create a callback that runs once, at the end of the frame
 * @param {Function} callback The callback
 * @returns {Function} The wrapped callback
 */
const useRequestFrameOnce = (callback) => {
  const request = useRef();

  // Allow only a single callback per-frame
  return useCallback(() => {
    cancelAnimationFrame(request.current);
    request.current = requestAnimationFrame(callback);
  }, [request, callback]);
};

/**
 * Generates an array of the form [0, ...n / total]
 * except where total is `0` where it returns `[0]`.
 * @param {Number} total The total number of thresholds to create
 * @returns {Array} The threshold array
 */
export const thresholds = (total) =>
  total === 0
    ? [0]
    : [...Array.from({ length: total }, (_, i) => i / total), 1];

/**
 * A hook that creates and manages an IntersectionObserver for the given element
 * @param {Object} element A React.Ref from the target element
 * @param {Object} options An IntersectionObserver options object
 * @param {Function} callback A function to call with IntersectionObserver changes
 */
const useIntersection = (element, options, callback) => {
  const observer = useRef();

  // After rendering and layout
  return useLayoutEffect(() => {
    // Check the element is ready
    if (!element.current) {
      return;
    }

    // Dispose any previous observer
    if (observer.current) {
      observer.current.disconnect();
    }

    // Create a new observer if supported
    if (window.IntersectionObserver) {
      observer.current = new window.IntersectionObserver(callback, options);
      observer.current.observe(element.current);
    }

    // Manually callback as element may already be visible
    callback();
  }, [callback, element, options]);
};

export default LazyList;

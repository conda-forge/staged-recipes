import 'd3-transition';
import { select } from 'd3-selection';
import { interpolate } from 'd3-interpolate';
import { zoom as d3Zoom, zoomIdentity, zoomTransform } from 'd3-zoom';

/**
 * Applies an active viewport behaviour on the given elements using d3-zoom.
 * Returns an object representing the view for use in view related functions.
 * @param {Object} options The options to use
 * @param {React.Ref} options.container The container element ref
 * @param {React.Ref} options.wrapper The wrapper element ref
 * @param {?Function} options.onViewChanged Callback when view changes
 * @param {?Function} options.onViewEnd Callback when view change ends
 * @param {?Boolean} [options.allowUserInput=true] Enable or disable user input
 * @returns {Object} An object representing the view
 */
export const viewing = ({
  container,
  wrapper,
  onViewChanged,
  onViewEnd,
  allowUserInput = true,
}) => {
  const zoom = d3Zoom()
    .on('zoom', (event) => {
      const transform = event.transform;

      // Ignore invalid transforms
      if (isInvalidTransform(transform)) {
        return;
      }

      select(wrapper.current).attr('transform', transform);
      onViewChanged && onViewChanged(transform);
    })
    .on('end', onViewEnd)
    // Use linear interpolation
    .interpolate(interpolate);

  if (!allowUserInput) {
    // Ignore all user input default behaviour
    zoom.filter(() => false);
  }

  select(container.current)
    .call(zoom)
    // Disable default double click to avoid conflicts
    .on('dblclick.zoom', null);

  return {
    zoom,
    container,
    wrapper,
  };
};

/**
 * A constant for the origin transform { x: 0, y: 0, k: 1 }
 */
export const origin = zoomIdentity;

/**
 * Returns true if the transform is equivalent to the origin { x: 0, y: 0, k: 1 }
 * @param {Object} transform A transform object to test
 * @returns {Boolean} True if equivalent else false
 */
export const isOrigin = ({ x, y, k }) =>
  x === origin.x && y === origin.y && k === origin.k;

/**
 * Returns true if the transform meets this definition:
 *  - any component (x, y or k) is infinite, `NaN` or `undefined`
 * otherwise returns false.
 * @param {Object} transform A transform object to test
 * @returns {Boolean} True if the transform is invalid else false
 */
export const isInvalidTransform = ({ x, y, k }) =>
  !isFinite(x + y + k) || isNaN(x + y + k) || (x === 0 && y === 0 && k === 0);

/**
 * Returns the current transform of the given view.
 * This is equivalent to the container CSS transform but negated.
 * @param {Object} view The view
 * @returns {Object} The view transform
 */
export const getViewTransform = (view) => {
  const transform = zoomTransform(view.wrapper.current);
  return isInvalidTransform(transform) ? origin : negateTransform(transform);
};

/**
 * Negates the x and y components, in effect making the direction opposite.
 * Scale component does not change. Zeroes are always positive.
 * @private
 * @param {Object} transform The transform to negate
 * @returns {Object} The new transform
 */
const negateTransform = (transform) =>
  // This ensures +0 instead of -0
  origin.translate(-transform.x || 0, -transform.y || 0).scale(transform.k);

/**
 * Sets the extents of the given view.
 * Translate and scale extents may be provided individually.
 * @param {Object} view The view
 * @param {Object} extents The exents
 */
export const setViewExtents = (view, { translate, scale }) => {
  if (translate) {
    const { minX, minY, maxX, maxY } = translate;
    view.zoom.translateExtent([
      [minX, minY],
      [maxX, maxY],
    ]);
  }

  if (scale) {
    const { minK, maxK } = scale;
    view.zoom.scaleExtent([minK, maxK]);
  }
};

/**
 * Gets the extents of the given view including both translate and scale.
 * @param {Object} view The view
 * @returns {Object} The view extents
 */
export const getViewExtents = (view) => {
  const scale = view.zoom.scaleExtent();
  const translate = view.zoom.translateExtent();
  return {
    translate: {
      minX: translate[0][0],
      minY: translate[0][1],
      maxX: translate[1][0],
      maxY: translate[1][1],
    },
    scale: { minK: scale[0], maxK: scale[1] },
  };
};

/**
 * Gets the bounds of the viewport.
 * By default this retrieves the container element dimensions unless an alternative viewport is set.
 * @param {Object} view The view
 * @returns {Object} The viewport extents
 */
export const getViewport = (view) => {
  const viewport = view.zoom.extent()(select(view.container.current));
  return {
    top: viewport[0][1],
    left: viewport[0][0],
    bottom: viewport[1][1],
    right: viewport[1][0],
  };
};

/**
 * Sets the bounds of the viewport instead of using container element dimensions.
 * @param {Object} view The view
 * @param {Object} viewport The viewport bounds
 */
export const setViewport = (view, viewport) => {
  view.zoom.extent([
    [viewport.left, viewport.top],
    [viewport.right, viewport.bottom],
  ]);
};

/**
 * Sets the view transform on the view with optional transition.
 * Always respects the view extent constraints.
 * Translate and scale components may be provided individually.
 * Transform is absolute unless relative option set, where it will be added.
 * @param {Object} view The view
 * @param {Object} transform The transform to set on the view
 * @param {?Number} [duration=0] The transition duration (or 0 for none)
 * @param {?Boolean} [relative=false] When true, transform added to current transform
 */
export const setViewTransform = (
  view,
  transform,
  duration = 0,
  relative = false
) => {
  const container = select(view.container.current);
  const current = getViewTransform(view);
  const hasTranslation =
    typeof transform.x !== 'undefined' && typeof transform.y !== 'undefined';
  let k, x, y;

  if (typeof jest !== 'undefined') {
    // Transitions not supported in tests
    duration = 0;
  }

  if (relative) {
    // Relative: v' = v + t
    k = current.k + (transform.k || 0);
    x = current.x + (transform.x || 0);
    y = current.y + (transform.y || 0);
  } else {
    // Absolute: v' = t
    k = transform.k || current.k;
    x = transform.x || current.x;
    y = transform.y || current.y;
  }

  // Only translate if requested to avoid scale offset
  if (hasTranslation) {
    // Apply translation respecting extents
    container.call(view.zoom.transform, origin);
    container.call(view.zoom.translateTo, x / k, y / k);
  }

  // Apply scale respecting extents
  container.call(view.zoom.scaleTo, k);

  // If the update requires a transition
  if (duration) {
    // Store the already computed final transform
    const final = getViewTransform(view);

    // Revert to the initial transform
    container.call(view.zoom.transform, negateTransform(current));

    // Transition to the final transform
    setViewTransformExact(view, final, duration);
  }
};

/**
 * Sets the transform on the view with optional transition.
 * Ignores the view extent constraints.
 * The transform must be absolute containing both translate and scale components.
 * @param {Object} view The view
 * @param {Object} transform The transform to set on the view
 * @param {?Number} [duration=0] The transition duration (or 0 for none)
 */
export const setViewTransformExact = (view, transform, duration = 0) => {
  const container = select(view.container.current);

  // Convert transform
  const final = origin.translate(-transform.x, -transform.y).scale(transform.k);

  if (typeof jest !== 'undefined') {
    // Simulate application in tests
    view.container.current.__zoom = final;
    return;
  }

  // Apply the transform ignoring extents
  (!duration
    ? container
    : container.transition('zoom').duration(duration)
  ).call(view.zoom.transform, final);
};

/**
 * Returns a view transform that fits the object dimensions
 * and optional focus point inside the given view dimensions,
 * while respecting a minimum desired scale.
 * @param {Object} options The options
 * @param {Object} options.offset The origin point
 * @param {?Object} options.focus The optional point to keep in focus
 * @param {Number} options.viewWidth The width of the viewport
 * @param {Number} options.viewHeight The height of the viewport
 * @param {Number} options.objectWidth The width of the object
 * @param {Number} options.objectHeight The height of the object
 * @param {?Number} [options.minScaleX=0] The minimum X scale
 * @param {?Number} [options.minScaleFocus=0] The minimum scale when focus given
 * @param {?Number} [options.focusOffset=0.8] Offset center towards relative focus position
 * @returns {Object} A view transform that fits the constraints
 */
export const viewTransformToFit = ({
  offset,
  focus,
  viewWidth,
  viewHeight,
  objectWidth,
  objectHeight,
  minScaleX = 0,
  minScaleFocus = 0,
  focusOffset = 0.8,
  preventZoom,
}) => {
  let scale = origin.k;
  let x = origin.x;
  let y = origin.y;

  // Get the scales that fit each axis
  const scaleY = viewHeight / objectHeight;
  const scaleX = viewWidth / objectWidth;

  // Apply a minimum to X but allow Y to fit
  const scaleXClamp = Math.max(minScaleX, scaleX);

  // To fit both axis, choose the smaller one
  scale = Math.min(scaleXClamp, scaleY);

  // If there is a focus point
  if (focus || !preventZoom) {
    // Ensure scale is a reasonable size
    scale = Math.max(minScaleFocus, scale);
  }

  // Offset the origin
  x += offset.x;
  y += offset.y;

  // Offset to center whole object
  x += (viewWidth - objectWidth * scale) * 0.5;
  y += (viewHeight - objectHeight * scale) * 0.5;

  // When there is a focus point set
  if (focus) {
    // Find which axes would become cropped
    const isCroppedX = viewWidth < objectWidth * scale;
    const isCroppedY = viewHeight < objectHeight * scale;

    const objectCenterX = objectWidth * 0.5;
    const objectCenterY = objectHeight * 0.5;

    // Offset on the cropped axes only
    const focusCenterOffsetX = isCroppedX ? objectCenterX - focus.x : 0;
    const focusCenterOffsetY = isCroppedY ? objectCenterY - focus.y : 0;

    const focusRelativeOffsetX = focusCenterOffsetX / objectWidth;
    const focusRelativeOffsetY = focusCenterOffsetY / objectHeight;

    // Offset to exactly center on the selected focus
    x += focusCenterOffsetX * scale;
    y += focusCenterOffsetY * scale;

    // Adjust centering to better account for focus position
    x -= focusRelativeOffsetX * viewWidth * focusOffset;
    y -= focusRelativeOffsetY * viewHeight * focusOffset;
  }

  // This ensures +0 instead of -0
  return { x: -x || 0, y: -y || 0, k: scale };
};

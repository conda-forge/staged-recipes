import { useState, useRef } from 'react';

/**
 * Any React render function that returns elements, including those representing the container, panels and handle elements.
 * The state and props this function provides are expected to be applied these child elements to enable SplitPanel functionality.
 * See split-panel.test.js for a reference implementation.
 * @callback splitPanelRender
 * @param {Object} state An object that contains a copy of the current split panel state and props intended for children
 * @param {Boolean} state.isResizing Is `true` when the split is being actively moved, otherwise `false`
 * @param {Number} state.split A number [0...1] as the current % split position
 * @param {Object} state.props.container The props intended for the panel container element(s)
 * @param {Object} state.props.panelA The props intended for the first panel descendent element(s)
 * @param {Object} state.props.panelB The props intended for the second panel descendent element(s)
 * @param {Object} state.props.handle The props intended for the handle descendent element(s)
 **/

/**
 * A design agnostic user-resizable split panel controller.
 * Pass any React render function as this component's children and return your elements there.
 * See split-panel.test.js for a reference implementation.
 * @param {splitPanelRender} children Any React render function that returns elements including representing the container, panels, handle
 * @param {?Number} [splitDefault=0.65] A number [0...1] as the default % split position
 * @param {?Number} [splitMin=0] A number [0...1] as the minimum % split position
 * @param {?Number} [splitMax=1] A number [0...1] as the maximum % split position
 * @param {?Number} [keyboardStep=0.025] A number [0...1] as the % step to move split when using keyboard
 * @param {?String} [orientation='vertical'] Only 'vertical' currently supported
 **/
export const SplitPanel = ({
  splitDefault = 0.65,
  splitMin = 0,
  splitMax = 1,
  keyboardStep = 0.025,
  orientation = 'vertical',
  children,
}) => {
  const containerRef = useRef();
  const handleRef = useRef();

  const getRects = () => ({
    container: containerRef.current?.getBoundingClientRect(),
    handle: handleRef.current?.getBoundingClientRect(),
  });

  const clamp = (splitValue) => {
    const rects = getRects();

    const handleSize = rects.handle
      ? rects.handle.height / rects.container.height
      : 0;

    if (splitValue < splitMin) {
      return splitMin;
    }

    if (splitValue > splitMax - handleSize) {
      return splitMax - handleSize;
    }

    return splitValue;
  };

  const [isResizing, setIsResizing] = useState(false);
  const [split, setSplit] = useState(clamp(splitDefault));

  const onMouse = (event) => {
    if (event.type === 'mouseup') {
      setIsResizing(false);
      return;
    }

    if (isResizing || event.type === 'mousedown') {
      const rects = getRects();

      const mouseOffsetVertical =
        (event.clientY - rects.container.top - rects.handle.height * 0.5) /
        rects.container.height;

      setIsResizing(true);
      setSplit(clamp(mouseOffsetVertical));

      event.preventDefault();
    }
  };

  const onKey = (event) => {
    const keyboardOffset =
      {
        ArrowUp: -keyboardStep,
        ArrowLeft: -keyboardStep,
        ArrowDown: keyboardStep,
        ArrowRight: keyboardStep,
      }[event.key] || 0;

    if (keyboardOffset) {
      setSplit(clamp(split + keyboardOffset));
      event.preventDefault();
    }
  };

  return children({
    isResizing,
    split,
    props: {
      container: {
        ref: containerRef,
        onMouseMove: onMouse,
        onMouseUp: onMouse,
      },
      panelA: { style: { height: split * 100 + '%' } },
      panelB: { style: { height: (1 - split) * 100 + '%' } },
      handle: {
        ref: handleRef,
        role: 'separator',
        'aria-orientation': orientation,
        tabIndex: '0',
        onMouseUp: onMouse,
        onMouseDown: onMouse,
        onKeyDown: onKey,
      },
    },
  });
};

export default SplitPanel;

import React from 'react';
import { setup } from '../../utils/state.mock';
import SplitPanel from './split-panel';

describe('SplitPanel', () => {
  const mockSplitPanel = (props) =>
    setup.mount(
      <SplitPanel {...props}>
        {({
          split,
          isResizing,
          props: { container, panelA, panelB, handle },
        }) => (
          <div
            className="split-panel__container"
            data-is-resizing={isResizing}
            data-split={split}
            {...container}
          >
            <div className="split-panel__panel-a" {...panelA} />
            <div className="split-panel__handle" {...handle} />
            <div className="split-panel__panel-b" {...panelB} />
          </div>
        )}
      </SplitPanel>
    );

  const mockBoundingRects = (rects) => {
    // Gets the React instance className for a React node
    const getInstanceClassName = (node) => {
      const key = Object.keys(node).find((key) =>
        key.startsWith('__reactFiber')
      );
      return node[key].memoizedProps.className;
    };

    // Emulate element bounds as if rendered
    window.Element.prototype.getBoundingClientRect = function () {
      const className = getInstanceClassName(this);
      return rects[className];
    };

    return rects;
  };

  const container = (wrapper) => wrapper.find('.split-panel__container');
  const panelA = (wrapper) => wrapper.find('.split-panel__panel-a');
  const panelB = (wrapper) => wrapper.find('.split-panel__panel-b');
  const handle = (wrapper) => wrapper.find('.split-panel__handle');

  it('renders without crashing', () => {
    const wrapper = mockSplitPanel();

    expect(panelA(wrapper).exists()).toBe(true);
    expect(panelB(wrapper).exists()).toBe(true);
    expect(handle(wrapper).exists()).toBe(true);
  });

  it('moves the split when user mousedown, mousemove, mouseup on handle', () => {
    const mockRects = mockBoundingRects({
      'split-panel__container': {
        x: 0,
        y: 0,
        top: 0,
        left: 0,
        right: 100,
        bottom: 100,
        width: 100,
        height: 100,
      },
      'split-panel__handle': {
        x: 0,
        y: 0,
        top: 0,
        left: 0,
        right: 100,
        bottom: 100,
        width: 100,
        height: 0,
      },
    });

    const containerRect = mockRects['split-panel__container'];

    const splitDefault = 50;

    const wrapper = mockSplitPanel({
      splitDefault: splitDefault / 100,
      splitMin: 0,
      splitMax: 1,
    });

    // Check split is at default position and not resizing.
    expect(container(wrapper).prop('data-is-resizing')).toBe(false);
    expect(parseFloat(panelA(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault
    );
    expect(parseFloat(panelB(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault
    );

    // Simulate user mouse down on handle.
    handle(wrapper).simulate('mousedown', {
      type: 'mousedown',
      // Simulated mouse position.
      clientY: containerRect.height * 0.6,
    });

    // Check split has moved to mouse position and is resizing.
    expect(container(wrapper).prop('data-is-resizing')).toBe(true);
    expect(parseFloat(panelA(wrapper).prop('style').height)).toBeCloseTo(60);
    expect(parseFloat(panelB(wrapper).prop('style').height)).toBeCloseTo(40);

    // Simulate user mouse move on handle (after first mousedown).
    handle(wrapper).simulate('mousemove', {
      type: 'mousemove',
      // Simulated mouse position.
      clientY: containerRect.height * 0.7,
    });

    // Check split has moved to mouse position and is resizing.
    expect(container(wrapper).prop('data-is-resizing')).toBe(true);
    expect(parseFloat(panelA(wrapper).prop('style').height)).toBeCloseTo(70);
    expect(parseFloat(panelB(wrapper).prop('style').height)).toBeCloseTo(30);

    // Simulate user mouse up on handle (after first mousedown, mousemove).
    handle(wrapper).simulate('mouseup', {
      type: 'mouseup',
      // Simulated mouse position.
      clientY: containerRect.height * 0.7,
    });

    // Check split has not moved and is not resizing.
    expect(container(wrapper).prop('data-is-resizing')).toBe(false);
    expect(parseFloat(panelA(wrapper).prop('style').height)).toBeCloseTo(70);
    expect(parseFloat(panelB(wrapper).prop('style').height)).toBeCloseTo(30);
  });

  it('moves the split when user focuses handle and uses keyboard arrows', () => {
    const mockRects = mockBoundingRects({
      'split-panel__container': {
        x: 0,
        y: 0,
        top: 0,
        left: 0,
        right: 100,
        bottom: 100,
        width: 100,
        height: 100,
      },
      'split-panel__handle': {
        x: 0,
        y: 0,
        top: 0,
        left: 0,
        right: 100,
        bottom: 100,
        width: 100,
        height: 0,
      },
    });

    const containerRect = mockRects['split-panel__container'];
    const containerHeight = containerRect.height;

    const keyboardStep = 0.025;
    const splitDefault = 50;

    const wrapper = mockSplitPanel({
      splitDefault: splitDefault / 100,
      splitMin: 0,
      splitMax: 1,
      keyboardStep,
    });

    expect(parseFloat(panelA(wrapper).prop('style').height)).toBeCloseTo(50);
    expect(parseFloat(panelB(wrapper).prop('style').height)).toBeCloseTo(50);

    // Simulate user keyboard down arrow press.
    handle(wrapper).simulate('keydown', {
      type: 'keydown',
      key: 'ArrowDown',
    });

    // Check split has moved downwards.
    expect(parseFloat(panelA(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault + keyboardStep * containerHeight
    );
    expect(parseFloat(panelB(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault - keyboardStep * containerHeight
    );

    // Simulate user keyboard right arrow press.
    handle(wrapper).simulate('keydown', {
      type: 'keydown',
      key: 'ArrowRight',
    });

    // Check split has moved downwards.
    expect(parseFloat(panelA(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault + 2 * keyboardStep * containerHeight
    );
    expect(parseFloat(panelB(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault - 2 * keyboardStep * containerHeight
    );

    // Simulate user keyboard up arrow press.
    handle(wrapper).simulate('keydown', {
      type: 'keydown',
      key: 'ArrowUp',
    });

    // Check split has moved upwards.
    expect(parseFloat(panelA(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault + keyboardStep * containerHeight
    );
    expect(parseFloat(panelB(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault - keyboardStep * containerHeight
    );

    // Simulate user keyboard left arrow press.
    handle(wrapper).simulate('keydown', {
      type: 'keydown',
      key: 'ArrowUp',
    });

    // Check split has moved upwards.
    expect(parseFloat(panelA(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault
    );
    expect(parseFloat(panelB(wrapper).prop('style').height)).toBeCloseTo(
      splitDefault
    );
  });
});

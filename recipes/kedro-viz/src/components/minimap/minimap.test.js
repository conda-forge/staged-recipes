import React from 'react';
import MiniMap, { mapStateToProps, mapDispatchToProps } from './minimap';
import { mockState, setup } from '../../utils/state.mock';
import { getViewTransform, origin } from '../../utils/view';
import { getVisibleNodeIDs } from '../../selectors/disabled';

describe('MiniMap', () => {
  it('renders without crashing', () => {
    const svg = setup.mount(<MiniMap />).find('svg');
    expect(svg.length).toEqual(1);
    expect(svg.hasClass('pipeline-minimap__graph')).toBe(true);
  });

  it('renders nodes with D3', () => {
    const wrapper = setup.mount(<MiniMap />);
    const nodes = wrapper.render().find('.pipeline-minimap-node');
    const mockNodes = getVisibleNodeIDs(mockState.spaceflights);
    expect(nodes.length).toEqual(mockNodes.length);
  });

  it('a transform to fit the graph in container was applied', () => {
    const wrapper = setup.mount(<MiniMap />);
    const instance = wrapper.find('MiniMap').instance();
    const viewTransform = getViewTransform(instance.view);

    // Sanity checks only due to limited test environment
    // View logic is directly covered in view utility tests

    // Should not be the default transform
    expect(viewTransform).not.toEqual(origin);

    // Should have offset
    expect(viewTransform.x).toBeLessThan(0);
    expect(viewTransform.y).toBeLessThan(0);

    // Should have scaled
    expect(viewTransform.k).toBeLessThan(1);
    expect(viewTransform.k).toBeGreaterThan(0);
  });

  it('does not update nodes when not visible', () => {
    const wrapper = setup.mount(<MiniMap visible={false} />);
    const nodes = wrapper.render().find('.pipeline-minimap-node');
    expect(nodes.length).toEqual(0);
  });

  it('adds and removes global wheel event handler', () => {
    const windowEvents = {};
    window.addEventListener = jest.fn(
      (event, callback) => (windowEvents[event] = callback)
    );
    window.removeEventListener = jest.fn((event) => delete windowEvents[event]);

    const wrapper = setup.mount(<MiniMap />);
    expect(() => windowEvents.wheel({ target: null })).not.toThrow();
    wrapper.unmount();
    expect(windowEvents.wheel).toBeUndefined();
  });

  it('adds and removes global pointer event handler when supported', () => {
    const windowEvents = {};
    window.addEventListener = jest.fn(
      (event, callback) => (windowEvents[event] = callback)
    );
    window.removeEventListener = jest.fn((event) => delete windowEvents[event]);
    window.PointerEvent = {};

    const wrapper = setup.mount(<MiniMap />);
    expect(windowEvents.mouseup).toBeUndefined();
    expect(() => windowEvents.pointerup()).not.toThrow();
    wrapper.unmount();
    expect(windowEvents.pointerup).toBeUndefined();
  });

  it('adds and removes global mouse event handler when pointer events not supported', () => {
    const windowEvents = {};
    window.addEventListener = jest.fn(
      (event, callback) => (windowEvents[event] = callback)
    );
    window.removeEventListener = jest.fn((event) => delete windowEvents[event]);
    window.PointerEvent = null;

    const wrapper = setup.mount(<MiniMap />);
    expect(windowEvents.mouseup).toBeDefined();
    expect(() => windowEvents.mouseup()).not.toThrow();
    wrapper.unmount();
    expect(windowEvents.mouseup).toBeUndefined();
  });

  it('updates chart zoom x and y when mouse down and mouse moves on minimap', () => {
    const onUpdateChartZoom = jest.fn();
    const wrapper = setup.mount(
      <MiniMap onUpdateChartZoom={onUpdateChartZoom} />
    );
    const container = wrapper.find('.pipeline-minimap');
    const mouseEvent = () => ({ clientX: 5, clientY: 10 });
    container.simulate('mouseenter', mouseEvent());
    container.simulate('mousedown', mouseEvent());
    container.simulate('mousemove', mouseEvent());
    container.simulate('mouseleave', mouseEvent());
    expect(onUpdateChartZoom).toHaveBeenLastCalledWith({
      x: expect.any(Number),
      y: expect.any(Number),
      scale: expect.any(Number),
      applied: expect.any(Boolean),
      transition: expect.any(Boolean),
      relative: expect.any(Boolean),
    });
  });

  it('updates chart zoom scale when mouse wheel moves on minimap', () => {
    const onUpdateChartZoom = jest.fn();
    const wrapper = setup.mount(
      <MiniMap onUpdateChartZoom={onUpdateChartZoom} />
    );
    const container = wrapper.find('.pipeline-minimap');
    const mouseEvent = () => ({ clientX: 5, clientY: 10 });
    const wheelEvent = () => ({ deltaY: 1 });
    container.simulate('mouseenter', mouseEvent());
    container.simulate('wheel', wheelEvent());
    container.simulate('mouseleave', mouseEvent());
    expect(onUpdateChartZoom).toHaveBeenLastCalledWith({
      scale: expect.any(Number),
      applied: expect.any(Boolean),
      transition: expect.any(Boolean),
      relative: expect.any(Boolean),
    });
  });

  it('does not throw an error/warning when no data is displayed', () => {
    // Setup
    const originalConsole = console;
    console.warn = jest.fn();
    console.error = jest.fn();
    // Test
    const emptyData = { data: { nodes: [], edges: [] } };
    expect(() => setup.mount(<MiniMap />, emptyData)).not.toThrow();
    expect(console.warn).not.toHaveBeenCalled();
    expect(console.error).not.toHaveBeenCalled();
    // Teardown
    console.warn = originalConsole.warn;
    console.error = originalConsole.error;
  });

  it('maps state to props', () => {
    const expectedResult = {
      visible: expect.any(Boolean),
      mapSize: expect.any(Object),
      clickedNode: null,
      chartSize: expect.any(Object),
      chartZoom: expect.any(Object),
      graphSize: expect.any(Object),
      linkedNodes: expect.any(Object),
      nodeActive: expect.any(Object),
      nodeSelected: expect.any(Object),
      nodes: expect.any(Array),
      textLabels: expect.any(Boolean),
    };
    expect(mapStateToProps(mockState.spaceflights)).toEqual(expectedResult);
  });

  it('maps dispatch to props', () => {
    const dispatch = jest.fn();
    const zoom = {};

    mapDispatchToProps(dispatch).onUpdateChartZoom(zoom);
    expect(dispatch.mock.calls[0][0]).toEqual({
      type: 'UPDATE_ZOOM',
      zoom,
    });
  });
});

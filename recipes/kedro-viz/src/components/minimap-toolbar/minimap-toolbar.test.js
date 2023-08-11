import React from 'react';
import ConnectedMiniMapToolbar, {
  MiniMapToolbar,
  mapStateToProps,
  mapDispatchToProps,
} from './minimap-toolbar';
import { mockState, setup } from '../../utils/state.mock';

describe('MiniMapToolbar', () => {
  it('renders without crashing', () => {
    const wrapper = setup.mount(<ConnectedMiniMapToolbar />);
    expect(wrapper.find('.pipeline-icon-toolbar__button').length).toBe(4);
  });

  const functionCalls = [
    ['.pipeline-minimap-button--map', 'onToggleMiniMap'],
    ['.pipeline-minimap-button--zoom-in', 'onUpdateChartZoom'],
    ['.pipeline-minimap-button--zoom-out', 'onUpdateChartZoom'],
    ['.pipeline-minimap-button--reset', 'onUpdateChartZoom'],
  ];

  test.each(functionCalls)(
    'calls %s function on %s button click',
    (selector, callback) => {
      const mockFn = jest.fn();
      const props = {
        chartZoom: { scale: 1, minScale: 0.5, maxScale: 1.5 },
        displayMiniMap: true,
        visible: { miniMap: false },
        [callback]: mockFn,
      };
      const wrapper = setup.mount(<MiniMapToolbar {...props} />);
      expect(mockFn.mock.calls.length).toBe(0);
      wrapper.find(selector).find('button').simulate('click');
      expect(mockFn.mock.calls.length).toBe(1);
    }
  );

  it('does not display the toggle minimap button if displayMinimap is false', () => {
    const props = {
      chartZoom: { scale: 1, minScale: 0.5, maxScale: 1.5 },
      displayMiniMap: false,
      visible: { miniMap: false },
    };
    const wrapper = setup.mount(<MiniMapToolbar {...props} />);
    expect(wrapper.find('.pipeline-minimap-button--map').length).toBe(0);
  });

  it('maps state to props', () => {
    const expectedResult = {
      displayMiniMap: true,
      chartZoom: expect.any(Object),
      visible: expect.objectContaining({
        miniMap: expect.any(Boolean),
        miniMapBtn: expect.any(Boolean),
      }),
    };
    expect(mapStateToProps(mockState.spaceflights)).toEqual(expectedResult);
  });

  it('mapDispatchToProps', () => {
    const dispatch = jest.fn();
    const expectedResult = {
      onToggleMiniMap: expect.any(Function),
      onUpdateChartZoom: expect.any(Function),
    };
    expect(mapDispatchToProps(dispatch)).toEqual(expectedResult);
  });
});

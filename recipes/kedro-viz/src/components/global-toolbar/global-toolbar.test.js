import React from 'react';
import { MemoryRouter } from 'react-router-dom';
import ConnectedGlobalToolbar, {
  GlobalToolbar,
  mapStateToProps,
  mapDispatchToProps,
} from './global-toolbar';
import { mockState, setup } from '../../utils/state.mock';

describe('GlobalToolbar', () => {
  it('renders without crashing', () => {
    const wrapper = setup.mount(
      <MemoryRouter>
        <ConnectedGlobalToolbar />
      </MemoryRouter>
    );
    expect(wrapper.find('.pipeline-icon-toolbar__button').length).toBe(5);
  });

  const functionCalls = [
    ['.pipeline-menu-button--theme', 'onToggleTheme'],
    ['.pipeline-menu-button--settings', 'onToggleSettingsModal'],
  ];

  test.each(functionCalls)(
    'calls %s function on %s button click',
    (selector, callback) => {
      const mockFn = jest.fn();
      const props = {
        theme: mockState.spaceflights.theme,
        visible: mockState.spaceflights.visible,
        [callback]: mockFn,
      };
      const wrapper = setup.mount(
        <MemoryRouter>
          <GlobalToolbar {...props} />
        </MemoryRouter>
      );
      expect(mockFn.mock.calls.length).toBe(0);
      wrapper.find(selector).find('button').simulate('click');
      expect(mockFn.mock.calls.length).toBe(1);
    }
  );

  it('maps state to props', () => {
    const expectedResult = {
      theme: expect.stringMatching(/light|dark/),
      visible: {
        code: false,
        exportBtn: true,
        exportModal: false,
        graph: true,
        labelBtn: true,
        layerBtn: true,
        miniMap: true,
        miniMapBtn: true,
        modularPipelineFocusMode: null,
        metadataModal: false,
        settingsModal: false,
        sidebar: true,
      },
    };
    expect(mapStateToProps(mockState.spaceflights)).toEqual(expectedResult);
  });

  describe('mapDispatchToProps', () => {
    it('onToggleTheme', () => {
      const dispatch = jest.fn();
      mapDispatchToProps(dispatch).onToggleTheme('light');
      expect(dispatch.mock.calls[0][0]).toEqual({
        theme: 'light',
        type: 'TOGGLE_THEME',
      });
    });

    it('onToggleSettingsModal', () => {
      const dispatch = jest.fn();
      mapDispatchToProps(dispatch).onToggleSettingsModal(true);
      expect(dispatch.mock.calls[0][0]).toEqual({
        visible: true,
        type: 'TOGGLE_SETTINGS_MODAL',
      });
    });
  });
});

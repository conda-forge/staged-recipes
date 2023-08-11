import React from 'react';
import {
  PipelineWarning,
  mapStateToProps,
  mapDispatchToProps,
} from './pipeline-warning';
import { mockState, setup } from '../../utils/state.mock';
import { act } from 'react-dom/test-utils';

describe('PipelineWarning', () => {
  describe('LargePipelineWarning', () => {
    it('renders large pipeline warning without crashing', () => {
      const mockFn = jest.fn();
      const props = {
        onDisable: mockFn,
        onHide: mockFn,
        nodes: ['node1', 'node2'],
        visible: true,
      };
      const wrapper = setup.mount(<PipelineWarning {...props} />);
      expect(wrapper.find('.pipeline-warning__title').length).toBe(1);
    });

    it('will call onHide upon clicking the "render anyway" button', () => {
      const mockFn = jest.fn();
      const props = {
        onDisable: () => {},
        onHide: mockFn,
        nodes: [],
        visible: true,
      };
      const wrapper = setup.mount(<PipelineWarning {...props} />);
      wrapper.find('.button__btn').at(0).simulate('click');
      expect(mockFn.mock.calls.length).toBe(1);
    });

    it('will call onDisable upon clicking the "Don\'t show this again" button', () => {
      const mockFn = jest.fn();
      const props = {
        onDisable: mockFn,
        onHide: () => {},
        nodes: [],
        visible: true,
      };
      const wrapper = setup.mount(<PipelineWarning {...props} />);
      wrapper.find('.button__btn').at(1).simulate('click');
      expect(mockFn.mock.calls.length).toBe(1);
    });
  });

  describe('EmptyPipelineWarning', () => {
    let wrapper;
    const mockFn = jest.fn();
    const emptyProps = {
      onDisable: mockFn,
      onHide: mockFn,
      nodes: [],
      visible: false,
    };

    beforeAll(() => {
      jest.useFakeTimers();
      wrapper = setup.mount(<PipelineWarning {...emptyProps} />);
    });

    it('renders empty pipeline warning without crashing', () => {
      act(() => {
        jest.runOnlyPendingTimers();
      });
      wrapper.update();
      expect(wrapper.find('.pipeline-warning__title').length).toBe(1);
    });

    it('does not render empty pipeline warning when pipeline is not empty', () => {
      const props = {
        onDisable: mockFn,
        onHide: mockFn,
        nodes: ['node1', 'node2'],
        visible: false,
      };
      const wrapper = setup.mount(<PipelineWarning {...props} />);
      expect(wrapper.find('.pipeline-warning__title').length).toBe(0);
    });
  });

  describe('mapStateToProps', () => {
    it('maps state to props', () => {
      const expectedResult = {
        theme: expect.any(String),
        nodes: expect.any(Object),
        sidebarVisible: expect.any(Boolean),
        visible: expect.any(Boolean),
      };
      expect(mapStateToProps(mockState.spaceflights)).toEqual(expectedResult);
    });
  });

  describe('mapDispatchToProps', () => {
    it('disables the size warning flag', () => {
      const dispatch = jest.fn();
      mapDispatchToProps(dispatch).onDisable();
      expect(dispatch.mock.calls[0][0]).toEqual({
        type: 'CHANGE_FLAG',
        name: 'sizewarning',
        value: false,
      });
    });

    it('hides the size warning', () => {
      const dispatch = jest.fn();
      mapDispatchToProps(dispatch).onHide();
      expect(dispatch.mock.calls[0][0]).toEqual({
        type: 'TOGGLE_IGNORE_LARGE_WARNING',
        ignoreLargeWarning: true,
      });
    });
  });
});

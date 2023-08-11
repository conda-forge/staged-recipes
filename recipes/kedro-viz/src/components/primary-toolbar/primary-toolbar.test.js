import React from 'react';
import PrimaryToolbar from './primary-toolbar';
import { mockState, setup } from '../../utils/state.mock';

describe('PrimaryToolbar', () => {
  it('renders without crashing', () => {
    const wrapper = setup.mount(<PrimaryToolbar />);
    expect(wrapper.find('.pipeline-icon-toolbar__button').length).toBe(1);
  });

  it('shows the collapse sidebar icon button', () => {
    const visible = {
      sidebar: true,
    };
    const wrapper = setup.mount(<PrimaryToolbar visible={visible} />);
    expect(wrapper.find('.pipeline-icon-toolbar__button').length).toBe(1);
  });

  it('shows the original menu button when visible sidebar prop is true', () => {
    const visible = {
      sidebar: true,
    };
    const wrapper = setup.mount(<PrimaryToolbar visible={visible} />);
    expect(wrapper.find('.pipeline-menu-button--inverse').length).toBe(0);
  });

  it('shows the reverse menu button when visible sidebar prop is true', () => {
    const visible = {
      sidebar: false,
    };
    const wrapper = setup.mount(<PrimaryToolbar visible={visible} />);
    expect(wrapper.find('.pipeline-menu-button--inverse').length).toBe(2);
  });

  const functionCalls = [['.pipeline-menu-button--menu', 'onToggleSidebar']];

  test.each(functionCalls)(
    'calls %s function on %s button click',
    (selector, callback) => {
      const mockFn = jest.fn();
      const props = {
        textLabels: mockState.spaceflights.textLabels,
        visible: mockState.spaceflights.visible,
        displaySidebar: true,
        [callback]: mockFn,
      };
      const wrapper = setup.mount(<PrimaryToolbar {...props} />);
      expect(mockFn.mock.calls.length).toBe(0);
      wrapper.find(selector).find('button').simulate('click');
      expect(mockFn.mock.calls.length).toBe(1);
    }
  );
});

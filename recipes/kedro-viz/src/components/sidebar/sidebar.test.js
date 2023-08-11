import React from 'react';
import MountSidebar, { Sidebar } from './sidebar';
import { mockState, setup } from '../../utils/state.mock';

const mockProps = {
  flags: { pipelines: true },
  theme: mockState.spaceflights.theme,
  onToggle: () => {},
  visible: true,
};

describe('Sidebar', () => {
  it('renders without crashing', () => {
    const wrapper = setup.shallow(Sidebar, mockProps);
    const container = wrapper.find('.pipeline-sidebar');
    expect(container.length).toBe(1);
  });

  it('is open by default', () => {
    const sidebar = setup.shallow(Sidebar, mockProps).find('.pipeline-sidebar');
    expect(sidebar.hasClass('pipeline-sidebar--visible')).toBe(true);
  });

  it('hides when clicking the hide menu button', () => {
    const wrapper = setup.mount(<MountSidebar />, {
      visible: { sidebar: true },
    });
    wrapper.find('button[aria-label="Hide menu"]').simulate('click');
    const sidebar = wrapper.find('.pipeline-sidebar');
    expect(sidebar.hasClass('pipeline-sidebar--visible')).toBe(false);
  });

  it('shows when clicking the show menu button', () => {
    const wrapper = setup.mount(<MountSidebar />, {
      visible: { sidebar: false },
    });
    wrapper.find('button[aria-label="Show menu"]').simulate('click');
    const sidebar = wrapper.find('.pipeline-sidebar');
    expect(sidebar.hasClass('pipeline-sidebar--visible')).toBe(true);
  });
});

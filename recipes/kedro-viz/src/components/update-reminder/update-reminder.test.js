import React from 'react';
import UpdateReminder from './update-reminder';
import { setup } from '../../utils/state.mock';
import { updateContent } from './update-reminder-content';

const numberNewFeatures = updateContent.features.length;

describe('Update Reminder', () => {
  const versionOutOfDate = {
    latest: '4.3.1',
    installed: '4.2.0',
    isOutdated: true,
  };
  const versionsUpToDate = {
    latest: '4.3.1',
    installed: '4.3.1',
    isOutdated: false,
  };

  it('renders without crashing', () => {
    const wrapper = setup.mount(
      <UpdateReminder
        isOutdated={versionOutOfDate.isOutdated}
        versions={versionOutOfDate}
      />
    );
    expect(wrapper.find('.update-reminder-unexpanded').length).toBe(1);
  });

  it('popup expands when it is clicked', () => {
    const wrapper = setup.mount(
      <UpdateReminder
        isOutdated={versionOutOfDate.isOutdated}
        versions={versionOutOfDate}
      />
    );
    const container = wrapper.find('.update-reminder-unexpanded');

    container.find('.buttons-container').find('button').at(0).simulate('click');
    expect(wrapper.find('.update-reminder-expanded-header').length).toBe(1);
  });

  it('dismisses when the dismiss button is clicked', () => {
    const wrapper = setup.mount(
      <UpdateReminder
        isOutdated={versionOutOfDate.isOutdated}
        versions={versionOutOfDate}
      />
    );
    const container = wrapper.find('.update-reminder-unexpanded');
    container.find('.buttons-container').find('button').at(1).simulate('click');
    expect(wrapper.find('.update-reminder-expanded-header').length).toBe(0);
  });

  it('shows the correct version tag when outdated', () => {
    const wrapper = setup.mount(
      <UpdateReminder
        isOutdated={versionOutOfDate.isOutdated}
        versions={versionOutOfDate}
      />
    );
    wrapper.find('.buttons-container').find('button').at(1).simulate('click');
    expect(wrapper.find('.update-reminder-version-tag--outdated').length).toBe(
      1
    );
  });

  it('shows the correct version tag when up to date', () => {
    const wrapper = setup.mount(
      <UpdateReminder
        isOutdated={versionsUpToDate.isOutdated}
        versions={versionsUpToDate}
      />
    );
    expect(
      wrapper.find('.update-reminder-version-tag--up-to-date').length
    ).toBe(1);
  });

  it('shows feature release information', () => {
    const wrapper = setup.mount(
      <UpdateReminder
        isOutdated={versionOutOfDate.isOutdated}
        versions={versionOutOfDate}
      />
    );
    const container = wrapper.find('.update-reminder-unexpanded');
    container.find('.buttons-container').find('button').at(0).simulate('click');
    expect(wrapper.find('.update-reminder-expanded-content').length).toBe(1);
    expect(
      wrapper.find('.update-reminder-expanded-content--feature').length
    ).toBe(numberNewFeatures);
  });

  it('shows new version information', () => {
    const wrapper = setup.mount(
      <UpdateReminder
        isOutdated={versionOutOfDate.isOutdated}
        versions={versionOutOfDate}
      />
    );
    const container = wrapper.find('.update-reminder-unexpanded');
    container.find('.buttons-container').find('button').at(0).simulate('click');
    expect(wrapper.find('.update-reminder-expanded-detail > h3').text()).toBe(
      'Kedro-Viz 4.3.1 is here!'
    );
  });

  it('shows the user is up to date', () => {
    const wrapper = setup.mount(
      <UpdateReminder
        isOutdated={versionsUpToDate.isOutdated}
        versions={versionsUpToDate}
      />
    );
    const container = wrapper.find('.update-reminder-version-tag--up-to-date');
    container.simulate('click');
    expect(
      wrapper.find('.update-reminder-expanded-detail--up-to-date > h3').text()
    ).toBe("You're up to date");
    expect(
      wrapper.find('.update-reminder-expanded-detail--up-to-date > p').text()
    ).toBe('Kedro-Viz 4.3.1');
  });
});

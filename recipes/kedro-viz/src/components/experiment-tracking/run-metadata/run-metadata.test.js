import React from 'react';
import RunMetadata from '.';
import { runs } from '../../experiment-wrapper/mock-data';
import Adapter from '@wojtekmaj/enzyme-adapter-react-17';
import { configure, shallow } from 'enzyme';

configure({ adapter: new Adapter() });

const twoRuns = [
  {
    id: 'run1',
    author: '',
    bookmark: true,
    gitSha: '',
    gitBranch: '',
    runCommand: '',
    notes: '',
    title: '',
  },
  {
    id: 'run2',
    author: '',
    bookmark: true,
    gitSha: '',
    gitBranch: '',
    runCommand: '',
    notes: '',
    title: '',
  },
];

describe('RunMetadata', () => {
  it('renders without crashing', () => {
    const wrapper = shallow(
      <RunMetadata isSingleRun={runs.length === 1 ? true : false} runs={runs} />
    );

    expect(wrapper.find('.details-metadata').length).toBe(1);
    expect(wrapper.find('.details-metadata__run').length).toBe(4);
  });

  it('renders a first run for when theres a single run', () => {
    const wrapper = shallow(
      <RunMetadata
        enableComparisonView={true}
        isSingleRun={runs.slice(0, 1).length === 1 ? true : false}
        runs={runs.slice(0, 1)}
      />
    );

    expect(wrapper.find('.details-metadata').length).toBe(1);
    expect(wrapper.find('.details-metadata__run--first-run').length).toBe(1);
  });

  it('contains "-comparison-view" classname for when the comparison mode is enabled', () => {
    const wrapper = shallow(
      <RunMetadata enableComparisonView={true} runs={runs.slice(0, 1)} />
    );

    expect(
      wrapper.find('.details-metadata__table-comparison-view').length
    ).toBe(1);
  });

  it('shows a "--first-run" for the first run when comparison mode is on', () => {
    const wrapper = shallow(
      <RunMetadata
        enableComparisonView={true}
        isSingleRun={runs.slice(0, 1).length === 1 ? true : false}
        runs={runs.slice(0, 1)}
      />
    );
    expect(wrapper.find('.details-metadata__run--first-run').length).toBe(1);
    expect(
      wrapper.find('.details-metadata__run--first-run-comparison-view').length
    ).toBe(1);
  });

  it('handles show more/less button click event', () => {
    const setToggleNotes = jest.fn();
    const wrapper = shallow(
      <RunMetadata
        isSingleRun={runs.slice(0, 1).length === 1 ? true : false}
        runs={runs.slice(0, 1)}
      />
    );
    const onClick = jest.spyOn(React, 'useState');
    onClick.mockImplementation((toggleNotes) => [toggleNotes, setToggleNotes]);

    expect(wrapper.find('.details-metadata__show-more').text()).toMatch(
      'Show more'
    );

    wrapper.find('.details-metadata__show-more').simulate('click');
    expect(setToggleNotes).toBeTruthy();
    expect(wrapper.find('.details-metadata__show-more').text()).toMatch(
      'Show less'
    );

    wrapper.find('.details-metadata__show-more').simulate('click');
    expect(setToggleNotes).toBeTruthy();
    expect(wrapper.find('.details-metadata__show-more').text()).toMatch(
      'Show more'
    );
  });

  it('enables the pin button when show changes is enabled ', () => {
    const wrapper = shallow(
      <RunMetadata
        enableComparisonView={true}
        enableShowChanges={true}
        isSingleRun={false}
        runs={twoRuns}
      />
    );

    expect(wrapper.find('.pipeline-menu-button__pin').length).toEqual(2);
  });
});

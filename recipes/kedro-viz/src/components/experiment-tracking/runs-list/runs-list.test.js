import React from 'react';
import RunsList from '.';
import { ApolloProvider } from '@apollo/client';
import { client } from '../../../apollo/config';
import { shallow } from 'enzyme';
import { setup } from '../../../utils/state.mock';
import { HoverStateContext } from '../utils/hover-state-context';

const runDataList = [
  {
    bookmark: false,
    id: new Date('October 15, 2021 03:24:00').toISOString(),
    title: 'Run 1',
    notes: 'notes of run 1 is a duck',
  },
  {
    bookmark: false,
    id: new Date('October 15, 2021 03:26:00').toISOString(),
    title: 'Run 2',
    notes: 'notes of run 2 is a fish',
  },
  {
    bookmark: false,
    id: new Date('October 15, 2021 03:29:00').toISOString(),
    title: 'Run 3',
    notes: 'notes of run 3 is a star',
  },
  {
    bookmark: true,
    id: new Date('October 15, 2021 03:29:00').toISOString(),
    title: 'Run 4',
    notes: 'notes of run 4 is a star',
  },
];

const setHoveredElementId = jest.fn();
const mockContextValue = {
  setHoveredElementId,
  hoveredElementId: [new Date('October 15, 2021 03:29:00').toISOString()],
};

jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useLocation: () => ({
    pathname: 'localhost:3000/',
  }),
}));

describe('RunsListCard', () => {
  it('renders without crashing', () => {
    const wrapper = shallow(
      <RunsList runData={runDataList} selectedRunIds={['run3']} />
    );

    expect(wrapper.find('.runs-list__wrapper').length).toBe(2);
  });

  it('renders the search bar', () => {
    const wrapper = shallow(
      <RunsList runData={runDataList} selectedRunIds={['run3']} />
    );

    expect(wrapper.find('.search-bar-wrapper').length).toBe(1);
  });

  it('displays the right search amount of cards for the search', () => {
    const stateSetter = jest.fn();
    jest
      .spyOn(React, 'useState')
      //Simulate that searchValue state value
      .mockImplementation((stateValue) => [(stateValue = 'run'), stateSetter]);

    const wrapper = setup.mount(
      <ApolloProvider client={client}>
        <HoverStateContext.Provider value={mockContextValue}>
          <RunsList runData={runDataList} selectedRunIds={['run3']} />
        </HoverStateContext.Provider>
      </ApolloProvider>
    );

    expect(wrapper.find('.runs-list-card').length).toBe(4);
  });
});

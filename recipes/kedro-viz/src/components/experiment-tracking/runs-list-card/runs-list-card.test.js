import React from 'react';
import RunsListCard from '.';
import Adapter from '@wojtekmaj/enzyme-adapter-react-17';
import { configure, mount } from 'enzyme';
import { HoverStateContext } from '../utils/hover-state-context';

configure({ adapter: new Adapter() });

// Mocked methods

const mockUpdateRunDetails = jest.fn();
const setHoveredElementId = jest.fn();

jest.mock('../../../apollo/mutations', () => {
  return {
    useUpdateRunDetails: () => {
      return {
        updateRunDetails: mockUpdateRunDetails,
      };
    },
  };
});

// Setup

const randomRunId = new Date('October 15, 2021 03:24:00').toISOString();
const randomRun = {
  bookmark: false,
  id: randomRunId,
  title: 'Sprint 4 EOW',
};

const selectedRunIds = [randomRunId];

const savedRun = {
  bookmark: true,
  id: new Date('October 15, 2021 03:24:00').toISOString(),
  title: 'Sprint 4 EOW',
  notes: 'star',
};

const nonActiveRun = {
  bookmark: true,
  id: new Date('October 15, 2021 03:24:00').toISOString(),
  title: 'Sprint 4 EOW',
};

const mockContextValue = {
  setHoveredElementId,
  hoveredElementId: [new Date('October 25, 2021 03:24:00').toISOString()],
};

// Tests

describe('RunsListCard', () => {
  it('renders without crashing', () => {
    const wrapper = mount(
      <HoverStateContext.Provider value={mockContextValue}>
        <RunsListCard data={randomRun} selectedRunIds={selectedRunIds} />
      </HoverStateContext.Provider>
    );

    expect(wrapper.find('.runs-list-card').length).toBe(1);
    expect(wrapper.find('.runs-list-card__title').length).toBe(1);
  });

  it('renders with a bookmark icon', () => {
    const wrapper = mount(
      <HoverStateContext.Provider value={mockContextValue}>
        <RunsListCard data={savedRun} selectedRunIds={selectedRunIds} />
      </HoverStateContext.Provider>
    );

    expect(wrapper.find('.runs-list-card__bookmark').length).toBe(2);
  });

  it('does not render with check icon for single view', () => {
    const wrapper = mount(
      <HoverStateContext.Provider value={mockContextValue}>
        <RunsListCard
          data={randomRun}
          enableComparisonView={false}
          selectedRunIds={selectedRunIds}
        />
      </HoverStateContext.Provider>
    );

    expect(wrapper.find('.runs-list-card__checked').length).toBe(0);
  });

  it('renders with an unchecked check icon for comparison view', () => {
    const wrapper = mount(
      <HoverStateContext.Provider value={mockContextValue}>
        <RunsListCard
          data={nonActiveRun}
          enableComparisonView={true}
          selectedRunIds={selectedRunIds}
        />
      </HoverStateContext.Provider>
    );

    expect(wrapper.find('.runs-list-card__checked--comparing').length).toBe(1);
  });

  it('renders with an inactive bookmark icon', () => {
    const wrapper = mount(
      <HoverStateContext.Provider value={mockContextValue}>
        <RunsListCard
          data={randomRun}
          enableComparisonView={false}
          selectedRunIds={selectedRunIds}
        />
      </HoverStateContext.Provider>
    );

    expect(wrapper.find('.runs-list-card__bookmark--stroke').length).toBe(2);
  });

  it('renders with an active bookmark icon', () => {
    const wrapper = mount(
      <HoverStateContext.Provider value={mockContextValue}>
        <RunsListCard
          data={savedRun}
          enableComparisonView={false}
          selectedRunIds={selectedRunIds}
        />
      </HoverStateContext.Provider>
    );

    expect(wrapper.find('.runs-list-card__bookmark--solid').length).toBe(2);
  });

  it('calls a function on click and adds an active class', () => {
    const setActive = jest.fn();
    const wrapper = mount(
      <HoverStateContext.Provider value={mockContextValue}>
        <RunsListCard
          data={randomRun}
          onRunSelection={() => setActive(randomRunId)}
          selectedRunIds={selectedRunIds}
        />
      </HoverStateContext.Provider>
    );
    const onClick = jest.spyOn(React, 'useState');

    onClick.mockImplementation((active) => [active, setActive]);
    wrapper.simulate('click');
    expect(setActive).toBeTruthy();
    expect(wrapper.find('.runs-list-card--active').length).toBe(1);
  });

  it('calls the updateRunDetails function', () => {
    const wrapper = mount(
      <HoverStateContext.Provider value={mockContextValue}>
        <RunsListCard
          data={randomRun}
          enableComparisonView={true}
          selectedRunIds={selectedRunIds}
        />
      </HoverStateContext.Provider>
    );

    wrapper.simulate('click', {
      target: {
        classList: {
          contains: () => true,
          tagName: 'path',
        },
      },
    });

    expect(mockUpdateRunDetails).toHaveBeenCalled();
  });

  it('displays the notes in the runs card when notes matches search value', () => {
    const wrapper = mount(
      <HoverStateContext.Provider value={mockContextValue}>
        <RunsListCard
          data={savedRun}
          selectedRunIds={selectedRunIds}
          searchValue={'star'}
        />
      </HoverStateContext.Provider>
    );

    expect(wrapper.find('.runs-list-card__notes').length).toBe(1);
  });
});

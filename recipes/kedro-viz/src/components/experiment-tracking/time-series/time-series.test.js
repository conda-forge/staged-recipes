import React from 'react';
import { mount } from 'enzyme';

import { getSelectedOrderedData, TimeSeries } from './time-series';
import { HoverStateContext } from '../utils/hover-state-context';
import { formatTimestamp } from '../../../utils/date-utils';
import { data, selectedRuns, oneSelectedRun } from '../mock-data';

const metricsKeys = Object.keys(data.metrics);

const runKeys = Object.keys(data.runs);
const runData = Object.entries(data.runs);

const hoveredElement = 0;

describe('TimeSeries', () => {
  const mockContextValue = {
    hoveredElementId: runKeys[hoveredElement],
    setHoveredElementId: jest.fn(),
  };

  const wrapper = mount(
    <HoverStateContext.Provider value={mockContextValue}>
      <TimeSeries metricsData={data} selectedRuns={selectedRuns}></TimeSeries>
    </HoverStateContext.Provider>
  );

  it('renders without crashing', () => {
    expect(wrapper.find('.time-series').length).toBe(1);
  });

  it('constructs an svg for each metric from the data', () => {
    const svg = wrapper.find('.time-series').find('svg');
    expect(svg.length).toBe(metricsKeys.length);
  });

  it('show tooltip onHover - runLine', () => {
    wrapper
      .find('.time-series__run-lines')
      .find('line')
      .at(hoveredElement)
      .simulate('mouseover');

    const tooltip = wrapper.find('.time-series').find('.tooltip');
    expect(tooltip.hasClass('tooltip--show')).toBe(true);
  });
});

describe('TimeSeries with multiple selected runs and hovered run', () => {
  const mockContextValue = {
    hoveredElementId: runKeys[hoveredElement],
    setHoveredElementId: jest.fn(),
  };

  const wrapper = mount(
    <HoverStateContext.Provider value={mockContextValue}>
      <TimeSeries metricsData={data} selectedRuns={selectedRuns}></TimeSeries>
    </HoverStateContext.Provider>
  )
    .find('.time-series')
    .find('svg')
    .find('g');

  it('draw X, Y and dual axes for each metric chart', () => {
    const xAxis = wrapper.find('.time-series__runs-axis');
    expect(xAxis.length).toBe(metricsKeys.length);

    const yAxis = wrapper.find('.time-series__metric-axis');
    expect(yAxis.length).toBe(metricsKeys.length);

    const dualAxis = wrapper.find('.time-series__metric-axis-dual');
    expect(dualAxis.length).toBe(metricsKeys.length);
  });

  it('draw metricLine for each metric', () => {
    const metricLine = wrapper.find('.time-series__metric-line');
    expect(metricLine.length).toBe(metricsKeys.length);
  });

  it('draw runLines for each metric', () => {
    const runLines = wrapper
      .find('.time-series__run-lines')
      .find('.time-series__run-line');
    expect(runLines.length).toBe(runData.length * metricsKeys.length);
  });

  it('applies "time-series__run-line--hovered" class to the correct runLine on mouseover', () => {
    const runLine = wrapper
      .find('.time-series__run-lines')
      .find('line')
      .at(hoveredElement);

    runData.forEach((_, index) => {
      if (hoveredElement === index) {
        expect(
          runLine.at(index).hasClass('time-series__run-line--hovered')
        ).toBe(true);
      }
    });
  });

  it('selected group is returend in the correct order', () => {
    const selectedGroupLine = wrapper
      .find('.time-series__selected-group')
      .find('line');

    getSelectedOrderedData(runData, selectedRuns).forEach(([key, _], index) => {
      const parsedSelectedDate = new Date(formatTimestamp(selectedRuns[index]));

      if (parsedSelectedDate.getTime() === key.getTime()) {
        expect(
          selectedGroupLine
            .at(index)
            .hasClass(`time-series__run-line--selected-${index}`)
        ).toBe(true);
      }
    });
  });

  it('on double click reset to default zoom scale', () => {
    const setRangeSelection = jest.fn();
    const brushContainer = wrapper.find('.time-series__brush').at(0);
    const onDbClick = jest.spyOn(React, 'useState');

    onDbClick.mockImplementation((rangeSelection) => [
      rangeSelection,
      setRangeSelection,
    ]);
    brushContainer.simulate('dblclick');

    expect(setRangeSelection).toBeTruthy();
    expect(brushContainer.length).toBe(1);
  });
});

describe('TimeSeries with only one selected run and no hovered run', () => {
  const mockContextValue = {
    hoveredElementId: null,
    setHoveredElementId: jest.fn(),
  };

  const wrapper = mount(
    <HoverStateContext.Provider value={mockContextValue}>
      <TimeSeries metricsData={data} selectedRuns={oneSelectedRun}></TimeSeries>
    </HoverStateContext.Provider>
  )
    .find('.time-series')
    .find('svg')
    .find('g');

  it('Class "time-series__run-line--blend" is not applied when there is only one selected run and no hovered element', () => {
    const runLine = wrapper.find('.time-series__run-lines').find('line');

    runData.forEach((_, index) => {
      expect(runLine.at(index).hasClass('time-series__run-line--blend')).toBe(
        false
      );
    });
  });

  it('Class "time-series__metric-line--blend" is not applied when there is only one selected run and no hovered element', () => {
    const metricLine = wrapper.find('.time-series__metric-line');

    metricsKeys.forEach((_, index) => {
      expect(
        metricLine.at(index).hasClass('time-series__metric-line--blend')
      ).toBe(false);
    });
  });
});

describe('TimeSeries with only one selected run and hovered run', () => {
  const mockContextValue = {
    hoveredElementId: runKeys[hoveredElement],
    setHoveredElementId: jest.fn(),
  };

  const wrapper = mount(
    <HoverStateContext.Provider value={mockContextValue}>
      <TimeSeries metricsData={data} selectedRuns={oneSelectedRun}></TimeSeries>
    </HoverStateContext.Provider>
  )
    .find('.time-series')
    .find('svg')
    .find('g');

  it('Class "time-series__run-line--blend" is applied when there is only one selected run and hovered element', () => {
    const runLine = wrapper.find('.time-series__run-lines').find('line');

    runData.forEach((_, index) => {
      if (hoveredElement === index) {
        expect(runLine.at(index).hasClass('time-series__run-line--blend')).toBe(
          true
        );
      }
    });
  });

  it('Class "time-series__metric-line--blend" is applied when there is only one selected run and hovered element', () => {
    const metricLine = wrapper.find('.time-series__metric-line');

    metricsKeys.forEach((_, index) => {
      if (hoveredElement === index) {
        expect(
          metricLine.at(index).hasClass('time-series__metric-line--blend')
        ).toBe(true);
      }
    });
  });
});

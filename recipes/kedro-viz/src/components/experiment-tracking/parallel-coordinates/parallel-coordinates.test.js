import React from 'react';
import { mount } from 'enzyme';

import { HoverStateContext } from '../utils/hover-state-context';
import { ParallelCoordinates, getUniqueValues } from './parallel-coordinates';
import { data, oneSelectedRun, selectedRuns } from '../mock-data';
import { metricLimit } from '../../../config';

const hoveredRunIndex = 4;
const hoverMetricIndex = 1;

const mockDefaultContextValue = {
  hoveredElementId: null,
  setHoveredElementId: jest.fn(),
};

const mockHoveredContextValue = {
  hoveredElementId: Object.keys(data.runs)[hoveredRunIndex],
  setHoveredElementId: jest.fn(),
};

describe('Parallel Coordinates renders correctly with D3', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = mount(
      <HoverStateContext.Provider value={mockDefaultContextValue}>
        <ParallelCoordinates metricsData={data} selectedRuns={oneSelectedRun} />
      </HoverStateContext.Provider>
    );
  });

  it('renders without crashing', () => {
    const svg = wrapper.find('div').find('svg');

    expect(svg.length).toEqual(1);
  });

  it('render the correct number of metric-axis from the data', () => {
    const metricAxises = wrapper.find('div').find('svg').find('.metric-axis');

    const graphKeys = Object.keys(data.metrics);

    expect(metricAxises.length).toEqual(graphKeys.length);
  });

  it('run-lines should be limited to less than metricLimit, even if its more than 10 from the data', () => {
    const runLine = wrapper.find('.run-line');

    expect(runLine.length).toBeLessThan(metricLimit);
  });

  it('text from the tick-values should be displayed in ascending order', () => {
    const tickValues = wrapper.find('div').find('svg').find('.tick-values');

    const text = tickValues.map((value) => value.text());
    // Since the text is in the format of ['1.0001.3002.4003.0003.3003.4004.5005.3006.500']
    // we need to remove the extra '00' in the middle
    const textValues = text.map((each) => each.split('00'));

    // Then ensure all are number, and the last character 00 should also be removed
    const formattedTextValues = textValues.map((array) => {
      array.splice(-1);
      return array.map((each) => Number(each));
    });

    const graphData = Object.entries(data.metrics);

    graphData.forEach(([metricName, values], metricIndex) => {
      const uniqueValues = getUniqueValues(values);

      formattedTextValues.forEach((text, index) => {
        if (index === metricIndex) {
          expect(text).toEqual(uniqueValues);
        }
      });
    });
  });
});

describe('Parallel Coordinates" interactions', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = mount(
      <HoverStateContext.Provider value={mockHoveredContextValue}>
        <ParallelCoordinates metricsData={data} selectedRuns={oneSelectedRun} />
      </HoverStateContext.Provider>
    );
  });

  it('shows tooltip when hovering over a run line', () => {
    wrapper
      .find('div')
      .find('svg')
      .find('.run-line')
      .at(hoveredRunIndex)
      .simulate('mouseover');

    const tooltip = wrapper.find('div').find('.tooltip');

    expect(tooltip.hasClass('tooltip--show')).toBe(true);
  });

  it('tick-values are only highlighted once per axis when hovering over a run line', () => {
    const highLightedValues = wrapper
      .find('div')
      .find('svg')
      .find('.tick-values')
      .find('.text--hovered');

    const highlightedText = highLightedValues.map((value) => value.text());
    const graphData = Object.entries(data.metrics);

    highlightedText.forEach((text, index) => {
      graphData.forEach(([metricName, values], metricIndex) => {
        if (index === metricIndex) {
          // each values from metrics should include a highlightedText
          expect(values.includes(Number(text))).toBe(true);
        }
      });
    });
  });

  it('applies "run-line--hovered" to the run line when hovering over', () => {
    const runLine = wrapper
      .find('div')
      .find('svg')
      .find('.run-line')
      .at(hoveredRunIndex);

    expect(runLine.hasClass('run-line--hovered')).toBe(true);
  });

  it('applies "run-line--faded" to all the run lines that are not included in the hovered modes', () => {
    const runLines = wrapper.find('div').find('svg').find('.run-line');

    runLines.forEach((run, index) => {
      expect(run.hasClass('run-line--faded')).toEqual(
        index !== hoveredRunIndex
      );
    });
  });

  it('applies "text--hovered" to the tick values when hovering over', () => {
    const textValues = wrapper
      .find('div')
      .find('svg')
      .find('.tick-values')
      .find('.text')
      .at(hoveredRunIndex);

    expect(textValues.hasClass('text--hovered')).toBe(true);
  });

  it('applies "text--faded" to all the tick values that are not included in the hovered modes', () => {});

  it('applies "line--hovered" to the tick lines when hovering over', () => {
    const textValues = wrapper
      .find('div')
      .find('svg')
      .find('.tick-lines')
      .find('.line')
      .at(hoveredRunIndex);

    expect(textValues.hasClass('line--hovered')).toBe(true);
  });

  it('applies "line--faded" to all the tick lines that are not included in the hovered modes', () => {});

  it('applies "metric-axis--hovered" to the metric-axis when hovering over', () => {
    wrapper
      .find('div')
      .find('svg')
      .find('.metric-axis')
      .find('text')
      .at(hoverMetricIndex)
      .simulate('mouseover');

    const metricAxis = wrapper
      .find('div')
      .find('svg')
      .find('.metric-axis')
      .at(hoverMetricIndex);

    expect(metricAxis.hasClass('metric-axis--hovered')).toBe(true);
  });

  it('applies "metric-axis--faded" to all the metric-axis that are not included in the hovered modes', () => {
    wrapper
      .find('div')
      .find('svg')
      .find('.metric-axis')
      .find('text')
      .at(hoverMetricIndex)
      .simulate('mouseover');

    const otherMetricsAxis = wrapper
      .find('div')
      .find('svg')
      .find('.metric-axis');

    otherMetricsAxis.forEach((metric, index) => {
      expect(metric.hasClass('metric-axis--faded')).toEqual(
        index !== hoverMetricIndex
      );
    });
  });

  it('in single run, applies "run-line--selected-first" class to "line" when selecting a new run', () => {
    const runKeys = Object.keys(data.runs);

    const oneSelectedRunWrapper = mount(
      <HoverStateContext.Provider value={mockHoveredContextValue}>
        <ParallelCoordinates metricsData={data} selectedRuns={oneSelectedRun} />
      </HoverStateContext.Provider>
    )
      .find('div')
      .find('svg')
      .find('.selected-runs')
      .find('path')
      .at(runKeys.indexOf(oneSelectedRun[0]));

    expect(oneSelectedRunWrapper.length).toEqual(1);
    expect(oneSelectedRunWrapper.hasClass('run-line--selected-first')).toBe(
      true
    );
  });

  it('in comparison mode, applies classnames accordingly to "line"', () => {
    const runKeys = Object.keys(data.runs);

    const selectedRunsWrapper = mount(
      <HoverStateContext.Provider value={mockHoveredContextValue}>
        <ParallelCoordinates metricsData={data} selectedRuns={selectedRuns} />
      </HoverStateContext.Provider>
    )
      .find('div')
      .find('svg')
      .find('.selected-runs')
      .find('path');

    expect(
      selectedRunsWrapper
        .at(runKeys.indexOf(selectedRuns[0]))
        .hasClass('run-line--selected-first')
    ).toBe(true);

    expect(
      selectedRunsWrapper
        .at(runKeys.indexOf(selectedRuns[1]))
        .hasClass('run-line--selected-second')
    ).toBe(true);

    expect(
      selectedRunsWrapper
        .at(runKeys.indexOf(selectedRuns[2]))
        .hasClass('run-line--selected-third')
    ).toBe(true);
  });
});

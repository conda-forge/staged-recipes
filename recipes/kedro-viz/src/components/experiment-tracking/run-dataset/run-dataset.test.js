import React from 'react';
import RunDataset from '.';
import { runs, trackingData } from '../../experiment-wrapper/mock-data';
import JSONObject from '../../json-object';
import { shallow, mount } from 'enzyme';

const booleanTrackingData = {
  JSONData: [
    {
      datasetName: 'train_evaluation.hyperparams_linear_regression',
      datasetType: 'tracking.json_dataset.JSONDataSet',
      data: {
        classWeight: [{ runId: 'My Favorite Sprint', value: false }],
      },
      runIds: ['My Favorite Sprint'],
    },
  ],
};

const objectTrackingData = {
  JSONData: [
    {
      datasetName: 'train_evaluation.hyperparams_linear_regression',
      datasetType: 'tracking.json_dataset.JSONDataSet',
      data: {
        classWeight: [{ runId: 'My Favorite Sprint', value: { a: true } }],
      },
      runIds: ['My Favorite Sprint'],
    },
  ],
};

const comparisonTrackingData = {
  metrics: [
    {
      datasetName: 'train_evaluation.r2_score_linear_regression',
      datasetType: 'tracking.metrics_dataset.MetricsDataSet',
      data: {
        classWeight: [
          { runId: 'My Favorite Sprint', value: 12 },
          { runId: 'My second Favorite Sprint', value: 13 },
        ],
      },
      runIds: ['My Favorite Sprint', 'My second Favorite Sprint'],
    },
  ],
};

const jsonTrackingData = {
  json: [
    {
      datasetName: 'train_evaluation.r2_score_linear_regression',
      datasetType: 'tracking.json_dataset.JSONDataSet',
      data: {
        classWeight: [
          {
            runId: 'My Favorite Sprint',
            value: {
              precision: 1,
              accuracy: {
                acc1: 1,
                acc2: 2,
              },
            },
          },
          {
            runId: 'My second Favorite Sprint',
            value: {
              precision: 4.5,
              accuracy: {
                acc1: 3.1,
                acc2: 2.5,
              },
            },
          },
        ],
      },
      runIds: ['My Favorite Sprint', 'My second Favorite Sprint'],
    },
  ],
};

const showDiffTrackingData = {
  metrics: [
    {
      datasetName: 'train_evaluation.r2_score_linear_regression',
      datasetType: 'tracking.metrics_dataset.MetricsDataSet',
      data: {
        classWeight: [
          { runId: 'My Favorite Sprint', value: 12 },
          { runId: 'My second Favorite Sprint', value: 13 },
        ],
        r2Score: [{ runId: 'My second Favorite Sprint', value: 0.2342356 }],
      },
      runIds: ['My Favorite Sprint', 'My second Favorite Sprint'],
    },
  ],
};

const matplotlibTrackingData = {
  metrics: [
    {
      datasetName: 'matplotlib',
      datasetType: 'matplotlib.matplotlib_writer.MatplotlibWriter',
      data: {
        'matplot_lib_single_plot.png': [
          {
            runId: 'My Favorite Sprint',
            value: 'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
          },
        ],
      },
      runIds: ['My Favorite Sprint'],
    },
  ],
};

const emptyMatplotlibTrackingData = {
  metrics: [
    {
      datasetName: 'matplotlib',
      datasetType: 'matplotlib.matplotlib_writer.MatplotlibWriter',
      data: {
        'matplot_lib_single_plot.png': [
          {
            runId: 'My Favorite Sprint',
            value: null,
          },
        ],
      },
      runIds: ['My Favorite Sprint'],
    },
  ],
};

const plotlyTrackingData = {
  metrics: [
    {
      datasetName: 'plotly',
      datasetType: 'plotly.plotly_dataset.PlotlyDataSet',
      data: {
        plotlyVisualization: [
          {
            runId: 'My Favorite Sprint',
            value: {
              data: [],
              layout: {},
            },
          },
        ],
      },
      runIds: ['My Favorite Sprint'],
    },
  ],
};

jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useLocation: () => ({
    pathname: 'localhost:3000/',
  }),
}));

describe('RunDataset', () => {
  it('renders without crashing', () => {
    const wrapper = shallow(
      <RunDataset
        isSingleRun={runs.length === 1 ? true : false}
        trackingData={trackingData}
        enableComparisonView={false}
      />
    );

    expect(wrapper.find('.details-dataset').length).toBe(1);
    expect(wrapper.find('.details-dataset__accordion-wrapper').length).toBe(1);
  });

  it('contains "comparison-view" classname when the comparison view is enabled', () => {
    const wrapper = shallow(
      <RunDataset trackingData={trackingData} enableComparisonView={true} />
    );

    expect(
      wrapper.find('.details-dataset__accordion-wrapper-comparison-view').length
    ).toBe(1);
  });

  it('renders a boolean value as a string', () => {
    const wrapper = mount(<RunDataset trackingData={booleanTrackingData} />);

    expect(wrapper.find('.details-dataset__value').text()).toBe('false');
  });

  it('renders a boolean value as a string', () => {
    const wrapper = mount(<RunDataset trackingData={objectTrackingData} />);

    const datasetValue = wrapper.find('.details-dataset__value').text();

    expect(typeof datasetValue).toBe('string');
  });

  it('renders the comparison arrow when showChanges is on', () => {
    const wrapper = mount(
      <RunDataset
        enableShowChanges={true}
        isSingleRun={false}
        pinnedRun={'My Favorite Sprint'}
        trackingData={comparisonTrackingData}
      />
    );

    expect(wrapper.find('.dataset-arrow-icon').length).toBe(1);
  });

  it('renders the comparison delta value when showChanges is on', () => {
    const wrapper = mount(
      <RunDataset
        enableShowChanges={true}
        isSingleRun={false}
        pinnedRun={'My Favorite Sprint'}
        trackingData={comparisonTrackingData}
      />
    );

    expect(wrapper.find('.details-dataset__deltaValue').at(1).text()).toBe(
      '1.0 (8%)'
    );
  });

  it('renders a cell with a - value for runs with different metrics', () => {
    const wrapper = mount(
      <RunDataset isSingleRun={false} trackingData={showDiffTrackingData} />
    );

    expect(wrapper.find('.details-dataset__value').at(2).text()).toBe('-');
  });

  it('renders a matplotlib image and container', () => {
    const wrapper = mount(
      <RunDataset
        enableShowChanges={true}
        isSingleRun={true}
        pinnedRun={'My Favorite Sprint'}
        trackingData={matplotlibTrackingData}
      />
    );

    expect(wrapper.find('.details-dataset__image-container').length).toBe(1);
    expect(wrapper.find('.details-dataset__image').length).toBe(1);
  });

  it('renders a empty plot placeholder', () => {
    const wrapper = mount(
      <RunDataset
        enableShowChanges={true}
        isSingleRun={true}
        pinnedRun={'My Favorite Sprint'}
        trackingData={emptyMatplotlibTrackingData}
      />
    );

    expect(wrapper.find('.details-dataset__value').length).toBe(1);
    expect(wrapper.find('.details-dataset__empty-plot').length).toBe(1);
  });

  it('renders a plotly chart container', () => {
    const wrapper = shallow(
      <RunDataset
        enableShowChanges={true}
        isSingleRun={true}
        pinnedRun={'My Favorite Sprint'}
        trackingData={plotlyTrackingData}
      />
    );

    expect(wrapper.find('.details-dataset__visualization-wrapper').length).toBe(
      1
    );
  });

  it('renders a react-json-view component when the run value is a nested json', () => {
    const wrapper = shallow(
      <RunDataset
        enableShowChanges={true}
        isSingleRun={true}
        pinnedRun={'My Favorite Sprint'}
        trackingData={jsonTrackingData}
      />
    );

    expect(wrapper.containsMatchingElement(<JSONObject />)).toEqual(true);
  });
});

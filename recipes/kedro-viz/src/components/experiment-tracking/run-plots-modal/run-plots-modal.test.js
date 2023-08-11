import React from 'react';
import RunPlotsModal from './run-plots-modal';
import { setup } from '../../../utils/state.mock';

function generateTestData(numberOfRuns = 2, dataType = 'plotly') {
  return {
    datasetKey:
      dataType === 'matplotlib' ? 'matplotlib_plot.png' : 'plotly chart',
    datasetType:
      dataType === 'matplotlib'
        ? 'matplotlib.matplotlib_writer.MatplotlibWriter'
        : 'plotly.plotly_dataset.PlotlyDataSet',
    datasetValues: [...Array(numberOfRuns).keys()].map((run) => {
      if (dataType === 'matplotlib') {
        return {
          runId: `2022-07-0${run + 1}T12.54.06.759Z`,
          value: 'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
        };
      } else {
        return {
          runId: `2022-07-0${run + 1}T12.54.06.759Z`,
          value: {
            data: [
              {
                x: [1, 2, 3],
                y: [2, 6, 3],
                type: 'scatter',
                mode: 'lines+markers',
                marker: { color: 'red' },
              },
              { type: 'bar', x: [1, 2, 3], y: [2, 5, 3] },
            ],
            layout: { width: 320, height: 240, title: 'A Fancy Plot' },
          },
        };
      }
    }),
  };
}

describe('Run Plots Modal', () => {
  const setShowRunPlotsModal = jest.fn();

  it('renders without crashing', () => {
    const wrapper = setup.mount(
      <RunPlotsModal
        runDatasetToShow={generateTestData(1, 'matplotlib')}
        setShowRunPlotsModal={setShowRunPlotsModal}
        visible={true}
      />
    );

    expect(wrapper.find('.pipeline-run-plots-modal').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').text()).toBe(
      'matplotlib_plot.png'
    );
    expect(
      wrapper.find('.pipeline-run-plots-modal__content--oneChart').length
    ).toBe(1);
    expect(wrapper.find('.pipeline-run-plots__image--oneChart').length).toBe(1);
    expect(
      wrapper.find('.pipeline-run-plots-image-text-relative_timestamp').length
    ).toBe(1);
    expect(
      wrapper.find('.pipeline-run-plots-image-text-timestamp').length
    ).toBe(1);
  });

  it('renders two Matplotlib images with timestamps and human readable times', () => {
    const wrapper = setup.mount(
      <RunPlotsModal
        runDatasetToShow={generateTestData(2, 'matplotlib')}
        setShowRunPlotsModal={setShowRunPlotsModal}
        visible={true}
      />
    );

    expect(wrapper.find('.pipeline-run-plots-modal').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').text()).toBe(
      'matplotlib_plot.png'
    );
    expect(
      wrapper.find('.pipeline-run-plots-modal__content--twoCharts').length
    ).toBe(1);
    expect(wrapper.find('.pipeline-run-plots__image--twoCharts').length).toBe(
      2
    );
    expect(
      wrapper.find('.pipeline-run-plots-image-text-relative_timestamp').length
    ).toBe(2);
    expect(
      wrapper.find('.pipeline-run-plots-image-text-timestamp').length
    ).toBe(2);
  });

  it('renders three Matplotlib images with timestamps and human readable times', () => {
    const wrapper = setup.mount(
      <RunPlotsModal
        runDatasetToShow={generateTestData(3, 'matplotlib')}
        setShowRunPlotsModal={setShowRunPlotsModal}
        visible={true}
      />
    );

    expect(wrapper.find('.pipeline-run-plots-modal').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').text()).toBe(
      'matplotlib_plot.png'
    );
    expect(
      wrapper.find('.pipeline-run-plots-modal__content--threeCharts').length
    ).toBe(1);
    expect(wrapper.find('.pipeline-run-plots__image--threeCharts').length).toBe(
      3
    );
    expect(
      wrapper.find('.pipeline-run-plots-image-text-relative_timestamp').length
    ).toBe(3);
    expect(
      wrapper.find('.pipeline-run-plots-image-text-timestamp').length
    ).toBe(3);
  });

  it('renders two Plotly charts with timestamps and human readable times', () => {
    const wrapper = setup.mount(
      <RunPlotsModal
        runDatasetToShow={generateTestData(2)}
        setShowRunPlotsModal={setShowRunPlotsModal}
        visible={true}
      />
    );

    expect(wrapper.find('.pipeline-run-plots-modal').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').text()).toBe(
      'plotly chart'
    );
    expect(
      wrapper.find('.pipeline-run-plots-modal__content--twoCharts').length
    ).toBe(1);
    expect(
      wrapper.find('.pipeline-run-plots-modal__content--plotly').length
    ).toBe(1);
    expect(
      wrapper.find('.pipeline-run-plots__plot-wrapper--twoCharts').length
    ).toBe(2);
    expect(
      wrapper.find('.pipeline-run-plots-image-text-relative_timestamp').length
    ).toBe(2);
    expect(
      wrapper.find('.pipeline-run-plots-image-text-timestamp').length
    ).toBe(2);
  });

  it('renders three Plotly charts with timestamps and human readable times', () => {
    const wrapper = setup.mount(
      <RunPlotsModal
        runDatasetToShow={generateTestData(3)}
        setShowRunPlotsModal={setShowRunPlotsModal}
        visible={true}
      />
    );

    expect(wrapper.find('.pipeline-run-plots-modal').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').length).toBe(1);
    expect(wrapper.find('.pipeline-run-plots-modal__title').text()).toBe(
      'plotly chart'
    );
    expect(
      wrapper.find('.pipeline-run-plots-modal__content--threeCharts').length
    ).toBe(1);
    expect(
      wrapper.find('.pipeline-run-plots-modal__content--plotly').length
    ).toBe(1);
    expect(
      wrapper.find('.pipeline-run-plots__plot-wrapper--threeCharts').length
    ).toBe(3);
    expect(
      wrapper.find('.pipeline-run-plots-image-text-relative_timestamp').length
    ).toBe(3);
    expect(
      wrapper.find('.pipeline-run-plots-image-text-timestamp').length
    ).toBe(3);
  });
});

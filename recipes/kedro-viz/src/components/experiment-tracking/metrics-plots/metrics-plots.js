import React, { useEffect, useState } from 'react';
import classnames from 'classnames';
import { TimeSeries } from '../time-series/time-series.js';

import { ParallelCoordinates } from '../parallel-coordinates/parallel-coordinates.js';
import ExperimentWarning from '../../experiment-warning';
import { GET_METRIC_PLOT_DATA } from '../../../apollo/queries';
import { useApolloQuery } from '../../../apollo/utils';
import SelectDropdown from '../select-dropdown';
import { saveLocalStorage, loadLocalStorage } from '../../../store/helpers';
import { metricLimit, localStorageMetricsSelect } from '../../../config';
import {
  removeChildFromObject,
  removeElementsFromObjectValues,
} from '../../../utils/object-utils';

import './metrics-plots.css';

const tabLabels = ['Time-series', 'Parallel coordinates'];

const getSelectedDataFromDropdown = (
  runMetricsData,
  localRunMetricsData,
  selectedMetrics
) => {
  const metricsKeys =
    runMetricsData?.data && Object.keys(runMetricsData?.data.metrics);
  const originalMetricsData =
    runMetricsData?.data && runMetricsData?.data.metrics;
  const originalRunsData = runMetricsData?.data && runMetricsData?.data.runs;

  const toBeRemoved = {};

  metricsKeys.map((metric, index) => {
    if (selectedMetrics.indexOf(metric) === -1) {
      toBeRemoved[metric] = index;
    }
    return toBeRemoved;
  });

  const updatedMetrics = removeChildFromObject(
    originalMetricsData,
    Object.keys(toBeRemoved)
  );
  const updatedRuns = removeElementsFromObjectValues(
    originalRunsData,
    Object.values(toBeRemoved)
  );

  return {
    ...localRunMetricsData,
    metrics: updatedMetrics,
    runs: updatedRuns,
  };
};

const MetricsPlots = ({ selectedRunIds, sidebarVisible }) => {
  const [activeTab, setActiveTab] = useState(tabLabels[0]);
  const [chartHeight, setChartHeight] = useState(0);
  const [parCoordsWidth, setParCoordsWidth] = useState(0);
  const [timeSeriesWidth, setTimeSeriesWidth] = useState(0);
  const [containerWidth, setContainerWidth] = useState('auto');
  const [localRunMetricsData, setLocalRunMetricsData] = useState({});
  const [selectedDropdownValues, setSelectedDropdownValues] = useState(0);

  const { data: { runMetricsData = [] } = [] } = useApolloQuery(
    GET_METRIC_PLOT_DATA,
    {
      variables: { limit: metricLimit },
    }
  );

  const metrics =
    runMetricsData?.data && Object.keys(runMetricsData?.data.metrics);
  const numberOfMetrics = metrics ? metrics.length : 0;

  useEffect(() => {
    if (runMetricsData?.data) {
      const selectMetricsValues = loadLocalStorage(localStorageMetricsSelect);
      // We want to check the localStorage everytime the component re-loads
      // if value stored in localStorage
      // we can update the localRunMetricsData with the selected values from localStorage
      if (Object.keys(selectMetricsValues).length > 0) {
        setSelectedDropdownValues(selectMetricsValues[0]);

        const updatedRunData = getSelectedDataFromDropdown(
          runMetricsData,
          localRunMetricsData,
          selectMetricsValues[0]
        );
        setLocalRunMetricsData(updatedRunData);
      }
      // If value doesn't exist in localStorage yet
      // then we need to create it first
      else {
        const metricsKeys = Object.keys(runMetricsData.data.metrics);

        setSelectedDropdownValues(metricsKeys);
        setLocalRunMetricsData(runMetricsData.data);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [runMetricsData]);

  const onSelectedDropdownChanged = (selectedValues) => {
    const updatedRunData = getSelectedDataFromDropdown(
      runMetricsData,
      localRunMetricsData,
      selectedValues
    );
    setLocalRunMetricsData(updatedRunData);
    saveLocalStorage(localStorageMetricsSelect, [selectedValues]);
    setSelectedDropdownValues(selectedValues);
  };

  useEffect(() => {
    if (numberOfMetrics > 0) {
      if (numberOfMetrics > 5 && activeTab === tabLabels[1]) {
        setContainerWidth(numberOfMetrics * 200);
        setParCoordsWidth(numberOfMetrics * 200);
      } else {
        setContainerWidth('auto');
        setParCoordsWidth(
          document.querySelector('.metrics-plots-wrapper__charts').clientWidth
        );
      }
    }
  }, [activeTab, numberOfMetrics]);

  useEffect(() => {
    setTimeSeriesWidth(
      document.querySelector('.metrics-plots-wrapper__charts').clientWidth
    );
    setChartHeight(
      document.querySelector('.metrics-plots-wrapper__charts').clientHeight
    );
  }, []);

  return (
    <div className="metrics-plots-wrapper">
      <div className="metrics-plots-wrapper__header">
        <div className="kedro chart-types-wrapper">
          {tabLabels.map((tab) => {
            return (
              <div
                className={classnames('chart-types-wrapper__tab', {
                  'chart-types-wrapper__tab--active': activeTab === tab,
                })}
                key={tab}
                onClick={() => setActiveTab(tab)}
              >
                {tab}
              </div>
            );
          })}
        </div>
        <SelectDropdown
          dropdownValues={metrics}
          onChange={onSelectedDropdownChanged}
          selectedDropdownValues={selectedDropdownValues}
        />
      </div>

      <div
        className="metrics-plots-wrapper__charts"
        style={{ width: containerWidth }}
      >
        {selectedDropdownValues.length === 0 && (
          <ExperimentWarning
            title={'No data to display'}
            subTitle={'Select a metric to view a visualisation.'}
          />
        )}
        {Object.keys(localRunMetricsData).length > 0 ? (
          activeTab === tabLabels[0] ? (
            <TimeSeries
              chartWidth={timeSeriesWidth - 100}
              metricsData={localRunMetricsData}
              selectedRuns={selectedRunIds}
              sidebarVisible={sidebarVisible}
            />
          ) : (
            <ParallelCoordinates
              chartHeight={chartHeight}
              chartWidth={parCoordsWidth}
              metricsData={localRunMetricsData}
              selectedRuns={selectedRunIds}
              sidebarVisible={sidebarVisible}
            />
          )
        ) : null}
      </div>
    </div>
  );
};

export default MetricsPlots;

import React from 'react';
import classnames from 'classnames';
import Accordion from '../accordion';
import PinArrowIcon from '../../icons/pin-arrow';
import PlotlyChart from '../../plotly-chart';
import { sanitizeValue } from '../../../utils/experiment-tracking-utils';
import { TransitionGroup, CSSTransition } from 'react-transition-group';
import { DataSetLoader } from './run-dataset-loader';
import JSONObject from '../../json-object';

import getShortType from '../../../utils/short-type';
import './run-dataset.css';
import '../run-metadata/animation.css';

const determinePinIcon = (data, pinValue, pinnedRun) => {
  if (data.runId !== pinnedRun && typeof data.value === 'number') {
    if (data.value > pinValue) {
      return 'upArrow';
    }
    if (data.value < pinValue) {
      return 'downArrow';
    }
  }
  return null;
};

const determinePinDelta = (data, pinValue, pinnedRun) => {
  if (
    data.runId !== pinnedRun &&
    typeof data.value === 'number' &&
    data.value !== pinValue
  ) {
    const delta = data.value - pinValue;
    const deltaPercentage = Math.round((delta / Math.abs(pinValue)) * 100);

    return delta.toFixed(1) + ' (' + deltaPercentage + '%)';
  }

  return null;
};

const resolveRunDataWithPin = (runData, pinnedRun) => {
  const pinValue = runData.filter((data) => data.runId === pinnedRun)[0]?.value;

  if (typeof pinValue === 'number') {
    return runData.map((data) => ({
      pinIcon: determinePinIcon(data, pinValue, pinnedRun),
      pinDelta: determinePinDelta(data, pinValue, pinnedRun),
      ...data,
    }));
  }

  return runData;
};

/**
 * Display the dataset of the experiment tracking run.
 * @param {String} props.activeTab The selected tab (Overview || Plots).
 * @param {Boolean} enableComparisonView Whether or not the enableComparisonView is on.
 * @param {Boolean} props.enableShowChanges Are changes enabled or not.
 * @param {Boolean} props.isSingleRun Indication to display a single run.
 * @param {String} props.pinnedRun ID of the pinned run.
 * @param {Boolean} props.showLoader Whether to show the loading component.
 * @param {Object} props.trackingData The experiment tracking run data.
 * @param {String} props.theme The currently-selected light or dark theme.
 */
const RunDataset = ({
  activeTab,
  enableComparisonView,
  enableShowChanges,
  isSingleRun,
  pinnedRun,
  selectedRunIds,
  setRunDatasetToShow,
  setShowRunPlotsModal,
  showLoader,
  trackingData,
  theme,
}) => {
  if (!trackingData) {
    return null;
  }

  return (
    <div
      className={classnames('details-dataset', {
        'details-dataset--not-overview': activeTab !== 'Overview',
      })}
    >
      {Object.keys(trackingData)
        .filter((group) => {
          if (activeTab === 'Plots' && group === activeTab) {
            return true;
          }

          if (activeTab !== 'Plots' && group !== 'Plots') {
            return true;
          }

          return false;
        })
        .map((group) => {
          return (
            <Accordion
              className={classnames(
                'details-dataset__accordion',
                'details-dataset__accordion-wrapper',
                {
                  'details-dataset__accordion-wrapper-comparison-view':
                    enableComparisonView,
                }
              )}
              heading={group}
              headingClassName={classnames(
                'details-dataset__accordion-header',
                {
                  'details-dataset__accordion-header--hidden':
                    group === 'Plots',
                }
              )}
              key={group}
              layout="left"
              size="large"
            >
              {trackingData[group].length === 0 && (
                <div className="details-dataset__row">
                  <span
                    className="details-dataset__name-header"
                    style={{
                      visibility: enableComparisonView ? 'hidden' : 'visible',
                    }}
                  >
                    No data to display. Try selecting a different run.
                  </span>
                  <TransitionGroup
                    component="div"
                    className="details-dataset__transition-group-wrapper"
                  >
                    {selectedRunIds.map((id, index) => {
                      return (
                        <CSSTransition
                          classNames="details-dataset__value-animation"
                          enter={isSingleRun ? false : true}
                          exit={isSingleRun ? false : true}
                          key={id}
                          timeout={300}
                        >
                          <span
                            className={classnames(
                              'details-dataset__value-header',
                              {
                                'details-dataset__value-header--comparison-view':
                                  enableComparisonView && index === 0,
                              }
                            )}
                            style={{
                              display: enableComparisonView ? 'flex' : 'none',
                            }}
                          >
                            No data to display. Try selecting a different run.
                          </span>
                        </CSSTransition>
                      );
                    })}
                  </TransitionGroup>
                </div>
              )}
              {trackingData[group].map((dataset) => {
                const { data, datasetType, datasetName, runIds } = dataset;

                return (
                  <Accordion
                    className="details-dataset__accordion"
                    heading={datasetName}
                    headingClassName="details-dataset__accordion-header"
                    isHyperlink
                    key={datasetName}
                    layout="left"
                    linkTitle="Show me where this dataset is located in the flowchart"
                    size="medium"
                  >
                    {Object.keys(data)
                      .sort((a, b) => {
                        return a.localeCompare(b);
                      })
                      .map((key, rowIndex) => {
                        const updatedDatasetValues = fillEmptyMetrics(
                          dataset.data[key],
                          runIds
                        );
                        const runDataWithPin = resolveRunDataWithPin(
                          updatedDatasetValues,
                          pinnedRun
                        );

                        return buildDatasetDataMarkup(
                          key,
                          runDataWithPin,
                          datasetType,
                          rowIndex,
                          isSingleRun,
                          enableComparisonView,
                          enableShowChanges,
                          setRunDatasetToShow,
                          setShowRunPlotsModal,
                          showLoader,
                          theme
                        );
                      })}
                  </Accordion>
                );
              })}
            </Accordion>
          );
        })}
    </div>
  );
};

/**
 * Build the necessary markup used to display the run dataset.
 * @param {String} datasetKey The row label of the data.
 * @param {Array} datasetValues A single dataset array from a run.
 * @param {Number} rowIndex The array index of the dataset data.
 * @param {Boolean} isSingleRun Whether or not this is a single run.
 * @param {Boolean} enableShowChanges Are changes enabled or not.
 * @param {Boolean} enableComparisonView Whether or not the enableComparisonView is on.
 * @param {Function} setRunDatasetToShow Callback function to show runDataset.
 * @param {Function} setShowRunPlotsModal Callback function to show RunPlot modal.
 */
function buildDatasetDataMarkup(
  datasetKey,
  datasetValues,
  datasetType,
  rowIndex,
  isSingleRun,
  enableComparisonView,
  enableShowChanges,
  setRunDatasetToShow,
  setShowRunPlotsModal,
  showLoader,
  theme
) {
  const isPlotlyDataset = getShortType(datasetType) === 'plotly';
  const isImageDataset = getShortType(datasetType) === 'image';
  const isJSONTrackingDataset = getShortType(datasetType) === 'JSONTracking';
  const isMetricsTrackingDataset =
    getShortType(datasetType) === 'metricsTracking';
  const isTrackingDataset = isJSONTrackingDataset || isMetricsTrackingDataset;

  const onExpandVizClick = () => {
    setShowRunPlotsModal(true);
    setRunDatasetToShow({ datasetKey, datasetType, datasetValues });
  };

  return (
    <React.Fragment key={datasetKey + rowIndex}>
      {rowIndex === 0 ? (
        <div className="details-dataset__row">
          <span className="details-dataset__name-header">Name</span>
          <TransitionGroup
            component="div"
            className="details-dataset__transition-group-wrapper"
          >
            {datasetValues.map((data, index) => (
              <CSSTransition
                key={data.runId}
                timeout={300}
                classNames="details-dataset__value-animation"
                enter={isSingleRun ? false : true}
                exit={isSingleRun ? false : true}
              >
                <span
                  className={classnames('details-dataset__value-header', {
                    'details-dataset__value-header--comparison-view':
                      index === 0 && enableComparisonView,
                  })}
                >
                  Value
                </span>
              </CSSTransition>
            ))}
          </TransitionGroup>
          {showLoader && (
            <DataSetLoader
              length={datasetValues.length}
              theme={theme}
              x={0}
              y={12}
            />
          )}
        </div>
      ) : null}
      <div className="details-dataset__row">
        <span className={'details-dataset__label'}>{datasetKey}</span>
        <TransitionGroup
          component="div"
          className="details-dataset__transition-group-wrapper"
        >
          {datasetValues.map((run, index) => {
            const isSinglePinnedRun = datasetValues.length === 1;
            const isJSONObject = run.value && typeof run.value === 'object';

            return (
              <CSSTransition
                key={run.runId}
                timeout={300}
                classNames="details-dataset__value-animation"
                enter={isSinglePinnedRun ? false : true}
                exit={isSinglePinnedRun ? false : true}
              >
                <span
                  className={classnames('details-dataset__value', {
                    'details-dataset__value--comparison-view':
                      index === 0 && enableComparisonView,
                  })}
                >
                  {isTrackingDataset && !isJSONObject && (
                    <>
                      {sanitizeValue(run.value)}
                      {enableShowChanges && <PinArrowIcon icon={run.pinIcon} />}
                      {enableShowChanges && (
                        <span className="details-dataset__deltaValue">
                          {run.pinDelta}
                        </span>
                      )}
                    </>
                  )}
                  {isJSONTrackingDataset && isJSONObject && (
                    <JSONObject
                      value={run.value}
                      theme={theme}
                      empty="-"
                      kind="text"
                    />
                  )}

                  {isPlotlyDataset &&
                    (run.value ? (
                      <div
                        className="details-dataset__visualization-wrapper"
                        onClick={onExpandVizClick}
                      >
                        <PlotlyChart
                          data={run.value.data}
                          layout={run.value.layout}
                          view="experiment_preview"
                        />
                      </div>
                    ) : (
                      fillEmptyPlots()
                    ))}

                  {isImageDataset &&
                    (run.value ? (
                      <div
                        className="details-dataset__image-container"
                        onClick={onExpandVizClick}
                      >
                        <img
                          alt="Matplotlib rendering"
                          className="details-dataset__image"
                          src={`data:image/png;base64,${run.value}`}
                        />
                      </div>
                    ) : (
                      fillEmptyPlots()
                    ))}
                </span>
              </CSSTransition>
            );
          })}
        </TransitionGroup>
        {showLoader && (
          <DataSetLoader
            length={datasetValues.length}
            theme={theme}
            x={0}
            y={12}
          />
        )}
      </div>
    </React.Fragment>
  );
}

/**
 * Fill in missing run metrics if they don't match the number of runIds.
 * @param {Array} datasetValues Array of objects for a metric, e.g. r2_score.
 * @param {Array} runIds Array of strings of runIds.
 * @returns Array of objects, the length of which matches the length
 * of the runIds.
 */
function fillEmptyMetrics(datasetValues, runIds) {
  if (datasetValues.length === runIds.length) {
    return datasetValues;
  }

  const metrics = [];

  runIds.forEach((id) => {
    const foundIdIndex = datasetValues.findIndex((item) => {
      return item.runId === id;
    });

    // We didn't find a metric with this runId, so add a placeholder.
    if (foundIdIndex === -1) {
      metrics.push({ runId: id, value: null });
    } else {
      metrics.push(datasetValues[foundIdIndex]);
    }
  });

  return metrics;
}

function fillEmptyPlots() {
  return <div className="details-dataset__empty-plot">No plot available</div>;
}

export default RunDataset;

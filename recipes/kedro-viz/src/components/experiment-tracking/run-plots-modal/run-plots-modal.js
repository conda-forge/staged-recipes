import React, { useEffect } from 'react';
import PlotlyChart from '../../plotly-chart';
import BackWideIcon from '../../icons/back-wide';
import NodeIcon from '../../icons/node-icon';
import getShortType from '../../../utils/short-type';
import { toHumanReadableTime } from '../../../utils/date-utils';
import classNames from 'classnames';
import './run-plots-modal.css';

const RunPlotsModal = ({ runDatasetToShow, visible, setShowRunPlotsModal }) => {
  const { datasetKey, datasetType, datasetValues } = runDatasetToShow;
  const runDataWithPlotData = datasetValues?.filter(({ value }) => value);
  const numDatasets = runDataWithPlotData?.length;
  const plotView =
    numDatasets === 3
      ? 'threeCharts'
      : numDatasets === 2
      ? 'twoCharts'
      : 'oneChart';
  const isPlotly = getShortType(datasetType) === 'plotly';
  const isImage = getShortType(datasetType) === 'image';
  const nodeTypeIcon = getShortType(datasetType);

  const handleKeyDown = (event) => {
    if (event.keyCode === 27) {
      setShowRunPlotsModal(false);
    }
  };

  useEffect(() => {
    if (visible) {
      window.addEventListener('keydown', handleKeyDown);
    }

    return () => window.removeEventListener('keydown', handleKeyDown);
  });

  if (!visible) {
    return null;
  }

  return (
    <div className="pipeline-run-plots-modal">
      <div className="pipeline-run-plots-modal__top">
        <button
          className="pipeline-run-plots-modal__back"
          onClick={() => setShowRunPlotsModal(false)}
        >
          <BackWideIcon className="pipeline-run-plots-modal__back-icon"></BackWideIcon>
          <span className="pipeline-run-plots-modal__back-text">Back</span>
        </button>
        <div className="pipeline-run-plots-modal__header">
          <NodeIcon
            className="pipeline-run-plots-modal__icon"
            icon={nodeTypeIcon}
          />
          <span className="pipeline-run-plots-modal__title">{datasetKey}</span>
        </div>
      </div>
      <div
        className={classNames(
          'pipeline-run-plots-modal__content',
          `pipeline-run-plots-modal__content--${plotView}`,
          {
            'pipeline-run-plots-modal__content--plotly': isPlotly,
          }
        )}
      >
        {isPlotly &&
          runDataWithPlotData.map((data) => {
            return (
              data.value && (
                <div
                  className={classNames(
                    'pipeline-run-plots__plot-wrapper',
                    `pipeline-run-plots__plot-wrapper--${plotView}`
                  )}
                  key={data.runId}
                >
                  <PlotlyChart
                    data={data.value.data}
                    layout={data.value.layout}
                    view={plotView}
                  />
                  <div className="pipeline-run-plots-image-text">
                    <span className="pipeline-run-plots-image-text-timestamp">
                      {data.runId}
                    </span>
                    <span className="pipeline-run-plots-image-text-relative_timestamp">
                      {toHumanReadableTime(data.runId)}
                    </span>
                  </div>
                </div>
              )
            );
          })}
        {isImage &&
          runDataWithPlotData.map((data) => {
            return (
              <div
                className={classNames(
                  `pipeline-run-plots__image-wrapper`,
                  `pipeline-run-plots__image-wrapper--${plotView}`
                )}
                key={data.runId}
              >
                <img
                  alt="Matplotlib rendering"
                  className={classNames(
                    `pipeline-run-plots__image--${plotView}`
                  )}
                  src={`data:image/png;base64,${data.value}`}
                />
                <div className="pipeline-run-plots-image-text">
                  <span className="pipeline-run-plots-image-text-timestamp">
                    {data.runId}
                  </span>
                  <span className="pipeline-run-plots-image-text-relative_timestamp">
                    {toHumanReadableTime(data.runId)}
                  </span>
                </div>
              </div>
            );
          })}
      </div>
    </div>
  );
};

export default RunPlotsModal;

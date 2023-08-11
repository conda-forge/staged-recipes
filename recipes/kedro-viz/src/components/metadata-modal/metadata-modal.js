import React from 'react';
import { connect } from 'react-redux';
import PlotlyChart from '../plotly-chart';
import PreviewTable from '../preview-table';
import CollapseIcon from '../icons/collapse';
import BackIcon from '../icons/back';
import NodeIcon from '../icons/node-icon';
import { togglePlotModal } from '../../actions';
import getShortType from '../../utils/short-type';
import { getClickedNodeMetaData } from '../../selectors/metadata';
import './metadata-modal.css';

const MetadataModal = ({ metadata, onToggle, visible }) => {
  const hasPlot = Boolean(metadata?.plot);
  const hasImage = Boolean(metadata?.image);
  const hasPreview = Boolean(metadata?.preview);

  if (!visible.metadataModal || (!hasPlot && !hasImage && !hasPreview)) {
    return null;
  }

  const nodeTypeIcon = getShortType(metadata?.datasetType, metadata?.type);

  const onCollapsePlotClick = () => {
    onToggle(false);
  };

  return (
    <div className="pipeline-metadata-modal">
      <div className="pipeline-metadata-modal__top">
        <button
          className="pipeline-metadata-modal__back"
          onClick={onCollapsePlotClick}
        >
          <BackIcon className="pipeline-metadata-modal__back-icon"></BackIcon>
          <span className="pipeline-metadata-modal__back-text">Back</span>
        </button>
        <div className="pipeline-metadata-modal__header">
          <NodeIcon
            className="pipeline-metadata-modal__icon"
            icon={nodeTypeIcon}
          />
          <span className="pipeline-metadata-modal__title">
            {metadata.name}
          </span>
        </div>
        {hasPreview && (
          <div className="pipeline-metadata-modal__preview-text">
            Previewing first {metadata.preview.data.length} rows
          </div>
        )}
      </div>
      {hasPlot && (
        <PlotlyChart
          data={metadata.plot.data}
          layout={metadata.plot.layout}
          view="modal"
        />
      )}
      {hasImage && (
        <div className="pipeline-matplotlib-chart">
          <div className="pipeline-metadata__plot-image-container">
            <img
              alt="Matplotlib rendering"
              className="pipeline-metadata__plot-image--expanded"
              src={`data:image/png;base64,${metadata.image}`}
            />
          </div>
        </div>
      )}
      {hasPreview && (
        <div className="pipeline-metadata-modal__preview">
          <PreviewTable data={metadata.preview} size="large" />
        </div>
      )}
      {!hasPreview && (
        <div className="pipeline-metadata-modal__bottom">
          <button
            className="pipeline-metadata-modal__collapse-plot"
            onClick={onCollapsePlotClick}
          >
            <CollapseIcon className="pipeline-metadata-modal__collapse-plot-icon"></CollapseIcon>
            <span className="pipeline-metadata-modal__collapse-plot-text">
              {hasPlot
                ? 'Collapse Plotly Visualization'
                : 'Collapse Matplotlib Image'}
            </span>
          </button>
        </div>
      )}
    </div>
  );
};

export const mapStateToProps = (state) => ({
  metadata: getClickedNodeMetaData(state),
  theme: state.theme,
  visible: state.visible,
});

export const mapDispatchToProps = (dispatch) => ({
  onToggle: (value) => {
    dispatch(togglePlotModal(value));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(MetadataModal);

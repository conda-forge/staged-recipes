import React from 'react';
import { connect } from 'react-redux';
import { toggleMiniMap, updateZoom } from '../../actions';
import { getChartZoom } from '../../selectors/layout';
import IconButton from '../ui/icon-button';
import MapIcon from '../icons/map';
import PlusIcon from '../icons/plus';
import MinusIcon from '../icons/minus';
import ResetIcon from '../icons/reset';
import './minimap-toolbar.css';

/**
 * Controls for minimap
 */
export const MiniMapToolbar = ({
  chartZoom,
  displayMiniMap,
  onToggleMiniMap,
  onUpdateChartZoom,
  visible,
}) => {
  const { scale, minScale, maxScale } = chartZoom;

  return (
    <>
      <ul className="pipeline-minimap-toolbar kedro">
        {displayMiniMap && (
          <IconButton
            active={visible.miniMap}
            ariaLabel={`Turn minimap ${visible.miniMap ? 'off' : 'on'}`}
            className={'pipeline-minimap-button pipeline-minimap-button--map'}
            dataTest={`btnToggleMinimap`}
            icon={MapIcon}
            labelText={`${visible.miniMap ? 'Hide' : 'Show'} minimap`}
            onClick={() => onToggleMiniMap(!visible.miniMap)}
            visible={visible.miniMapBtn}
          />
        )}
        <IconButton
          ariaLabel={'Zoom in'}
          className={'pipeline-minimap-button pipeline-minimap-button--zoom-in'}
          dataTest={`btnZoomIn`}
          disabled={scale >= maxScale}
          icon={PlusIcon}
          labelText={'Zoom in'}
          onClick={() => onUpdateChartZoom(scaleZoom(chartZoom, 1.3))}
          visible={visible.miniMapBtn}
        />
        <IconButton
          ariaLabel={'Zoom out'}
          className={
            'pipeline-minimap-button pipeline-minimap-button--zoom-out'
          }
          dataTest={`btnZoomOut`}
          disabled={scale <= minScale}
          icon={MinusIcon}
          labelText={'Zoom out'}
          onClick={() => onUpdateChartZoom(scaleZoom(chartZoom, 0.7))}
          visible={visible.miniMapBtn}
        />
        <IconButton
          ariaLabel={'Reset zoom'}
          className={'pipeline-minimap-button pipeline-minimap-button--reset'}
          dataTest={`btnResetZoom`}
          icon={ResetIcon}
          labelText={'Reset zoom'}
          onClick={() => onUpdateChartZoom(scaleZoom(chartZoom, 0))}
          visible={visible.miniMapBtn}
        />
        <li>
          <span className="pipeline-minimap-toolbar__scale" title="Zoom level">
            {Math.round(100 * chartZoom.scale) || 100}%
          </span>
        </li>
      </ul>
    </>
  );
};

const scaleZoom = ({ scale }, factor) => ({
  scale: scale * (factor || 1),
  applied: false,
  transition: true,
  reset: factor === 0,
});

export const mapStateToProps = (state) => ({
  visible: state.visible,
  displayMiniMap: state.display.miniMap,
  chartZoom: getChartZoom(state),
});

export const mapDispatchToProps = (dispatch) => ({
  onToggleMiniMap: (value) => {
    dispatch(toggleMiniMap(value));
  },
  onUpdateChartZoom: (transform) => {
    dispatch(updateZoom(transform));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(MiniMapToolbar);

import React, { Component } from 'react';
import { connect } from 'react-redux';
import 'd3-transition';
import { select } from 'd3-selection';
import { getNodeActive, getNodeSelected } from '../../selectors/nodes';
import { updateZoom } from '../../actions';
import { getChartSize, getChartZoom } from '../../selectors/layout';
import { getLinkedNodes } from '../../selectors/linked-nodes';
import {
  viewing,
  isOrigin,
  viewTransformToFit,
  getViewTransform,
  setViewTransformExact,
} from '../../utils/view';
import { drawNodes, drawViewport } from './draw';
import './styles/minimap.css';

/**
 * Display a pipeline minimap, mostly rendered with D3
 */
export class MiniMap extends Component {
  constructor(props) {
    super(props);

    this.DURATION = 700;
    this.TRANSITION_WAIT = 200;
    this.ZOOM_RATE = 0.0025;

    this.isPointerDown = false;
    this.isPointerInside = false;
    this.lastTransitionTime = 0;

    this.containerRef = React.createRef();
    this.svgRef = React.createRef();
    this.wrapperRef = React.createRef();
    this.nodesRef = React.createRef();
    this.viewportRef = React.createRef();

    this.onPointerMove = this.onPointerMove.bind(this);
    this.onPointerEnter = this.onPointerEnter.bind(this);
    this.onPointerLeave = this.onPointerLeave.bind(this);
    this.onPointerDown = this.onPointerDown.bind(this);
    this.onPointerWheel = this.onPointerWheel.bind(this);
    this.onPointerWheelGlobal = this.onPointerWheelGlobal.bind(this);
    this.onPointerUpGlobal = this.onPointerUpGlobal.bind(this);
  }

  componentDidMount() {
    this.selectD3Elements();

    this.view = viewing({
      container: this.svgRef,
      wrapper: this.wrapperRef,
      allowUserInput: false,
    });

    this.addGlobalEventListeners();
    this.update();
  }

  componentWillUnmount() {
    this.removeGlobalEventListeners();
  }

  /**
   * Add window event listeners
   */
  addGlobalEventListeners() {
    window.addEventListener('wheel', this.onPointerWheelGlobal, {
      passive: false,
    });
    window.addEventListener(
      pointerEventName('pointerup'),
      this.onPointerUpGlobal
    );
  }

  /**
   * Remove window event listeners
   */
  removeGlobalEventListeners() {
    window.removeEventListener('wheel', this.onPointerWheelGlobal);
    window.removeEventListener(
      pointerEventName('pointerup'),
      this.onPointerUpGlobal
    );
  }

  componentDidUpdate(prevProps) {
    this.update(prevProps);
  }

  /**
   * Updates drawing and zoom if props have changed
   */
  update(prevProps = {}) {
    const { visible, chartZoom } = this.props;

    if (visible) {
      const changed = (...names) => this.changed(names, prevProps, this.props);

      if (
        changed(
          'visible',
          'nodes',
          'clickedNodes',
          'linkedNodes',
          'nodesActive',
          'nodeSelected'
        )
      ) {
        drawNodes.call(this);
      }

      if (changed('visible', 'chartZoom') && chartZoom.applied) {
        drawViewport.call(this);
      }

      if (changed('visible', 'nodes', 'textLabels', 'chartSize')) {
        this.resetView();
      }
    }
  }

  /**
   * Returns true if any of the given props are different between given objects.
   * Only shallow changes are detected.
   */
  changed(props, objectA, objectB) {
    return (
      objectA &&
      objectB &&
      props.some((prop) => objectA[prop] !== objectB[prop])
    );
  }

  /**
   * Create D3 element selectors
   */
  selectD3Elements() {
    this.el = {
      svg: select(this.svgRef.current),
      wrapper: select(this.wrapperRef.current),
      nodeGroup: select(this.nodesRef.current),
      viewport: select(this.viewportRef.current),
    };
  }

  /**
   * Handle pointer enter
   */
  onPointerEnter = () => {
    this.isPointerInside = true;
  };

  /**
   * Handle pointer leave
   */
  onPointerLeave = () => {
    this.isPointerInside = false;
  };

  /**
   * Handle global pointer up
   */
  onPointerUpGlobal = () => {
    this.isPointerDown = false;
    this.isPointerInside = false;
  };

  /**
   * Handle pointer down
   * @param {Object} event Event object
   */
  onPointerDown = (event) => {
    this.isPointerDown = true;
    this.isPointerInside = true;

    this.onPointerMove(event, true);
  };

  /**
   * Handle pointer wheel
   * @param {Object} event Event object
   */
  onPointerWheel = (event) => {
    // Change zoom based on wheel velocity
    this.props.onUpdateChartZoom({
      relative: true,
      scale: -(event.deltaY || 0) * this.ZOOM_RATE,
      applied: false,
      transition: false,
    });
  };

  /**
   * Handle global pointer wheel
   * @param {Object} event Event object
   */
  onPointerWheelGlobal = (event) => {
    // Prevent window scroll when wheeling on this minimap
    const wasTarget = this.containerRef.current.contains(event.target);
    if (wasTarget) {
      event.preventDefault();
    }
  };

  /**
   * Handle pointer move
   * @param {Object} event Event object
   * @param {?Boolean} useTransition Apply with transition
   */
  onPointerMove = (event, useTransition = false) => {
    if (this.isPointerDown && this.isPointerInside) {
      // Wait for transition
      const time = Number(new Date());
      if (time - this.lastTransitionTime < this.TRANSITION_WAIT) {
        return;
      }

      // Get current state
      const { scale: chartScale = 1 } = this.props.chartZoom;
      const { width, height } = this.props.mapSize;
      const { width: graphWidth, height: graphHeight } = this.props.graphSize;
      const { k: scale = 1 } = getViewTransform(this.view);
      const containerRect = this.svgRef.current.getBoundingClientRect();

      // Transform minimap pointer position to a graph position
      const pointerX = (event.clientX - containerRect.x) / scale;
      const pointerY = (event.clientY - containerRect.y) / scale;
      const centerX = (width / scale - graphWidth) * 0.5;
      const centerY = (height / scale - graphHeight) * 0.5;
      const x = (pointerX - centerX) * chartScale;
      const y = (pointerY - centerY) * chartScale;

      // Dispatch an update to be applied
      this.props.onUpdateChartZoom({
        x,
        y,
        scale: chartScale,
        relative: false,
        applied: false,
        transition: useTransition,
      });

      if (useTransition) {
        this.lastTransitionTime = time;
      }
    }
  };

  /**
   * Zoom and scale to fit
   */
  resetView() {
    const { graphSize, mapSize } = this.props;
    const { width: mapWidth, height: mapHeight } = mapSize;
    const { width: graphWidth, height: graphHeight } = graphSize;

    // Skip if chart or graph is not ready yet
    if (!mapWidth || !graphWidth) {
      return;
    }

    // Padding offset
    const offset = { x: padding * 0.5, y: padding * 0.5 };

    // Find a transform that fits everything in view
    const transform = viewTransformToFit({
      offset,
      viewWidth: mapWidth - padding,
      viewHeight: mapHeight - padding,
      objectWidth: graphWidth,
      objectHeight: graphHeight,
    });

    // Detect first transform
    const isFirstTransform = isOrigin(getViewTransform(this.view));

    // Apply transform ignoring extents
    setViewTransformExact(
      this.view,
      transform,
      isFirstTransform ? 0 : this.DURATION,
      false
    );
  }

  /**
   * Get the position of the viewport relative to the minimap
   */
  getViewport() {
    const { chartZoom, chartSize } = this.props;
    const {
      k: mapScale,
      x: translateX,
      y: translateY,
    } = getViewTransform(this.view);

    const scale = mapScale / chartZoom.scale;
    const width = chartSize.width * scale;
    const height = chartSize.height * scale;
    const x = -translateX - (chartZoom.x - chartSize.sidebarWidth) * scale;
    const y = -translateY - chartZoom.y * scale;

    return { x, y, width, height };
  }

  /**
   * Render React elements
   */
  render() {
    const { width, height } = this.props.mapSize;
    const transformStyle = {
      transform: `translate(calc(-100% + ${width}px), -100%)`,
    };

    // Add pointer events with back compatibility
    const _ = pointerEventName;
    const inputEvents = {
      onWheel: this.onPointerWheel,
      [_('onPointerEnter')]: this.onPointerEnter,
      [_('onPointerLeave')]: this.onPointerLeave,
      [_('onPointerDown')]: this.onPointerDown,
      [_('onPointerMove')]: this.onPointerMove,
    };

    return (
      <div
        className="pipeline-minimap-container"
        style={this.props.visible ? transformStyle : {}}
      >
        <div
          className="pipeline-minimap kedro"
          ref={this.containerRef}
          {...inputEvents}
        >
          <svg
            id="pipeline-minimap-graph"
            className="pipeline-minimap__graph"
            width={width}
            height={height}
            viewBox={`0 0 ${width} ${height}`}
            ref={this.svgRef}
          >
            <g id="zoom-wrapper" ref={this.wrapperRef}>
              <g
                id="minimap-nodes"
                className="pipeline-minimap__nodes"
                ref={this.nodesRef}
              />
            </g>
            <rect
              className="pipeline-minimap__viewport"
              ref={this.viewportRef}
            />
          </svg>
        </div>
      </div>
    );
  }
}

// Map sizing constants
const padding = 32;
const height = 220;
const minWidth = 218;
const maxWidth = 1.5 * minWidth;

/**
 * Convert pointer event name to a mouse event name if not supported
 */
const pointerEventName = (event) =>
  window.PointerEvent
    ? event
    : event.replace('pointer', 'mouse').replace('Pointer', 'Mouse');

/**
 * Gets the map sizing that fits the graph in state
 */
const getMapSize = (state) => {
  const size = state.graph.size || {};
  const graphWidth = size.width || 0;
  const graphHeight = size.height || 0;

  if (graphWidth > 0 && graphHeight > 0) {
    // Constrain width
    const scaledWidth = graphWidth * (height / graphHeight);
    const width = Math.min(Math.max(scaledWidth, minWidth), maxWidth);

    return { width, height };
  }

  // Use minimum size if no graph
  return { width: minWidth, height: height };
};

// Maintain a single reference to support change detection
const emptyNodes = [];
const emptyGraphSize = {};

export const mapStateToProps = (state, ownProps) => ({
  visible: state.visible.miniMap,
  mapSize: getMapSize(state),
  clickedNode: state.node.clicked,
  chartSize: getChartSize(state),
  chartZoom: getChartZoom(state),
  graphSize: state.graph.size || emptyGraphSize,
  nodes: state.graph.nodes || emptyNodes,
  linkedNodes: getLinkedNodes(state),
  nodeActive: getNodeActive(state),
  nodeSelected: getNodeSelected(state),
  textLabels: state.textLabels,
  ...ownProps,
});

export const mapDispatchToProps = (dispatch, ownProps) => ({
  onUpdateChartZoom: (transform) => {
    dispatch(updateZoom(transform));
  },
  ...ownProps,
});

export default connect(mapStateToProps, mapDispatchToProps)(MiniMap);

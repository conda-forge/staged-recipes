import React, { Component } from 'react';
import { connect } from 'react-redux';
import classnames from 'classnames';
import { select } from 'd3-selection';
import { updateChartSize, updateZoom } from '../../actions';
import { toggleSingleModularPipelineExpanded } from '../../actions/modular-pipelines';
import { loadNodeData, toggleNodeHovered } from '../../actions/nodes';
import {
  getNodeActive,
  getNodeSelected,
  getNodesWithInputParams,
  getInputOutputNodesForFocusedModularPipeline,
} from '../../selectors/nodes';
import { getInputOutputDataEdges } from '../../selectors/edges';
import { getChartSize, getChartZoom } from '../../selectors/layout';
import { getLayers } from '../../selectors/layers';
import { getLinkedNodes } from '../../selectors/linked-nodes';
import { getVisibleMetaSidebar } from '../../selectors/metadata';
import { drawNodes, drawEdges, drawLayers, drawLayerNames } from './draw';
import {
  viewing,
  isOrigin,
  viewTransformToFit,
  setViewTransform,
  getViewTransform,
  setViewTransformExact,
  setViewExtents,
  getViewExtents,
} from '../../utils/view';
import Tooltip from '../ui/tooltip';
import './styles/flowchart.css';

/**
 * Display a pipeline flowchart, mostly rendered with D3
 */
export class FlowChart extends Component {
  constructor(props) {
    super(props);

    this.state = {
      tooltip: { visible: false },
      activeLayer: undefined,
    };
    this.onViewChange = this.onViewChange.bind(this);
    this.onViewChangeEnd = this.onViewChangeEnd.bind(this);

    this.containerRef = React.createRef();
    this.svgRef = React.createRef();
    this.wrapperRef = React.createRef();
    this.edgesRef = React.createRef();
    this.nodesRef = React.createRef();
    this.layersRef = React.createRef();
    this.layerNamesRef = React.createRef();

    this.DURATION = 700;
    this.MARGIN = 500;
    this.MIN_SCALE = 0.8;
    this.MAX_SCALE = 2;
  }

  componentDidMount() {
    this.selectD3Elements();
    this.updateChartSize();

    this.view = viewing({
      container: this.svgRef,
      wrapper: this.wrapperRef,
      onViewChanged: this.onViewChange,
      onViewEnd: this.onViewChangeEnd,
    });

    this.updateViewExtents();
    this.addGlobalEventListeners();
    this.update();

    if (this.props.tooltip) {
      this.showTooltip(null, null, this.props.tooltip);
    } else {
      this.hideTooltip();
    }
  }

  componentWillUnmount() {
    this.removeGlobalEventListeners();
  }

  componentDidUpdate(prevProps) {
    this.update(prevProps);
  }

  /**
   * Updates drawing and zoom if props have changed
   */
  update(prevProps = {}) {
    const { chartZoom } = this.props;
    const changed = (...names) => this.changed(names, prevProps, this.props);
    const preventZoom = this.props.visibleMetaSidebar;

    if (changed('visibleSidebar', 'visibleCode', 'visibleMetaSidebar')) {
      this.updateChartSize();
    }

    if (changed('layers', 'chartSize')) {
      drawLayers.call(this);
      drawLayerNames.call(this);
    }

    if (
      changed(
        'edges',
        'clickedNode',
        'linkedNodes',
        'focusMode',
        'inputOutputDataEdges'
      )
    ) {
      drawEdges.call(this, changed);
    }

    if (
      changed(
        'nodes',
        'clickedNode',
        'linkedNodes',
        'nodeTypeDisabled',
        'nodeActive',
        'nodeSelected',
        'hoveredParameters',
        'nodesWithInputParams',
        'focusMode',
        'inputOutputDataNodes',
        'hoveredFocusMode'
      )
    ) {
      drawNodes.call(this, changed);
    }

    if (changed('edges', 'nodes', 'layers', 'chartSize', 'clickedNode')) {
      // Don't zoom out when the metadata or code panels are opened or closed
      if (prevProps.visibleMetaSidebar !== this.props.visibleMetaSidebar) {
        drawNodes.call(this, changed);
        drawEdges.call(this, changed);

        return;
      }

      if (prevProps.visibleCode !== this.props.visibleCode) {
        if (!this.props.visibleMetaSidebar) {
          drawNodes.call(this, changed);
          drawEdges.call(this, changed);

          return;
        }
      }

      this.resetView(preventZoom);
    } else {
      this.onChartZoomChanged(chartZoom);
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
      edgeGroup: select(this.edgesRef.current),
      nodeGroup: select(this.nodesRef.current),
      layerGroup: select(this.layersRef.current),
      layerNameGroup: select(this.layerNamesRef.current),
    };
  }

  /**
   * Update the chart size in state from chart container bounds.
   * This is emulated in tests with a constant fixed size.
   */
  updateChartSize() {
    if (typeof jest !== 'undefined') {
      // Emulate chart size for tests
      this.props.onUpdateChartSize(chartSizeTestFallback);
    } else {
      // Use container bounds
      this.props.onUpdateChartSize(
        this.containerRef.current.getBoundingClientRect()
      );
    }
  }

  /**
   * Add window event listeners on mount
   */
  addGlobalEventListeners() {
    // Add ResizeObserver to listen for any changes in the container's width/height
    // (with event listener fallback)
    if (window.ResizeObserver) {
      this.resizeObserver =
        this.resizeObserver ||
        new window.ResizeObserver(this.handleWindowResize);
      this.resizeObserver.observe(this.containerRef.current);
    } else {
      window.addEventListener('resize', this.handleWindowResize);
    }
    // Print event listeners
    window.addEventListener('beforeprint', this.handleBeforePrint);
    window.addEventListener('afterprint', this.handleAfterPrint);
  }

  /**
   * Remove window event listeners on unmount
   */
  removeGlobalEventListeners() {
    // ResizeObserver
    if (window.ResizeObserver) {
      this.resizeObserver.unobserve(this.containerRef.current);
    } else {
      window.removeEventListener('resize', this.handleWindowResize);
    }
    // Print event listeners
    window.removeEventListener('beforeprint', this.handleBeforePrint);
    window.removeEventListener('afterprint', this.handleAfterPrint);
  }

  /**
   * Handle window resize
   */
  handleWindowResize = () => {
    this.updateChartSize();
  };

  /**
   * Add viewBox on window print so that the SVG can be scaled to fit
   */
  handleBeforePrint = () => {
    const graphSize = this.props.graphSize;
    const width = graphSize.width + graphSize.marginx * 2;
    const height = graphSize.height + graphSize.marginy * 2;
    this.el.svg.attr('viewBox', `0 0 ${width} ${height}`);
  };

  /**
   * Remove viewBox once printing is done
   */
  handleAfterPrint = () => {
    this.el.svg.attr('viewBox', null);
  };

  /**
   * On every frame of every view transform change (from reset, pan, zoom etc.)
   * @param {Object} transform The current view transform
   */
  onViewChange(transform) {
    const { k: scale, x, y } = transform;

    // Apply animating class to zoom wrapper
    this.el.wrapper.classed(
      'pipeline-flowchart__zoom-wrapper--animating',
      true
    );

    // Update layer label y positions
    if (this.el.layerNames) {
      this.el.layerNames.style('transform', (d) => {
        const updateY = y + (d.y + d.height / 2) * scale;
        return `translateY(${updateY}px)`;
      });
    }

    // Hide the tooltip so it doesn't get misaligned to its node
    this.hideTooltip();

    // Update extents
    this.updateViewExtents(transform);
    const extents = getViewExtents(this.view);

    // Share the applied zoom state with other components
    this.props.onUpdateZoom({
      scale,
      x,
      y,
      applied: true,
      transition: false,
      relative: false,
      minScale: extents.scale.minK,
      maxScale: extents.scale.maxK,
    });
  }

  /**
   * Called when the view changes have ended (i.e. after transition ends)
   */
  onViewChangeEnd() {
    this.el.wrapper.classed(
      'pipeline-flowchart__zoom-wrapper--animating',
      false
    );
  }

  /**
   * Updates view extents based on the current view transform.
   * Offsets the extents considering any open sidebars.
   * Allows additional margin for user panning within limits.
   * Zoom scale is limited to a practical range for usability.
   * @param {?Object} transform Current transform override
   */
  updateViewExtents(transform) {
    const { k: scale } = transform || getViewTransform(this.view);

    const {
      sidebarWidth = 0,
      metaSidebarWidth = 0,
      codeSidebarWidth = 0,
      width: chartWidth = 0,
      height: chartHeight = 0,
    } = this.props.chartSize;

    const { width: graphWidth = 0, height: graphHeight = 0 } =
      this.props.graphSize;

    const leftSidebarOffset = sidebarWidth / scale;
    const rightSidebarOffset = (metaSidebarWidth + codeSidebarWidth) / scale;
    const margin = this.MARGIN;

    // Find the relative minimum scale to fit whole graph
    const minScale = Math.min(
      chartWidth / (graphWidth || 1),
      chartHeight / (graphHeight || 1)
    );

    setViewExtents(this.view, {
      translate: {
        minX: -leftSidebarOffset - margin,
        maxX: graphWidth + margin + rightSidebarOffset,
        minY: -margin,
        maxY: graphHeight + margin,
      },
      scale: {
        minK: this.MIN_SCALE * minScale,
        maxK: this.MAX_SCALE,
      },
    });
  }

  /**
   * Applies the given zoom state as necessary
   * @param {Object} chartZoom The new zoom state
   */
  onChartZoomChanged(chartZoom) {
    // No change if already applied (e.g. was an internal update)
    if (chartZoom.applied) {
      return;
    }

    // Apply reset if it was requested
    if (chartZoom.reset === true) {
      this.resetView(true);
      return;
    }

    // Set the view while respecting extents
    setViewTransform(
      this.view,
      { x: chartZoom.x, y: chartZoom.y, k: chartZoom.scale },
      chartZoom.transition ? this.DURATION * 0.3 : 0,
      chartZoom.relative
    );
  }

  /**
   * Zoom and scale to fit graph and any selected node in view
   */
  resetView(preventZoom) {
    const { chartSize, graphSize, clickedNode, nodes } = this.props;
    const { width: chartWidth, height: chartHeight } = chartSize;
    const { width: graphWidth, height: graphHeight } = graphSize;

    // Skip if chart or graph is not ready yet
    if (!chartWidth || !graphWidth) {
      return;
    }

    // Sidebar offset
    const offset = { x: chartSize.sidebarWidth, y: 0 };

    // Use the selected node as focus point
    const focus = clickedNode
      ? nodes.find((node) => node.id === clickedNode)
      : null;

    // Find a transform that fits everything in view
    const transform = viewTransformToFit({
      offset,
      focus,
      viewWidth: chartWidth,
      viewHeight: chartHeight,
      objectWidth: graphWidth,
      objectHeight: graphHeight,
      minScaleX: 0.2,
      minScaleFocus: this.props.chartZoom.scale,
      focusOffset: 0,
      preventZoom,
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
   * Returns parameter count when there are more
   * than one parameters and parameter name if there's a single parameter
   * @param {Array} parameterNames
   * @returns {String}
   */
  getHoveredParameterLabel = (parameterNames) =>
    parameterNames.length > 1
      ? `Parameters:${parameterNames.length}`
      : parameterNames[0];

  /**
   * Enable a node's focus state and highlight linked nodes
   * @param {Object} event Event object
   * @param {Object} node Datum for a single node
   */
  handleNodeClick = (event, node) => {
    if (node.type === 'modularPipeline') {
      this.props.onClickToExpandModularPipeline(node.id);
    } else {
      this.props.onLoadNodeData(node.id);
      this.props.toSelectedNode(node);
    }
    event.stopPropagation();
  };

  /**
   * Remove a node's focus state and dim linked nodes
   */
  handleChartClick = () => {
    if (this.props.clickedNode) {
      this.props.onLoadNodeData(null);
      // To reset URL to current active pipeline when click outside of a node on flowchart
      this.props.toSelectedPipeline();
    }
  };

  /**
   * Enable a node's active state, show tooltip, and highlight linked nodes
   * @param {Object} event Event object
   * @param {Object} node Datum for a single node
   */
  handleNodeMouseOver = (event, node) => {
    this.props.onToggleNodeHovered(node.id);
    node && this.showTooltip(event, node.fullName);
  };

  /**
   * Enable a layer's active state when hovering it, update labelName's active className accordingly
   * @param {Object} event Event object
   * @param {Object} node Datum for a single node
   */
  handleLayerMouseOver = (event, node) => {
    if (node) {
      this.setState({
        activeLayer: node.name,
      });
    }

    const { activeLayer } = this.state;
    const layerName = document.querySelector(
      `[data-id="layer-label--${node.name}"]`
    );

    if (activeLayer && layerName) {
      layerName.classList.add('pipeline-layer-name--active');
    }
  };

  /**
   * Remove the current labelName's active className when not hovering, and update layer's active state accordingly
   * @param {Object} event Event object
   * @param {Object} node Datum for a single node
   */
  handleLayerMouseOut = (event, node) => {
    const { activeLayer } = this.state;
    const layerName = document.querySelector(
      `[data-id="layer-label--${node.name}"]`
    );

    if (activeLayer && layerName) {
      layerName.classList.remove('pipeline-layer-name--active');
    }

    if (node) {
      this.setState({
        activeLayer: undefined,
      });
    }
  };

  /**
   * Shows tooltip when the parameter indicator is hovered on
   * @param {Object} event Event object
   * @param {Object} node Datum for a single node
   */
  handleParamsIndicatorMouseOver = (event, node) => {
    const parameterNames = this.props.nodesWithInputParams[node.id];
    if (parameterNames) {
      const label = this.getHoveredParameterLabel(parameterNames);

      this.showTooltip(event, label);
    }
    event.stopPropagation();
  };

  /**
   * Remove a node's active state, hide tooltip, and dim linked nodes
   * @param {Object} node Datum for a single node
   */
  handleNodeMouseOut = () => {
    this.props.onToggleNodeHovered(null);
    this.hideTooltip();
  };

  /**
   * Handle keydown event when a node is focused
   * @param {Object} event Event object
   * @param {Object} node Datum for a single node
   */
  handleNodeKeyDown = (event, node) => {
    const ENTER = 13;
    const ESCAPE = 27;
    if (event.keyCode === ENTER) {
      this.handleNodeClick(event, node);
    }
    if (event.keyCode === ESCAPE) {
      this.handleChartClick();
      this.handleNodeMouseOut();
    }
  };

  /**
   * Show, fill and and position the tooltip
   * @param {Object} event Event object
   * @param {Object} text Text to show on the tooltip
   * @param {?Object} options Options for the tooltip if required
   */
  showTooltip(event, text, options = {}) {
    this.setState({
      tooltip: {
        targetRect: event && event.target.getBoundingClientRect(),
        text: text,
        visible: true,
        ...options,
      },
    });
  }

  /**
   * Hide the tooltip
   */
  hideTooltip() {
    if (this.state.tooltip.visible) {
      this.setState({
        tooltip: {
          ...this.state.tooltip,
          visible: false,
        },
      });
    }
  }

  /**
   * Render React elements
   */
  render() {
    const { chartSize, layers, visibleGraph, displayGlobalToolbar } =
      this.props;
    const { outerWidth = 0, outerHeight = 0 } = chartSize;

    return (
      <div
        className="pipeline-flowchart kedro"
        ref={this.containerRef}
        onClick={this.handleChartClick}
      >
        <svg
          id="pipeline-graph"
          className="pipeline-flowchart__graph"
          width={outerWidth}
          height={outerHeight}
          ref={this.svgRef}
        >
          <g
            id="zoom-wrapper"
            className={classnames('pipeline-zoom-wrapper', {
              'pipeline-zoom-wrapper--hidden': !visibleGraph,
            })}
            ref={this.wrapperRef}
          >
            <defs>
              {[
                'arrowhead',
                'arrowhead--input',
                'arrowhead--accent--input',
                'arrowhead--accent',
              ].map((id) => (
                <marker
                  id={`pipeline-${id}`}
                  key={id}
                  className={`pipeline-flowchart__${id}`}
                  viewBox="0 0 10 10"
                  refX="7"
                  refY="5"
                  markerUnits="strokeWidth"
                  markerWidth="8"
                  markerHeight="6"
                  orient="auto"
                >
                  <path d="M 0 0 L 10 5 L 0 10 L 4 5 z" />
                </marker>
              ))}
            </defs>
            <g className="pipeline-flowchart__layers" ref={this.layersRef} />
            <g className="pipeline-flowchart__edges" ref={this.edgesRef} />
            <g
              id="nodes"
              className="pipeline-flowchart__nodes"
              ref={this.nodesRef}
            />
          </g>
        </svg>
        <ul
          className={classnames('pipeline-flowchart__layer-names', {
            'pipeline-flowchart__layer-names--visible': layers.length,
            'pipeline-flowchart__layer-names--no-global-toolbar':
              !displayGlobalToolbar,
          })}
          ref={this.layerNamesRef}
        />
        <Tooltip chartSize={chartSize} {...this.state.tooltip} />
      </div>
    );
  }
}

// Fixed chart size used in tests
export const chartSizeTestFallback = {
  left: 0,
  top: 0,
  right: 1280,
  bottom: 1024,
  width: 1280,
  height: 1024,
};

// Maintain a single reference to support change detection
const emptyEdges = [];
const emptyNodes = [];
const emptyGraphSize = {};

export const mapStateToProps = (state, ownProps) => ({
  clickedNode: state.node.clicked,
  chartSize: getChartSize(state),
  chartZoom: getChartZoom(state),
  displayGlobalToolbar: state.display.globalToolbar,
  edges: state.graph.edges || emptyEdges,
  focusMode: state.visible.modularPipelineFocusMode,
  graphSize: state.graph.size || emptyGraphSize,
  hoveredParameters: state.hoveredParameters,
  hoveredFocusMode: state.hoveredFocusMode,
  layers: getLayers(state),
  linkedNodes: getLinkedNodes(state),
  nodes: state.graph.nodes || emptyNodes,
  nodeTypeDisabled: state.nodeType.disabled,
  nodeActive: getNodeActive(state),
  nodeSelected: getNodeSelected(state),
  nodesWithInputParams: getNodesWithInputParams(state),
  inputOutputDataNodes: getInputOutputNodesForFocusedModularPipeline(state),
  inputOutputDataEdges: getInputOutputDataEdges(state),
  visibleGraph: state.visible.graph,
  visibleSidebar: state.visible.sidebar,
  visibleCode: state.visible.code,
  visibleMetaSidebar: getVisibleMetaSidebar(state),
  ...ownProps,
});

export const mapDispatchToProps = (dispatch, ownProps) => ({
  onClickToExpandModularPipeline: (modularPipelineId) => {
    dispatch(toggleSingleModularPipelineExpanded(modularPipelineId));
  },
  onLoadNodeData: (nodeClicked) => {
    dispatch(loadNodeData(nodeClicked));
  },
  onToggleNodeHovered: (nodeHovered) => {
    dispatch(toggleNodeHovered(nodeHovered));
  },
  onUpdateChartSize: (chartSize) => {
    dispatch(updateChartSize(chartSize));
  },
  onUpdateZoom: (transform) => {
    dispatch(updateZoom(transform));
  },
  ...ownProps,
});

export default connect(mapStateToProps, mapDispatchToProps)(FlowChart);

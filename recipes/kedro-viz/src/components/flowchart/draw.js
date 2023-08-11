import 'd3-transition';
import { interpolatePath } from 'd3-interpolate-path';
import { select } from 'd3-selection';
import { curveBasis, line } from 'd3-shape';
import { paths as nodeIcons } from '../icons/node-icon';

const lineShape = line()
  .x((d) => d.x)
  .y((d) => d.y)
  .curve(curveBasis);

/**
 * Matches all floating point numbers in a string
 */
const matchFloats = /\d+\.\d+/g;

/**
 * Limits the precision of a float value to one decimal point
 */
const toSinglePoint = (value) => parseFloat(value).toFixed(1);

/**
 * Limits the precision of a path string to one decimal point
 */
const limitPrecision = (path) => path.replace(matchFloats, toSinglePoint);

/**
 * Render layer bands
 */
export const drawLayers = function () {
  const { layers } = this.props;

  this.el.layers = this.el.layerGroup
    .selectAll('.pipeline-layer')
    .data(layers, (layer) => layer.id);

  const enterLayers = this.el.layers
    .enter()
    .append('rect')
    .attr('class', 'pipeline-layer')
    .on('mouseover', this.handleLayerMouseOver)
    .on('mouseout', this.handleLayerMouseOut);

  this.el.layers.exit().remove();

  this.el.layers = this.el.layers.merge(enterLayers);

  this.el.layers
    .attr('x', (d) => d.x)
    .attr('y', (d) => d.y)
    .attr('height', (d) => d.height)
    .attr('width', (d) => d.width);
};

/**
 * Render layer name labels
 */
export const drawLayerNames = function () {
  const {
    chartSize: { sidebarWidth = 0 },
    layers,
  } = this.props;

  this.el.layerNameGroup
    .transition('layer-names-sidebar-width')
    .duration(this.DURATION)
    .style('transform', `translateX(${sidebarWidth}px)`);

  this.el.layerNames = this.el.layerNameGroup
    .selectAll('.pipeline-layer-name')
    .data(layers, (layer) => layer.id);

  const enterLayerNames = this.el.layerNames
    .enter()
    .append('li')
    .attr('class', 'pipeline-layer-name')
    .attr('data-id', (node) => `layer-label--${node.name}`);

  enterLayerNames
    .style('opacity', 0)
    .transition('enter-layer-names')
    .duration(this.DURATION)
    .style('opacity', 0.55);

  this.el.layerNames
    .exit()
    .style('opacity', 0.55)
    .transition('exit-layer-names')
    .duration(this.DURATION)
    .style('opacity', 0)
    .remove();

  this.el.layerNames = this.el.layerNames.merge(enterLayerNames);

  this.el.layerNames.text((d) => d.name).attr('dy', 5);
};

/**
 * Sets the size and position of the given node rects
 */
const updateNodeRects = (nodeRects) =>
  nodeRects
    .attr('width', (node) => node.width - 5)
    .attr('height', (node) => node.height - 5)
    .attr('x', (node) => (node.width - 5) / -2)
    .attr('y', (node) => (node.height - 5) / -2)
    .attr('rx', (node) => {
      // Task and Pipeline nodes are rectangle so radius on x-axis is 0
      if (node.type === 'task' || node.type === 'modularPipeline') {
        return 0;
      }
      return node.height / 2;
    });

const updateParameterRect = (nodeRects) =>
  nodeRects
    .attr('width', 12)
    .attr('height', 12)
    .attr('x', (node) => (node.width + 20) / -2)
    .attr('y', -6);

/**
 * Render node icons and name labels
 */
export const drawNodes = function (changed) {
  const {
    clickedNode,
    linkedNodes,
    nodeTypeDisabled,
    nodeActive,
    nodeSelected,
    hoveredParameters,
    nodesWithInputParams,
    inputOutputDataNodes,
    nodes,
    focusMode,
    hoveredFocusMode,
  } = this.props;

  const isInputOutputNode = (nodeID) =>
    focusMode !== null && inputOutputDataNodes[nodeID];

  if (changed('nodes')) {
    this.el.nodes = this.el.nodeGroup
      .selectAll('.pipeline-node')
      .data(nodes, (node) => node.id);
  }

  if (!this.el.nodes) {
    return;
  }

  const updateNodes = this.el.nodes;
  const enterNodes = this.el.nodes.enter().append('g');
  const exitNodes = this.el.nodes.exit();
  // Filter out undefined nodes on Safari
  const allNodes = this.el.nodes
    .merge(enterNodes)
    .merge(exitNodes)
    .filter((node) => typeof node !== 'undefined');

  if (changed('nodes')) {
    enterNodes
      .attr('tabindex', '0')
      .attr('class', 'pipeline-node')
      .attr('transform', (node) => `translate(${node.x}, ${node.y})`)
      .attr('data-id', (node) => node.id)
      .classed(
        'pipeline-node--parameters',
        (node) => node.type === 'parameters'
      )
      .classed('pipeline-node--data', (node) => node.type === 'data')
      .classed('pipeline-node--task', (node) => node.type === 'task')
      .on('click', this.handleNodeClick)
      .on('mouseover', this.handleNodeMouseOver)
      .on('mouseout', this.handleNodeMouseOut)
      .on('focus', this.handleNodeMouseOver)
      .on('blur', this.handleNodeMouseOut)
      .on('keydown', this.handleNodeKeyDown);

    enterNodes
      .attr('opacity', 0)
      .transition('show-nodes')
      .duration(this.DURATION)
      .attr('opacity', 1);

    enterNodes
      .append('rect')
      .attr(
        'class',
        (node) => `pipeline-node__bg pipeline-node__bg--${node.type}`
      );

    enterNodes
      .append('rect')
      .attr('class', 'pipeline-node__parameter-indicator')
      .on('mouseover', this.handleParamsIndicatorMouseOver)
      .call(updateParameterRect);

    // Performance: use a single path per icon
    enterNodes
      .append('path')
      .attr('class', 'pipeline-node__icon')
      .attr('d', (node) => nodeIcons[node.icon]);

    enterNodes
      .append('text')
      .attr('class', 'pipeline-node__text')
      .text((node) => node.name)
      .attr('text-anchor', 'middle')
      .attr('dy', 5)
      .attr('dx', (node) => node.textOffset);

    exitNodes
      .transition('exit-nodes')
      .duration(this.DURATION)
      .style('opacity', 0)
      .remove();

    // Cancel exit transitions if re-entered
    updateNodes.transition('exit-nodes').style('opacity', null);

    this.el.nodes = this.el.nodeGroup.selectAll('.pipeline-node');
  }

  if (
    changed(
      'nodes',
      'nodeTypeDisabled',
      'nodeActive',
      'nodeSelected',
      'hoveredParameters',
      'nodesWithInputParams',
      'clickedNode',
      'linkedNodes',
      'focusMode',
      'inputOutputDataNodes'
    )
  ) {
    allNodes
      .classed('pipeline-node--active', (node) => nodeActive[node.id])
      .classed('pipeline-node--selected', (node) => nodeSelected[node.id])
      .classed(
        'pipeline-node--collapsed-hint',
        (node) =>
          hoveredParameters &&
          nodesWithInputParams[node.id] &&
          nodeTypeDisabled.parameters
      )
      .classed(
        'pipeline-node--dataset-input',
        (node) => isInputOutputNode(node.id) && node.type === 'data'
      )
      .classed(
        'pipeline-node--parameter-input',
        (node) => isInputOutputNode(node.id) && node.type === 'parameters'
      )
      .classed(
        'pipeline-node-input--active',
        (node) => isInputOutputNode(node.id) && nodeActive[node.id]
      )
      .classed(
        'pipeline-node-input--selected',
        (node) => isInputOutputNode(node.id) && nodeSelected[node.id]
      )
      .classed(
        'pipeline-node--faded',
        (node) => clickedNode && !linkedNodes[node.id]
      );
  }

  if (changed('hoveredFocusMode')) {
    allNodes.classed(
      'pipeline-node--faded',
      (node) => hoveredFocusMode && !nodeActive[node.id]
    );
  }

  if (changed('nodes')) {
    allNodes
      .transition('update-nodes')
      .duration(this.DURATION)
      .attr('transform', (node) => `translate(${node.x}, ${node.y})`)
      .on('end', () => {
        try {
          // Sort nodes so tab focus order follows X/Y position
          allNodes.sort((a, b) => a.order - b.order);
        } catch (err) {
          // Avoid rare DOM errors thrown due to timing issues
        }
      });

    enterNodes.select('.pipeline-node__bg').call(updateNodeRects);

    updateNodes
      .select('.pipeline-node__bg')
      .transition('node-rect')
      .duration((node) => (node.showText ? 200 : 600))
      .call(updateNodeRects);
    allNodes
      .select('.pipeline-node__parameter-indicator')
      .classed(
        'pipeline-node__parameter-indicator--visible',
        (node) => nodeTypeDisabled.parameters && nodesWithInputParams[node.id]
      )
      .transition('node-rect')
      .duration((node) => (node.showText ? 200 : 600))
      .call(updateParameterRect);

    // Performance: icon transitions with CSS on GPU
    allNodes
      .select('.pipeline-node__icon')
      .style('transition-delay', (node) => (node.showText ? '0ms' : '200ms'))
      .style(
        'transform',
        (node) =>
          `translate(${node.iconOffset}px, ${-node.iconSize / 2}px) ` +
          `scale(${node.iconSize / 24})`
      );

    // Performance: text transitions with CSS on GPU
    allNodes
      .select('.pipeline-node__text')
      .text((node) => node.name)
      .style('transition-delay', (node) => (node.showText ? '200ms' : '0ms'))
      .style('opacity', (node) => (node.showText ? 1 : 0));
  }
};

/**
 * Render edge lines
 */
export const drawEdges = function (changed) {
  const { edges, clickedNode, linkedNodes, focusMode, inputOutputDataEdges } =
    this.props;

  const isInputOutputEdge = (edgeID) =>
    focusMode !== null && inputOutputDataEdges[edgeID];

  if (changed('edges')) {
    this.el.edges = this.el.edgeGroup
      .selectAll('.pipeline-edge')
      .data(edges, (edge) => edge.id);
  }

  if (!this.el.edges) {
    return;
  }

  const updateEdges = this.el.edges;
  const enterEdges = this.el.edges.enter().append('g');
  const exitEdges = this.el.edges.exit();
  const allEdges = this.el.edges.merge(enterEdges).merge(exitEdges);

  if (changed('edges', 'focusMode', 'inputOutputDataNodes')) {
    enterEdges.append('path');
    allEdges
      .select('path')
      .attr('marker-end', (edge) =>
        edge.sourceNode.type === 'parameters'
          ? isInputOutputEdge(edge.id)
            ? `url(#pipeline-arrowhead--accent--input)`
            : `url(#pipeline-arrowhead--accent)`
          : isInputOutputEdge(edge.id)
          ? `url(#pipeline-arrowhead--input)`
          : `url(#pipeline-arrowhead)`
      );

    enterEdges
      .attr('data-id', (edge) => edge.id)
      .attr('class', 'pipeline-edge');

    enterEdges
      .attr('opacity', 0)
      .transition('show-edges')
      .duration(this.DURATION)
      .attr('opacity', 1);

    exitEdges
      .transition('exit-edges')
      .duration(this.DURATION)
      .style('opacity', 0)
      .remove();

    // Cancel exit transitions if re-entered
    updateEdges.transition('exit-edges').style('opacity', null);

    allEdges
      .select('path')
      .transition('update-edges')
      .duration(this.DURATION)
      .attrTween('d', function (edge) {
        // Performance: Limit path precision for parsing & render
        let current = edge.points && limitPrecision(lineShape(edge.points));
        const previous = select(this).attr('d') || current;
        return interpolatePath(previous, current);
      });

    this.el.edges = this.el.edgeGroup.selectAll('.pipeline-edge');
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
    allEdges
      .classed(
        'pipeline-edge--parameters',
        (edge) =>
          edge.sourceNode.type === 'parameters' && !isInputOutputEdge(edge.id)
      )
      .classed(
        'pipeline-edge--parameters-input',
        (edge) =>
          edge.sourceNode.type === 'parameters' && isInputOutputEdge(edge.id)
      )
      .classed('pipeline-edge--dataset--input', (edge) =>
        isInputOutputEdge(edge.id)
      )
      .classed(
        'pipeline-edge--faded',
        (edge) =>
          edge &&
          clickedNode &&
          (!linkedNodes[edge.source] || !linkedNodes[edge.target])
      );
  }
};

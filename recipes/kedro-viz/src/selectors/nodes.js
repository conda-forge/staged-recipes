import { createSelector } from 'reselect';
import { select } from 'd3-selection';
import { arrayToObject } from '../utils';
import { getPipelineNodeIDs } from './pipeline';
import {
  getNodeDisabled,
  getNodeDisabledTag,
  getVisibleNodeIDs,
} from './disabled';
import getShortType from '../utils/short-type';
import { getNodeRank } from './ranks';

export const getNodeName = (state) => state.node.name;
export const getNodeFullName = (state) => state.node.fullName;
const getNodeDisabledNode = (state) => state.node.disabled;
const getModularPipelineDisabled = (state) => state.modularPipeline.disabled;
const getNodeTags = (state) => state.node.tags;
export const getNodeModularPipelines = (state) => state.node.modularPipelines;
const getNodeType = (state) => state.node.type;
const getNodeDatasetType = (state) => state.node.datasetType;
const getNodeLayer = (state) => state.node.layer;
const getHoveredNode = (state) => state.node.hovered;
const getIsPrettyName = (state) => state.isPrettyName;
const getTagActive = (state) => state.tag.active;
const getModularPipelineActive = (state) => state.modularPipeline.active;
const getTextLabels = (state) => state.textLabels;
const getNodeTypeDisabled = (state) => state.nodeType.disabled;
const getClickedNode = (state) => state.node.clicked;
const getEdgeIDs = (state) => state.edge.ids;
const getEdgeSources = (state) => state.edge.sources;
const getEdgeTargets = (state) => state.edge.targets;

/**
 * Gets a map of nodeIds to graph nodes
 */
export const getGraphNodes = createSelector(
  [(state) => state.graph.nodes],
  (nodes = []) =>
    nodes.reduce((result, node) => {
      result[node.id] = node;
      return result;
    }, {})
);

/**
 * Set active status if the node is specifically highlighted, and/or via an associated tag or modular pipeline
 */
export const getNodeActive = createSelector(
  [
    getPipelineNodeIDs,
    getHoveredNode,
    getNodeTags,
    getTagActive,
    getNodeModularPipelines,
    getModularPipelineActive,
    (state) => state.modularPipeline.tree,
  ],
  (
    nodeIDs,
    hoveredNode,
    nodeTags,
    tagActive,
    nodeModularPipelines,
    modularPipelineActive,
    modularPipelinesTree
  ) => {
    const activeModularPipelines = Object.keys(modularPipelineActive).filter(
      (modularPipelineID) => modularPipelineActive[modularPipelineID]
    );
    const nodesActiveViaModularPipeline = activeModularPipelines.flatMap((id) =>
      modularPipelinesTree[id].children.map((child) => child.id)
    );

    return arrayToObject(nodeIDs, (nodeID) => {
      if (nodeID === hoveredNode) {
        return true;
      }
      const activeViaTag = nodeTags[nodeID].some((tag) => tagActive[tag]);
      const activeModularPipeline = activeModularPipelines.includes(nodeID);
      const activeViaModularPipeline =
        nodesActiveViaModularPipeline.includes(nodeID) ||
        (nodeModularPipelines[nodeID] &&
          nodeModularPipelines[nodeID].some(
            (modularPipeline) => modularPipelineActive[modularPipeline]
          ));
      return (
        Boolean(activeViaTag) ||
        Boolean(activeViaModularPipeline) ||
        Boolean(activeModularPipeline)
      );
    });
  }
);

/**
 * Set selected status if the node is clicked
 */
export const getNodeSelected = createSelector(
  [getPipelineNodeIDs, getClickedNode, getNodeDisabled],
  (nodeIDs, clickedNode, nodeDisabled) =>
    arrayToObject(
      nodeIDs,
      (nodeID) => nodeID === clickedNode && !nodeDisabled[nodeID]
    )
);

/**
 * Returns node label based on if pretty name is turned on/off
 */
export const getNodeLabel = createSelector(
  [getIsPrettyName, getNodeName, getNodeFullName],
  (isPrettyName, nodeName, nodeFullName) =>
    isPrettyName ? nodeName : nodeFullName
);

/**
 * Returns formatted nodes as an array, with all relevant properties
 */
export const getNodeData = createSelector(
  [
    getPipelineNodeIDs,
    getNodeLabel,
    getNodeType,
    getNodeDatasetType,
    getNodeDisabled,
    getModularPipelineDisabled,
    getNodeDisabledNode,
    getNodeDisabledTag,
    getNodeTypeDisabled,
    getNodeModularPipelines,
  ],
  (
    nodeIDs,
    nodeLabel,
    nodeType,
    nodeDatasetType,
    nodeDisabled,
    modularPipelineDisabled,
    nodeDisabledNode,
    nodeDisabledTag,
    typeDisabled,
    nodeModularPipelines
  ) =>
    nodeIDs
      .sort((a, b) => {
        if (nodeLabel[a] < nodeLabel[b]) {
          return -1;
        }
        if (nodeLabel[a] > nodeLabel[b]) {
          return 1;
        }
        return 0;
      })
      .map((id) => ({
        id,
        name: nodeLabel[id],
        type: nodeType[id],
        icon: getShortType(nodeDatasetType[id], nodeType[id]),
        modularPipelines: nodeModularPipelines[id],
        disabled: nodeDisabled[id],
        disabledModularPipeline: Boolean(modularPipelineDisabled[id]),
        disabledNode: Boolean(nodeDisabledNode[id]),
        disabledTag: nodeDisabledTag[id],
        disabledType: Boolean(typeDisabled[nodeType[id]]),
      }))
);

/**
 * Returns formatted nodes as an object, with all relevant properties.
 * This is similar to `getNodeData`, but instead of returning an Array,
 * it returns all nodes as an Object.
 */
export const getNodeDataObject = createSelector(
  [
    getPipelineNodeIDs,
    getNodeLabel,
    getNodeType,
    getNodeDatasetType,
    getNodeDisabled,
    getModularPipelineDisabled,
    getNodeDisabledNode,
    getNodeDisabledTag,
    getNodeTypeDisabled,
    getNodeModularPipelines,
  ],
  (
    nodeIDs,
    nodeLabel,
    nodeType,
    nodeDatasetType,
    nodeDisabled,
    modularPipelineDisabled,
    nodeDisabledNode,
    nodeDisabledTag,
    typeDisabled,
    nodeModularPipelines
  ) =>
    nodeIDs.reduce((obj, id) => {
      obj[id] = {
        id,
        name: nodeLabel[id],
        type: nodeType[id],
        icon: getShortType(nodeDatasetType[id], nodeType[id]),
        modularPipelines: nodeModularPipelines[id],
        disabled: nodeDisabled[id],
        disabledModularPipeline: Boolean(modularPipelineDisabled[id]),
        disabledNode: Boolean(nodeDisabledNode[id]),
        disabledTag: Boolean(nodeDisabledTag[id]),
        disabledType: Boolean(typeDisabled[nodeType[id]]),
      };
      return obj;
    }, {})
);

/**
 * Return the modular pipelines tree with full data for each tree node for display.
 */
export const getModularPipelinesTree = createSelector(
  [(state) => state.modularPipeline.tree, getNodeDataObject],
  (modularPipelinesTree, nodes) => {
    if (!modularPipelinesTree) {
      return {};
    }
    for (const modularPipelineID in modularPipelinesTree) {
      modularPipelinesTree[modularPipelineID].data = {
        ...nodes[modularPipelineID],
      };
      for (const child of modularPipelinesTree[modularPipelineID].children) {
        child.data = { ...nodes[child.id] };
      }
    }
    return modularPipelinesTree;
  }
);

/**
 * Returns formatted nodes grouped by type
 */
export const getGroupedNodes = createSelector([getNodeData], (nodes) =>
  nodes.reduce(function (obj, item) {
    const key = item.type;
    if (!obj.hasOwnProperty(key)) {
      obj[key] = [];
    }
    obj[key].push(item);
    return obj;
  }, {})
);

/**
 * Temporarily create a new SVG container in the DOM, write a node to it,
 * measure its width with getBBox, then delete the container and store the value
 */
export const getNodeTextWidth = createSelector(
  [getPipelineNodeIDs, getNodeLabel],
  (nodeIDs, nodeLabel) => {
    const nodeTextWidth = {};
    const svg = select(document.body)
      .append('svg')
      .attr('class', 'kedro pipeline-node');
    svg
      .selectAll('text')
      .data(nodeIDs)
      .enter()
      .append('text')
      .text((nodeID) => nodeLabel[nodeID])
      .each(function (nodeID) {
        const width = this.getBBox ? this.getBBox().width : 0;
        nodeTextWidth[nodeID] = width;
      });
    svg.remove();
    return nodeTextWidth;
  }
);

/**
 * Get the top/bottom and left/right padding for a node
 * @param {Boolean} showLabels Whether labels are visible
 * @param {Boolean} isTask Whether the node is a task type (vs data/params)
 */
export const getPadding = (showLabels, nodeType) => {
  if (showLabels) {
    switch (nodeType) {
      case 'modularPipeline':
        return { x: 30, y: 22 };
      case 'task':
        return { x: 16, y: 10 };
      default:
        return { x: 20, y: 10 };
    }
  }
  switch (nodeType) {
    case 'modularPipeline':
      return { x: 25, y: 25 };
    case 'task':
      return { x: 14, y: 14 };
    default:
      return { x: 16, y: 16 };
  }
};

/**
 * Calculate node width/height and icon/text positioning
 */
export const getNodeSize = createSelector(
  [getPipelineNodeIDs, getNodeTextWidth, getTextLabels, getNodeType],
  (nodeIDs, nodeTextWidth, textLabels, nodeType) => {
    return arrayToObject(nodeIDs, (nodeID) => {
      const iconSize = textLabels ? 24 : 28;
      const padding = getPadding(textLabels, nodeType[nodeID]);
      const textWidth = textLabels ? nodeTextWidth[nodeID] : 0;
      const textGap = textLabels ? 6 : 0;
      const innerWidth = iconSize + textWidth + textGap;
      return {
        showText: textLabels,
        width: innerWidth + padding.x * 2,
        height: iconSize + padding.y * 2,
        textOffset: (innerWidth - textWidth) / 2 - 1,
        iconOffset: -innerWidth / 2,
        iconSize,
      };
    });
  }
);

/**
 * Returns only visible nodes as an array, but without any extra properties
 * that are unnecessary for the chart layout calculation
 */
export const getVisibleNodes = createSelector(
  [
    getVisibleNodeIDs,
    getNodeLabel,
    getNodeType,
    getNodeDatasetType,
    getNodeFullName,
    getNodeSize,
    getNodeLayer,
    getNodeRank,
  ],
  (
    nodeIDs,
    nodeLabel,
    nodeType,
    nodeDatasetType,
    nodeFullName,
    nodeSize,
    nodeLayer,
    nodeRank
  ) =>
    nodeIDs.map((id) => ({
      id,
      name: nodeLabel[id],
      fullName: nodeFullName[id],
      icon: getShortType(nodeDatasetType[id], nodeType[id]),
      type: nodeType[id],
      layer: nodeLayer[id],
      rank: nodeRank[id],
      ...nodeSize[id],
    }))
);

/**
 * Returns a map of task nodeIDs to graph nodes that have parameter nodes as their source
 */

export const getNodesWithInputParams = createSelector(
  [
    getGraphNodes,
    getNodeName,
    getEdgeIDs,
    getNodeType,
    getEdgeSources,
    getEdgeTargets,
  ],
  (nodes, nodeName, edgeIDs, nodeType, edgeSources, edgeTargets) => {
    const nodesList = {};
    for (const edgeID of edgeIDs) {
      const source = edgeSources[edgeID];
      const target = edgeTargets[edgeID];
      if (nodeType[source] === 'parameters' && nodeType[target] === 'task') {
        if (!nodesList[target]) {
          nodesList[target] = [];
        }
        nodesList[target].push(nodeName[source]);
      }
    }
    return nodesList;
  }
);

/**
 * Returns a list of dataset nodes that are input and output nodes of the modular pipeline under focus mode
 */
export const getInputOutputNodesForFocusedModularPipeline = createSelector(
  [
    (state) => state.visible.modularPipelineFocusMode?.id,
    getGraphNodes,
    getModularPipelinesTree,
  ],
  (focusedModularPipelineID, graphNodes, modularPipelinesTree) => {
    const focusedModularPipeline = focusedModularPipelineID
      ? modularPipelinesTree[focusedModularPipelineID]
      : null;
    const nodeIDs = focusedModularPipeline
      ? [...focusedModularPipeline.inputs, ...focusedModularPipeline.outputs]
      : [];
    const result = nodeIDs.reduce((result, nodeID) => {
      result[nodeID] = graphNodes[nodeID];
      return result;
    }, {});
    return result;
  }
);

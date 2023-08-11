import { createSelector } from 'reselect';
import batchingToposort from 'batching-toposort';
import { getVisibleNodeIDs, getVisibleLayerIDs } from './disabled';
import { getVisibleEdges } from './edges';

const getNodeLayer = (state) => state.node.layer;

/**
 * Get list of visible nodes for each visible layer
 */
export const getLayerNodes = createSelector(
  [getVisibleNodeIDs, getVisibleLayerIDs, getNodeLayer],
  (nodeIDs, layerIDs, nodeLayer) => {
    if (!layerIDs.length) {
      return [];
    }
    // Create object containing a list of every node for each layer
    const layerNodes = {};
    for (const nodeID of nodeIDs) {
      const layer = nodeLayer[nodeID];
      if (!layerNodes[layer]) {
        layerNodes[layer] = [];
      }
      layerNodes[layer].push(nodeID);
    }

    // Convert to a nested array of layers of nodes
    return layerIDs.map((layerID) => layerNodes[layerID]);
  }
);

/**
 * Calculate ranks (vertical placement) for each node,
 * by toposorting while taking layers into account
 */
export const getNodeRank = createSelector(
  [getVisibleNodeIDs, getVisibleEdges, getLayerNodes, getVisibleLayerIDs],
  (nodeIDs, edges, layerNodes, layerIDs) => {
    if (!layerIDs.length) {
      return {};
    }

    // For each node, create a list of nodes that depend on that node
    const nodeDeps = {};

    // Initialise empty dependency arrays for each node
    for (const nodeID of nodeIDs) {
      nodeDeps[nodeID] = [];
    }

    // Add dependencies for visible edges
    for (const edge of edges) {
      nodeDeps[edge.source].push(edge.target);
    }

    // Add "false edge" dependencies for layered nodes to prevent layer overlaps
    for (let i = 1; i < layerNodes.length; i++) {
      for (const sourceID of layerNodes[i - 1]) {
        for (const targetID of layerNodes[i]) {
          nodeDeps[sourceID].push(targetID);
        }
      }
    }

    // Run toposort algorithm to rank nodes by dependency
    const toposortedNodes = batchingToposort(nodeDeps);

    // Convert toposort order into rank numbering
    const nodeRanks = {};
    for (let rank = 0; rank < toposortedNodes.length; rank++) {
      for (const nodeID of toposortedNodes[rank]) {
        nodeRanks[nodeID] = rank;
      }
    }

    return nodeRanks;
  }
);

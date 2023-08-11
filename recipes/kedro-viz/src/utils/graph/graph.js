/*
 * The Kedro-Viz Graph Layout Engine
 *
 * Refer to LAYOUT_ENGINE.md for description of the approach.
 */

import { offsetNode, offsetEdge } from './common';
import { layout } from './layout';
import { routing } from './routing';

const defaultOptions = {
  layout: {
    spaceX: 14,
    spaceY: 110,
    layerSpaceY: 55,
    spreadX: 2.2,
    padding: 100,
    iterations: 25,
  },
  routing: {
    spaceX: 26,
    spaceY: 28,
    minPassageGap: 40,
    stemUnit: 8,
    stemMinSource: 5,
    stemMinTarget: 5,
    stemMax: 20,
    stemSpaceSource: 6,
    stemSpaceTarget: 10,
  },
};

/**
 * Generates a diagram of the given DAG.
 * Input nodes and edges are updated in-place.
 * Results are stored as `x, y` properties on nodes
 * and `points` properties on edges.
 * @param {Array} nodes The input nodes
 * @param {Array} edges The input edges
 * @param {Object=} layers The node layers if specified
 * @param {Object=} options The graph options
 * @returns {Object} The generated graph
 */
export const graph = (nodes, edges, layers, options = defaultOptions) => {
  addEdgeLinks(nodes, edges);
  addNearestLayers(nodes, layers);

  layout({ nodes, edges, layers, ...options.layout });
  routing({ nodes, edges, layers, ...options.routing });

  const size = bounds(nodes, options.layout.padding);
  nodes.forEach((node) => offsetNode(node, size.min));
  edges.forEach((edge) => offsetEdge(edge, size.min));

  return {
    nodes,
    edges,
    layers,
    size,
  };
};

/**
 * Adds lists of source edges and target edges to each node in-place
 * @param {Array} nodes The input nodes
 * @param {Array} edges The input edges
 */
export const addEdgeLinks = (nodes, edges) => {
  const nodeById = {};

  for (const node of nodes) {
    nodeById[node.id] = node;
    node.targets = [];
    node.sources = [];
  }

  for (const edge of edges) {
    edge.sourceNode = nodeById[edge.source];
    edge.targetNode = nodeById[edge.target];
    edge.sourceNode.targets.push(edge);
    edge.targetNode.sources.push(edge);
  }
};

/**
 * Adds the nearest valid layer to each node whilst maintaining the correct layer order
 * @param {Array} nodes The input nodes
 * @param {?Array} layers The input layers
 */
const addNearestLayers = (nodes, layers) => {
  if (layers && layers.length > 0) {
    // Create the set of valid layers for lookup
    const validLayers = {};
    for (const layer of layers) {
      validLayers[layer] = true;
    }

    const hasValidLayer = (node) => Boolean(node && node.layer in validLayers);
    const lastLayer = layers[layers.length - 1];

    // For each node
    for (const node of nodes) {
      // Find first descendant node that has a valid layer following rank order (including itself)
      const layerNode = findNodeBy(
        // Starting node
        node,
        // Next connected nodes to search
        targetNodes,
        // Lowest rank first
        orderRankAscending,
        // Acceptance criteria
        hasValidLayer
      );

      // Assign the nearest layer if found otherwise must be the last layer
      node.nearestLayer = layerNode ? layerNode.layer : lastLayer;
    }
  }
};

/**
 * Returns the list of target nodes directly connected to the given node
 * @param {Object} node The input node
 * @returns {Array} The target nodes
 */
const targetNodes = (node) => node.targets.map((edge) => edge.targetNode);

/**
 * Comparator function for sorting nodes rank ascending
 * @param {Object} nodeA The first input node
 * @param {Object} nodeB The second input node
 * @returns {Number} The signed difference
 */
const orderRankAscending = (nodeA, nodeB) => nodeA.rank - nodeB.rank;

/**
 * Starting at the given node and expanding successors, returns the first node accepted in order
 * @param {Object} node The starting node
 * @param {Function} successors A function returning the next nodes to expand
 * @param {Function} order A comparator function used for prioritising successors
 * @param {Function} accept A function that returns true if the current node fits the criteria
 * @param {Object=} visited An object keeping track of nodes already searched
 * @returns {?Object} The first node accepted in order, or undefined if none
 */
const findNodeBy = (node, successors, order, accept, visited) => {
  // If the current node is accepted then return it without further search
  if (accept(node)) {
    return node;
  }

  // Keep track of visited nodes
  visited = visited || {};
  visited[node.id] = true;

  const results = successors(node)
    // Remove successors already visited
    .filter((successor) => !visited[successor.id])
    // Order unvisited successors
    .sort(order)
    // Search the unvisited successors recursively
    .map((successor) =>
      findNodeBy(successor, successors, order, accept, visited)
    )
    // Keep only the accepted resulting nodes if any
    .filter(accept)
    // Order resulting nodes
    .sort(order);

  // Return the first node accepted in order, or undefined if none
  return results[0];
};

/**
 * Finds the region bounding the given nodes
 * @param {Array} nodes The input nodes
 * @param {Number} padding Additional padding around the bounds
 * @returns {Object} The bounds
 */
const bounds = (nodes, padding) => {
  const size = {
    min: { x: Infinity, y: Infinity },
    max: { x: -Infinity, y: -Infinity },
  };

  for (const node of nodes) {
    const x = node.x;
    const y = node.y;

    if (x < size.min.x) {
      size.min.x = x;
    }
    if (x > size.max.x) {
      size.max.x = x;
    }
    if (y < size.min.y) {
      size.min.y = y;
    }
    if (y > size.max.y) {
      size.max.y = y;
    }
  }

  size.width = size.max.x - size.min.x + 2 * padding;
  size.height = size.max.y - size.min.y + 2 * padding;
  size.min.x -= padding;
  size.min.y -= padding;

  return size;
};

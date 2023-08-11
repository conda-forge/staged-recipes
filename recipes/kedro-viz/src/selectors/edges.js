import { createSelector } from 'reselect';
import { getNodeDisabled, getEdgeDisabled } from './disabled';
import { getFocusedModularPipeline } from './modular-pipelines';

const getNodeIDs = (state) => state.node.ids;
const getEdgeIDs = (state) => state.edge.ids;
const getEdgeSources = (state) => state.edge.sources;
const getEdgeTargets = (state) => state.edge.targets;
const getNodeModularPipelines = (state) => state.node.modularPipelines;
const getVisibleSidebarNodes = (state) => state.modularPipeline.visible;

/**
 * Create a new transitive edge from the first and last edge in the path
 * @param {String} target Node ID for the new edge
 * @param {String} source Node ID for the new edge
 * @param {Object} transitiveEdges Store of existing edges
 */
export const addNewEdge = (source, target, { edgeIDs, sources, targets }) => {
  const id = [source, target].join('|');
  if (!edgeIDs.includes(id)) {
    edgeIDs.push(id);
    sources[id] = source;
    targets[id] = target;
  }
};

/**
 * Create new edges to connect nodes which have a disabled node (or nodes)
 * in between them
 */
export const getTransitiveEdges = createSelector(
  [
    getNodeIDs,
    getEdgeIDs,
    getNodeDisabled,
    getEdgeSources,
    getEdgeTargets,
    getFocusedModularPipeline,
    getNodeModularPipelines,
    getVisibleSidebarNodes,
  ],
  (
    nodeIDs,
    edgeIDs,
    nodeDisabled,
    edgeSources,
    edgeTargets,
    focusedModularPipeline,
    nodeModularPipelines,
    visibleModularPipelines
  ) => {
    const transitiveEdges = {
      edgeIDs: [],
      sources: {},
      targets: {},
    };

    /**
     * Recursively walk through the graph, stepping over disabled nodes,
     * generating a list of nodes visited so far, and create transitive edges
     * for each path that visits disabled nodes between enabled nodes.
     * @param {Array} path The route that has been explored so far
     */
    const walkGraphEdges = (path) => {
      edgeIDs.forEach((edgeID) => {
        const source = path[path.length - 1];
        // Filter to only edges where the source node is the previous target
        if (edgeSources[edgeID] !== source) {
          return;
        }
        const target = edgeTargets[edgeID];

        if (!visibleModularPipelines[target]) {
          return;
        }

        // Further filter out connections between indicative input / output nodes under focus mode
        const isNotInputEdge =
          focusedModularPipeline !== null &&
          !nodeModularPipelines[source].includes(focusedModularPipeline.id) &&
          !nodeModularPipelines[target].includes(focusedModularPipeline.id);

        if (nodeDisabled[target]) {
          // If target node is disabled then keep walking the graph
          walkGraphEdges(path.concat(target));
        } else if (path.length > 1 && !isNotInputEdge) {
          // Else only create a new edge if there would be 3 or more nodes in the path
          addNewEdge(path[0], target, transitiveEdges);
        }
      });
    };

    // Only run walk if some nodes are disabled
    if (nodeIDs.some((nodeID) => nodeDisabled[nodeID])) {
      // Examine the children of every enabled node. The walk only needs
      // to be run in a single direction (i.e. top down), because links
      // that end in a terminus can never be transitive.
      nodeIDs.forEach((nodeID) => {
        if (!nodeDisabled[nodeID]) {
          walkGraphEdges([nodeID]);
        }
      });
    }

    return transitiveEdges;
  }
);

/**
 * Get only the visible edges (plus transitive edges),
 * and return them formatted as an array of objects
 */
export const getVisibleEdges = createSelector(
  [
    getEdgeIDs,
    getEdgeDisabled,
    getEdgeSources,
    getEdgeTargets,
    getTransitiveEdges,
  ],
  (edgeIDs, edgeDisabled, edgeSources, edgeTargets, transitiveEdges) =>
    edgeIDs
      .filter((id) => !edgeDisabled[id])
      .concat(transitiveEdges.edgeIDs)
      .map((id) => ({
        id,
        source: edgeSources[id] || transitiveEdges.sources[id],
        target: edgeTargets[id] || transitiveEdges.targets[id],
      }))
);

/**
 * Obtain all the edges that belongs to input and output data
 * nodes when under focus mode.
 */
export const getInputOutputDataEdges = createSelector(
  [getVisibleEdges, getNodeModularPipelines, getFocusedModularPipeline],
  (visibleEdges, nodeModularPipelines, focusedModularPipeline) => {
    const edgesList = {};
    if (focusedModularPipeline !== null) {
      visibleEdges.forEach((edge) => {
        if (
          !nodeModularPipelines[edge.source]?.includes(
            focusedModularPipeline.id
          ) ||
          !nodeModularPipelines[edge.target]?.includes(
            focusedModularPipeline.id
          )
        ) {
          edgesList[edge.id] = edge;
        }
      });
    }

    return edgesList;
  }
);

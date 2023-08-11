import { createSelector } from 'reselect';
import { getNodeDisabled } from './disabled';
import { arrayToObject } from '../utils';

const getNodeIDs = (state) => state.node.ids;
const getNodeType = (state) => state.node.type;
export const getNodeTypeIDs = (state) => state.nodeType.ids;
const getNodeTypeName = (state) => state.nodeType.name;
const getNodeTypeDisabled = (state) => state.nodeType.disabled;
export const isModularPipelineType = (type) => type === 'modularPipeline';

/**
 * Calculate the total number of nodes (and the number of visible nodes)
 * for each node-type
 */
export const getTypeNodeCount = createSelector(
  [getNodeTypeIDs, getNodeIDs, getNodeType, getNodeDisabled],
  (types, nodeIDs, nodeType, nodeDisabled) =>
    arrayToObject(types, (type) => {
      const typeNodeIDs = nodeIDs.filter((nodeID) => nodeType[nodeID] === type);
      const visibleTypeNodeIDs = typeNodeIDs.filter(
        (nodeID) => !nodeDisabled[nodeID]
      );
      return {
        total: typeNodeIDs.length,
        visible: visibleTypeNodeIDs.length,
      };
    })
);

/**
 * Get formatted list of node type objects
 */
export const getNodeTypes = createSelector(
  [getNodeTypeIDs, getNodeTypeName, getNodeTypeDisabled, getTypeNodeCount],
  (types, typeName, typeDisabled, typeNodeCount) =>
    types.map((id) => ({
      id,
      name: typeName[id],
      disabled: typeDisabled[id],
      nodeCount: typeNodeCount[id],
    }))
);

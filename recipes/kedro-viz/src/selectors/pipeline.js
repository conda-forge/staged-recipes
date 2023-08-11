import { createSelector } from 'reselect';
import { arrayToObject } from '../utils';

const getNodeIDs = (state) => state.node.ids;
const getNodePipelines = (state) => state.node.pipelines;
const getActivePipeline = (state) => state.pipeline.active;
const getNodeTags = (state) => state.node.tags;
const getNodeModularPipelines = (state) => state.node.modularPipelines;
const getDataSource = (state) => state.dataSource;
const getModularPipelineIDs = (state) => state.modularPipeline.ids;

/**
 * Calculate whether nodes should be disabled based on their registered pipelines
 */
export const getNodeDisabledPipeline = createSelector(
  [getNodeIDs, getNodePipelines, getActivePipeline, getDataSource],
  (nodeIDs, nodePipelines, activePipeline, dataSource) => {
    if (dataSource === 'json' || !activePipeline) {
      return {};
    }
    return arrayToObject(
      nodeIDs,
      (nodeID) => !nodePipelines[nodeID][activePipeline]
    );
  }
);

/**
 * Get a list of just the IDs for the active pipeline
 */
export const getPipelineNodeIDs = createSelector(
  [getNodeIDs, getNodeDisabledPipeline],
  (nodeIDs, nodeDisabledPipeline) =>
    nodeIDs.filter((nodeID) => !nodeDisabledPipeline[nodeID])
);

/**
 * Get IDs of tags used in the current pipeline
 */
export const getPipelineTagIDs = createSelector(
  [getPipelineNodeIDs, getNodeTags],
  (nodeIDs, nodeTags) => {
    const visibleTags = {};
    nodeIDs.forEach((nodeID) => {
      nodeTags[nodeID].forEach((tagID) => {
        if (!visibleTags[tagID]) {
          visibleTags[tagID] = true;
        }
      });
    });
    return Object.keys(visibleTags);
  }
);

/**
 * Get IDs of modular pipelines used in the current pipeline
 */
export const getPipelineModularPipelineIDs = createSelector(
  [getPipelineNodeIDs, getNodeModularPipelines, getModularPipelineIDs],
  (nodeIDs, nodeModularPipelines, modularPipelineIDs) => {
    const visibleModularPipelines = {};
    // check if pipeline contains defined modular pipelines
    if (modularPipelineIDs.length > 0) {
      nodeIDs.forEach((nodeID) => {
        nodeModularPipelines[nodeID].forEach((modularPipelineID) => {
          if (
            modularPipelineID &&
            !visibleModularPipelines[modularPipelineID]
          ) {
            visibleModularPipelines[modularPipelineID] = true;
          }
        });
      });
    }
    return Object.keys(visibleModularPipelines);
  }
);

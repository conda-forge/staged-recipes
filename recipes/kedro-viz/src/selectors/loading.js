import { createSelector } from 'reselect';

const getGraphLoading = (state) => state.loading.graph;
const getPipelineLoading = (state) => state.loading.pipeline;
const getNodeLoading = (state) => state.loading.node;

export const getDisplayLargeGraph = (state) => state.ignoreLargeWarning;

/**
 * Determine whether to show the loading spinner
 */
export const isLoading = createSelector(
  [getGraphLoading, getPipelineLoading, getNodeLoading],
  (graphLoading, pipelineLoading, nodeLoading) => {
    return graphLoading || pipelineLoading || nodeLoading;
  }
);

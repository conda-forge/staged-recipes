import { getUrl } from '../utils';
import loadJsonData from '../store/load-data';
import { preparePipelineState } from '../store/initial-state';
import { resetData } from './index';

/**
 * This file contains actions that update the active pipeline, and if loading data
 * asynchronously, they also handle loading this pipeline data from different endpoints.
 *
 * Many different cases need to be addressed, including:
 * 1. Loading data synchronously, or asynchonously.
 * 2. Loading data and updating the pipeline on first page load, or on user actions.
 * 3. Whether the dataset has pipelines defined in it, or not.
 * 4. Whether localStorage has an active pipeline already defined.
 * 5. If so, whether it exists in the current dataset.
 * 6. Whether the requested endpoint is the 'main' one, or not.
 *
 * These are mostly handled either within this file, in the preparePipelineState
 * utility, or in the getNodeDisabledPipeline selector. Please see their tests
 * for more info about implementation requirements.
 */

export const UPDATE_ACTIVE_PIPELINE = 'UPDATE_ACTIVE_PIPELINE';

/**
 * Update the actively-selected pipeline
 * @param {String} pipeline Pipeline ID
 */
export function updateActivePipeline(pipeline) {
  return {
    type: UPDATE_ACTIVE_PIPELINE,
    pipeline,
  };
}

export const TOGGLE_PIPELINE_LOADING = 'TOGGLE_PIPELINE_LOADING';

/**
 * Toggle whether to display the loading spinner
 * @param {Boolean} loading True if pipeline is still loading
 */
export function toggleLoading(loading) {
  return {
    type: TOGGLE_PIPELINE_LOADING,
    loading,
  };
}

/**
 * Determine where to load data from
 * @param {Object} pipeline Pipeline state
 */
export const getPipelineUrl = (pipeline) => {
  if (pipeline.active === pipeline.main) {
    return getUrl('main');
  }
  return getUrl('pipeline', pipeline.active);
};

/**
 * Check whether another async data pipeline request is needed on first page-load.
 * A second request is typically only required when an active pipeline is set in
 * localStorage, and it's not the 'main' pipeline endpoint.
 * @param {Object} pipeline Pipeline state
 * @return {Boolean} True if another request is needed
 */
export const requiresSecondRequest = (pipeline) => {
  // Pipelines are not present in the data
  if (!pipeline.ids.length || !pipeline.main) {
    return false;
  }

  // There is no active pipeline set
  if (!pipeline.active) {
    return false;
  }

  // The active pipeline is not 'main'
  return pipeline.active !== pipeline.main;
};

/**
 * Load pipeline data on initial page-load
 * @return {Function} A promise that resolves when the data is loaded
 */
export function loadInitialPipelineData() {
  return async function (dispatch, getState) {
    // Get a copy of the full state from the store
    const state = getState();
    // If data is passed synchronously then this process isn't necessary
    if (state.dataSource !== 'json') {
      return;
    }
    dispatch(toggleLoading(true));
    // Load 'main' data file. This is always loaded first, because it's needed
    // in order to obtain the list of pipelines, which is required for determining
    // whether the active pipeline (from localStorage) exists in the data.
    const url = getUrl('main');
    // obtain the status of expandAllPipelines to decide whether it needs to overwrite the
    // list of visible nodes
    const expandAllPipelines =
      state.display.expandAllPipelines || state.flags.expandAllPipelines;
    let newState = await loadJsonData(url).then((data) =>
      preparePipelineState(data, true, expandAllPipelines)
    );
    // If the active pipeline isn't 'main' then request data from new URL
    if (requiresSecondRequest(newState.pipeline)) {
      const url = getPipelineUrl(newState.pipeline);
      newState = await loadJsonData(url).then((data) =>
        preparePipelineState(data, false, expandAllPipelines)
      );
    }
    dispatch(resetData(newState));
    dispatch(toggleLoading(false));
  };
}

/**
 * Change pipeline on selection, loading new data if necessary
 * @param {String} pipelineID Unique ID for new pipeline
 * @return {Function} A promise that resolves when the data is loaded
 */
export function loadPipelineData(pipelineID) {
  return async function (dispatch, getState) {
    const { dataSource, pipeline, display, flags } = getState();

    if (pipelineID && pipelineID === pipeline.active) {
      return;
    }

    if (dataSource === 'json') {
      dispatch(toggleLoading(true));

      const url = getPipelineUrl({
        main: pipeline.main,
        active: pipelineID,
      });

      const expandAllPipelines =
        display.expandAllPipelines || flags.expandAllPipelines;
      const newState = await loadJsonData(url).then((data) =>
        preparePipelineState(data, false, expandAllPipelines)
      );

      // Set active pipeline here rather than dispatching two separate actions,
      // to improve performance by only requiring one state recalculation
      newState.pipeline.active = pipelineID;
      dispatch(resetData(newState));
      dispatch(toggleLoading(false));
    } else {
      dispatch(updateActivePipeline(pipelineID));
    }
  };
}

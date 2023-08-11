import { UPDATE_ACTIVE_PIPELINE } from '../actions/pipelines';

function pipelineReducer(pipelineState = {}, action) {
  switch (action.type) {
    case UPDATE_ACTIVE_PIPELINE: {
      return Object.assign({}, pipelineState, {
        active: action.pipeline,
      });
    }

    default:
      return pipelineState;
  }
}

export default pipelineReducer;

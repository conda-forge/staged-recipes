import { UPDATE_GRAPH_LAYOUT } from '../actions/graph';

function nodeReducer(graphState = {}, action) {
  const updateState = (newState) => Object.assign({}, graphState, newState);

  switch (action.type) {
    case UPDATE_GRAPH_LAYOUT: {
      return updateState(action.graph);
    }

    default:
      return graphState;
  }
}

export default nodeReducer;

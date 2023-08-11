import { TOGGLE_LAYERS } from '../actions';

function layerReducer(layerState = {}, action) {
  switch (action.type) {
    case TOGGLE_LAYERS: {
      return Object.assign({}, layerState, {
        visible: action.visible,
      });
    }

    default:
      return layerState;
  }
}

export default layerReducer;

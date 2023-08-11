import { CHANGE_FLAG } from '../actions';

function flagsReducer(flagsState = {}, action) {
  switch (action.type) {
    case CHANGE_FLAG: {
      return Object.assign({}, flagsState, {
        [action.name]: action.value,
      });
    }

    default:
      return flagsState;
  }
}

export default flagsReducer;

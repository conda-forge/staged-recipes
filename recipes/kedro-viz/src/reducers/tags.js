import { TOGGLE_TAG_ACTIVE, TOGGLE_TAG_FILTER } from '../actions/tags';

function tagReducer(tagState = {}, action) {
  const updateState = (newState) => Object.assign({}, tagState, newState);

  /**
   * Batch update tags from an array of tag IDs
   * @param {String} key Tag action value prop
   */
  const batchChanges = (key) =>
    action.tagIDs.reduce((result, tagID) => {
      result[tagID] = action[key];
      return result;
    }, {});

  switch (action.type) {
    case TOGGLE_TAG_ACTIVE: {
      return updateState({
        active: Object.assign({}, tagState.active, batchChanges('active')),
      });
    }

    case TOGGLE_TAG_FILTER: {
      return updateState({
        enabled: Object.assign({}, tagState.enabled, batchChanges('enabled')),
      });
    }

    default:
      return tagState;
  }
}

export default tagReducer;

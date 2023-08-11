import {
  TOGGLE_TYPE_DISABLED,
  NODE_TYPE_DISABLED_UNSET,
} from '../actions/node-type';

/**
 * See actions/node-type.js for details on the 'unset' value.
 */
const allNodeTypesUnset = {
  parameters: NODE_TYPE_DISABLED_UNSET,
  task: NODE_TYPE_DISABLED_UNSET,
  data: NODE_TYPE_DISABLED_UNSET,
};

const isNodeTypeUnset = (nodeTypeValue) =>
  nodeTypeValue === NODE_TYPE_DISABLED_UNSET;

const isNodeTypeDisabled = (nodeTypeValue) => nodeTypeValue === true;

function nodeTypeReducer(nodeTypeState = {}, action) {
  switch (action.type) {
    case TOGGLE_TYPE_DISABLED: {
      const nextDisabledState = {
        ...nodeTypeState.disabled,
        ...action.typeIDs,
      };

      const nextTypesDisabled = Object.values(nextDisabledState);

      // If no types will be enabled
      if (nextTypesDisabled.every(isNodeTypeDisabled)) {
        // Then reset all types to unset (defaulting to enabled)
        return {
          ...nodeTypeState,
          disabled: { ...allNodeTypesUnset },
        };
      }

      // At least one type is enabled, set any unset types to disabled
      for (const type in nextDisabledState) {
        if (isNodeTypeUnset(nextDisabledState[type])) {
          nextDisabledState[type] = true;
        }
      }

      return {
        ...nodeTypeState,
        disabled: nextDisabledState,
      };
    }
    default:
      return nodeTypeState;
  }
}

export default nodeTypeReducer;

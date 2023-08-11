import {
  TOGGLE_NODE_CLICKED,
  TOGGLE_NODES_DISABLED,
  TOGGLE_NODE_HOVERED,
  ADD_NODE_METADATA,
} from '../actions/nodes';
import { UPDATE_ACTIVE_PIPELINE } from '../actions/pipelines';

function nodeReducer(nodeState = {}, action) {
  const updateState = (newState) => Object.assign({}, nodeState, newState);

  switch (action.type) {
    case TOGGLE_NODE_CLICKED: {
      return updateState({
        clicked: action.nodeClicked,
      });
    }

    case TOGGLE_NODES_DISABLED: {
      return updateState({
        clicked: action.nodeIDs.includes(nodeState.clicked)
          ? null
          : nodeState.clicked,
        disabled: action.nodeIDs.reduce(
          (disabled, id) =>
            Object.assign({}, disabled, {
              [id]: action.isDisabled,
            }),
          nodeState.disabled
        ),
      });
    }

    case TOGGLE_NODE_HOVERED: {
      return updateState({
        hovered: action.nodeHovered,
      });
    }

    case UPDATE_ACTIVE_PIPELINE: {
      return updateState({
        clicked: null,
        hovered: null,
      });
    }

    case ADD_NODE_METADATA: {
      const { id, data } = action.data;
      return updateState({
        fetched: Object.assign({}, nodeState.fetched, {
          [id]: true,
        }),
        code: Object.assign({}, nodeState.code, {
          [id]: data.code,
        }),
        filepath: Object.assign({}, nodeState.filepath, {
          [id]: data.filepath,
        }),
        parameters: Object.assign({}, nodeState.parameters, {
          [id]: data.parameters,
        }),
        inputs: Object.assign({}, nodeState.inputs, {
          [id]: data.inputs,
        }),
        outputs: Object.assign({}, nodeState.outputs, {
          [id]: data.outputs,
        }),
        // the data returned from the API under the field name 'type' for dataset type nodes
        datasetType: Object.assign({}, nodeState.datasetType, {
          [id]: data.type,
        }),
        originalType: Object.assign({}, nodeState.originalType, {
          [id]: data.original_type,
        }),
        transcodedTypes: Object.assign({}, nodeState.transcodedTypes, {
          [id]: data.transcoded_types,
        }),
        plot: Object.assign({}, nodeState.plot, {
          [id]: data.plot,
        }),
        image: Object.assign({}, nodeState.image, {
          [id]: data.image,
        }),
        trackingData: Object.assign({}, nodeState.trackingData, {
          [id]: data.tracking_data,
        }),
        runCommand: Object.assign({}, nodeState.runCommand, {
          [id]: data.run_command,
        }),
        preview: Object.assign({}, nodeState.preview, {
          [id]: data.preview,
        }),
      });
    }

    default:
      return nodeState;
  }
}

export default nodeReducer;

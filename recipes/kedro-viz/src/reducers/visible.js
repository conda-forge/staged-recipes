import {
  TOGGLE_GRAPH,
  TOGGLE_EXPORT_MODAL,
  TOGGLE_SETTINGS_MODAL,
  TOGGLE_METADATA_MODAL,
  TOGGLE_SIDEBAR,
  TOGGLE_CODE,
  TOGGLE_MINIMAP,
  TOGGLE_MODULAR_PIPELINE_FOCUS_MODE,
} from '../actions';

function visibleReducer(visibleState = {}, action) {
  switch (action.type) {
    case TOGGLE_GRAPH: {
      return Object.assign({}, visibleState, {
        graph: action.visible,
      });
    }

    case TOGGLE_METADATA_MODAL: {
      return Object.assign({}, visibleState, {
        metadataModal: action.visible,
      });
    }

    case TOGGLE_EXPORT_MODAL: {
      return Object.assign({}, visibleState, {
        exportModal: action.visible,
      });
    }

    case TOGGLE_SETTINGS_MODAL: {
      return Object.assign({}, visibleState, {
        settingsModal: action.visible,
      });
    }

    case TOGGLE_SIDEBAR: {
      return Object.assign({}, visibleState, {
        sidebar: action.visible,
      });
    }

    case TOGGLE_MINIMAP: {
      return Object.assign({}, visibleState, {
        miniMap: action.visible,
      });
    }

    case TOGGLE_CODE: {
      return Object.assign({}, visibleState, {
        code: action.visible,
      });
    }

    case TOGGLE_MODULAR_PIPELINE_FOCUS_MODE: {
      return Object.assign({}, visibleState, {
        modularPipelineFocusMode: action.modularPipeline,
      });
    }

    default:
      return visibleState;
  }
}

export default visibleReducer;

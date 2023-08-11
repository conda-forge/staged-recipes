import { combineReducers } from 'redux';
import flags from './flags';
import graph from './graph';
import layer from './layers';
import loading from './loading';
import node from './nodes';
import nodeType from './node-type';
import pipeline from './pipeline';
import tag from './tags';
import modularPipeline from './modular-pipelines';
import visible from './visible';
import {
  RESET_DATA,
  TOGGLE_TEXT_LABELS,
  TOGGLE_THEME,
  UPDATE_CHART_SIZE,
  UPDATE_ZOOM,
  TOGGLE_IGNORE_LARGE_WARNING,
  TOGGLE_IS_PRETTY_NAME,
  TOGGLE_HOVERED_FOCUS_MODE,
} from '../actions';
import { TOGGLE_PARAMETERS_HOVERED } from '../actions';

/**
 * Create a generic reducer
 * @param {*} initialState Default state
 * @param {String} type Action type
 * @param {String} key Action payload key
 * @return {*} Updated state
 */
const createReducer =
  (initialState, type, key) =>
  (state = initialState, action) => {
    if (typeof key !== 'undefined' && action.type === type) {
      return action[key];
    }
    return state;
  };

/**
 * Reset/update application-wide data
 * @param {Object} state Complete app state
 * @param {Object} action Redux action
 * @return {Object} Updated(?) state
 */
function resetDataReducer(state = {}, action) {
  if (action.type === RESET_DATA) {
    return Object.assign({}, state, action.data);
  }
  return state;
}

const combinedReducer = combineReducers({
  // These props have their own reducers in other files
  flags,
  graph,
  layer,
  loading,
  node,
  nodeType,
  pipeline,
  tag,
  modularPipeline,
  visible,
  // These props don't have any actions associated with them
  display: createReducer(null),
  dataSource: createReducer(null),
  edge: createReducer({}),
  // These props have very simple non-nested actions
  chartSize: createReducer({}, UPDATE_CHART_SIZE, 'chartSize'),
  zoom: createReducer({}, UPDATE_ZOOM, 'zoom'),
  textLabels: createReducer(true, TOGGLE_TEXT_LABELS, 'textLabels'),
  theme: createReducer('dark', TOGGLE_THEME, 'theme'),
  isPrettyName: createReducer(true, TOGGLE_IS_PRETTY_NAME, 'isPrettyName'),
  hoveredParameters: createReducer(
    false,
    TOGGLE_PARAMETERS_HOVERED,
    'hoveredParameters'
  ),
  ignoreLargeWarning: createReducer(
    false,
    TOGGLE_IGNORE_LARGE_WARNING,
    'ignoreLargeWarning'
  ),
  hoveredFocusMode: createReducer(
    false,
    TOGGLE_HOVERED_FOCUS_MODE,
    'hoveredFocusMode'
  ),
});

const rootReducer = (state, action) =>
  combinedReducer(resetDataReducer(state, action), action);

export default rootReducer;

import { createStore, compose, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import watch from 'redux-watch';
import reducer from '../reducers';
import { getGraphInput } from '../selectors/layout';
import { calculateGraph } from '../actions/graph';
import { saveLocalStorage, pruneFalseyKeys } from './helpers';
import { localStorageName } from '../config';

/**
 * Watch the getGraphInput selector, and dispatch an asynchronous action to
 * update state.graph via a web worker when it changes.
 * @param {Object} store Redux store
 */
export const updateGraphOnChange = (store) => {
  const watchGraph = watch(() => getGraphInput(store.getState()));
  store.subscribe(
    watchGraph((graphInput) => {
      store.dispatch(calculateGraph(graphInput));
    })
  );
};

/**
 * Save selected state properties to window.localStorage
 * @param {Object} state Redux state snapshot
 */
const saveStateToLocalStorage = (state) => {
  // does not save modal state to localStorage
  const {
    exportModal,
    metadataModal,
    settingsModal,
    modularPipelineFocusMode,
    ...otherVisibleProps
  } = state.visible;
  saveLocalStorage(localStorageName, {
    node: {
      disabled: pruneFalseyKeys(state.node.disabled),
    },
    nodeType: {
      disabled: state.nodeType.disabled,
    },
    pipeline: {
      active: state.pipeline.active,
    },
    layer: {
      visible: state.layer.visible,
    },
    tag: {
      enabled: state.tag.enabled,
    },
    textLabels: state.textLabels,
    visible: otherVisibleProps,
    theme: state.theme,
    isPrettyName: state.isPrettyName,
    flags: state.flags,
  });
};

/**
 * Configure initial state and create the Redux store
 * @param {Object} initialState Initial Redux state (from initial-state.js)
 * @param {Object} dataType type of pipeline data - "static" or "json" (if data is loaded from API)
 * @return {Object} Redux store
 */
export default function configureStore(initialState, dataType) {
  const composeEnhancers =
    window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
  const store = createStore(
    reducer,
    initialState,
    composeEnhancers(applyMiddleware(thunk))
  );

  // dispatch the calculateGraph action to ensure the graph nodes still gets rendered
  // on initial load if data is loaded via data prop instead of fetching from Rest API
  if (dataType !== 'json') {
    store.dispatch(calculateGraph(getGraphInput(store.getState())));
  }

  updateGraphOnChange(store);
  store.subscribe(() => {
    saveStateToLocalStorage(store.getState());
  });

  return store;
}

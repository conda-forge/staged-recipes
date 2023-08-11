import React from 'react';
import { Provider } from 'react-redux';
import { mount, shallow } from 'enzyme';
import configureStore from '../store';
import getInitialState from '../store/initial-state';
import spaceflights from './data/spaceflights.mock.json';
import demo from './data/demo.mock.json';
import reducer from '../reducers';
import { getGraphInput } from '../selectors/layout';
import { updateGraph } from '../actions/graph';
import { graphNew } from './graph';

/**
 * Prime the state object for the testing environment
 * by running the asynchronous actions synchronously.
 * Optionally apply additional actions before or after layout.
 * @param {Object} props
 * @param {?Function[]} props.beforeLayoutActions Functions that given state return actions to reduce before layout
 * @param {?Function[]} props.afterLayoutActions Functions that given state return actions to reduce after layout
 */
export const prepareState = ({
  beforeLayoutActions = [],
  afterLayoutActions = [],
  ...props
}) => {
  const initialState = getInitialState(props);
  const actions = [
    // Per-test provided actions before layout:
    ...beforeLayoutActions,
    // Precalculate graph layout:
    (state) => {
      const layout = graphNew;
      const graphState = getGraphInput(state);
      if (!graphState) {
        return state;
      }
      const graph = layout(graphState);
      return updateGraph(graph);
    },
    // Per-test provided actions after layout:
    ...afterLayoutActions,
  ];
  return actions.reduce(
    (state, action) => reducer(state, action(state)),
    initialState
  );
};

/**
 * Example state objects for use in tests of redux-enabled components
 */
export const mockState = {
  json: prepareState({ data: 'json' }),
  demo: prepareState({ data: demo }),
  spaceflights: prepareState({ data: spaceflights }),
};

/**
 * Set up mounted/shallow Enzyme wrappers
 */
export const setup = {
  /**
   * Mount a React-Redux Provider wrapper for testing connected components.
   * Optionally apply additional actions to prepare initial state before or after layout.
   * @param {Object} children React component(s)
   * @param {Object} props Store initialisation props
   * @param {?Function[]} props.beforeLayoutActions Functions that given state return actions to reduce before layout
   * @param {?Function[]} props.afterLayoutActions Functions that given state return actions to reduce after layout
   */
  mount: (children, props = {}) => {
    const initialState = Object.assign(
      {},
      prepareState({ data: spaceflights, ...props })
    );
    return mount(
      <Provider store={configureStore(initialState, 'json')}>
        {children}
      </Provider>
    );
  },
  /**
   * Render a pure React component in a shallow wrapper
   * @param {Object} Component A React component
   * @param {Object} props React component props
   */
  shallow: (Component, props = {}) => shallow(<Component {...props} />),
};

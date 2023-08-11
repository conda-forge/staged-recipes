import { createStore } from 'redux';
import reducer from '../reducers';
import { mockState } from '../utils/state.mock';
import { changeFlag } from '../actions';
import {
  TOGGLE_NODE_DATA_LOADING,
  toggleNodeDataLoading,
  loadNodeData,
  addNodeMetadata,
  ADD_NODE_METADATA,
} from './nodes';
import nodeParameters from '../utils/data/node_parameters.mock.json';

const parametersID = 'f1f1425b';

jest.mock('../store/load-data.js');

describe('node actions', () => {
  describe('addNodeMetadata', () => {
    it('should create an action to add node metadata', () => {
      const data = { id: 'abc123', data: { parameters: { test: 'test' } } };
      const expectedAction = {
        type: ADD_NODE_METADATA,
        data,
      };
      expect(addNodeMetadata(data)).toEqual(expectedAction);
    });
  });

  describe('toggleLoading', () => {
    it('should create an action to toggle when the node data is loading', () => {
      const loading = true;
      const expectedAction = {
        type: TOGGLE_NODE_DATA_LOADING,
        loading,
      };
      expect(toggleNodeDataLoading(loading)).toEqual(expectedAction);
    });
  });

  describe('loadNodeData', () => {
    beforeEach(() => {
      jest.resetModules();
    });

    describe('if loading data asynchronously', () => {
      it('should set loading to true immediately', () => {
        const initialstate = reducer(mockState.json, changeFlag('meta', true));
        const store = createStore(reducer, initialstate);
        expect(store.getState().loading.node).toBe(false);
        loadNodeData('parametersID')(store.dispatch, store.getState);
        expect(store.getState().loading.node).toBe(true);
      });

      it('should load the new data, reset the state and added the fetched node id under node.fetched', async () => {
        let initialstate = reducer(mockState.json, changeFlag('meta', true));
        const store = createStore(reducer, initialstate);
        const node = { id: parametersID };
        await loadNodeData(node.id)(store.dispatch, store.getState);
        const state = store.getState();
        expect(state.node.fetched[node.id]).toEqual(true);
      });

      it('should dispatch an action with the newly fetched data to update the store', async () => {
        const initialstate = reducer(mockState.json, changeFlag('meta', true));
        const store = createStore(reducer, initialstate);
        const { dispatch, getState } = store;
        const node = { id: parametersID };
        const storeListener = jest.fn();
        const logDispatch = (action) => {
          storeListener(action);
          return dispatch(action);
        };

        await loadNodeData(node.id)(logDispatch, getState);

        expect(storeListener.mock.calls[2][0]).toEqual({
          type: ADD_NODE_METADATA,
          data: { id: node.id, data: nodeParameters },
        });
      });

      it('should set loading to false when complete', async () => {
        const initialstate = reducer(mockState.json, changeFlag('meta', true));
        const store = createStore(reducer, initialstate);
        const node = { id: parametersID };
        await loadNodeData(node.id)(store.dispatch, store.getState);
        expect(store.getState().loading.node).toBe(false);
      });

      it('should do nothing if the Node data is already fetched', async () => {
        const initialstate = reducer(mockState.json, changeFlag('meta', true));
        const store = createStore(reducer, initialstate);
        const { dispatch, getState } = store;
        const node = { id: parametersID };
        const storeListener = jest.fn();
        const logDispatch = (action) => {
          storeListener(action);
          return dispatch(action);
        };

        // The store would have been called 5 times: 4 times for the first round to fetch the node information,
        // one more time for toggleNodeCliced
        await loadNodeData(node.id)(logDispatch, getState);
        await loadNodeData(node.id)(logDispatch, getState);

        expect(storeListener).toHaveBeenCalledTimes(5);

        expect(storeListener.mock.calls[4][0]).toEqual({
          nodeClicked: parametersID,
          type: 'TOGGLE_NODE_CLICKED',
        });
      });

      it('should not make any API calls if there is no nodeID present', async () => {
        const initialstate = reducer(mockState.json, changeFlag('meta', true));
        const store = createStore(reducer, initialstate);
        const { dispatch, getState, subscribe } = store;
        const node = { id: null };
        const storeListener = jest.fn();

        subscribe(storeListener);
        await loadNodeData(node.id)(dispatch, getState);
        // the store should be called only once for 'toggleNodeClicked'
        expect(storeListener).toHaveBeenCalledTimes(1);
      });
    });
  });
});

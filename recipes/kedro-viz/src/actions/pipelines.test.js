import { createStore } from 'redux';
import reducer from '../reducers';
import { mockState } from '../utils/state.mock';
import { saveLocalStorage } from '../store/helpers';
import { localStorageName } from '../config';
import {
  updateActivePipeline,
  UPDATE_ACTIVE_PIPELINE,
  toggleLoading,
  TOGGLE_PIPELINE_LOADING,
  getPipelineUrl,
  requiresSecondRequest,
  loadInitialPipelineData,
  loadPipelineData,
} from './pipelines';

jest.mock('../store/load-data.js');

describe('pipeline actions', () => {
  describe('updateActivePipeline', () => {
    it('should create an action to update the active pipeline', () => {
      const pipeline = 'abc123';
      const expectedAction = {
        type: UPDATE_ACTIVE_PIPELINE,
        pipeline,
      };
      expect(updateActivePipeline(pipeline)).toEqual(expectedAction);
    });
  });

  describe('toggleLoading', () => {
    it('should create an action to toggle whether the pipeline is loading', () => {
      const loading = true;
      const expectedAction = {
        type: TOGGLE_PIPELINE_LOADING,
        loading,
      };
      expect(toggleLoading(loading)).toEqual(expectedAction);
    });
  });

  describe('getPipelineUrl', () => {
    const id = 'abc123';

    it('should return the "main" endpoint URL if active === main', () => {
      const pipeline = { active: id, main: id };
      expect(getPipelineUrl(pipeline)).toEqual(expect.stringContaining('main'));
    });

    it('should return a "pipelines" endpoint URL if active !== main', () => {
      const pipeline = { active: id, main: '__default__' };
      expect(getPipelineUrl(pipeline)).toEqual(
        expect.stringContaining(`pipelines/${id}`)
      );
    });
  });

  describe('requiresSecondRequest', () => {
    it('should return false if pipelines are not present in the data', () => {
      const pipeline = { ids: [], active: 'a' };
      expect(requiresSecondRequest(pipeline)).toBe(false);
    });

    it('should return false if there is no active pipeline', () => {
      const pipeline = { ids: ['a', 'b'], main: 'a' };
      expect(requiresSecondRequest(pipeline)).toBe(false);
    });

    it('should return false if the main pipeline is active', () => {
      const pipeline = { ids: ['a', 'b'], main: 'a', active: 'a' };
      expect(requiresSecondRequest(pipeline)).toBe(false);
    });

    it('should return true if the main pipeline is not active', () => {
      const pipeline = { ids: ['a', 'b'], main: 'a', active: 'b' };
      expect(requiresSecondRequest(pipeline)).toBe(true);
    });
  });

  describe('loadInitialPipelineData', () => {
    beforeEach(() => {
      jest.resetModules();
    });

    afterEach(() => {
      window.localStorage.clear();
      window.deletePipelines = undefined;
    });

    describe('if loading data synchronously', () => {
      it('should return immediately', () => {
        const store = createStore(reducer, mockState.spaceflights);
        loadInitialPipelineData()(store.dispatch, store.getState);
        expect(store.getState().loading.pipeline).toBe(false);
      });
    });

    describe('if loading data asynchronously', () => {
      it('should set loading to true immediately', () => {
        const store = createStore(reducer, mockState.json);
        expect(store.getState().loading.pipeline).toBe(false);
        loadInitialPipelineData()(store.dispatch, store.getState);
        expect(store.getState().loading.pipeline).toBe(true);
      });

      it('should set loading to false when complete', async () => {
        const store = createStore(reducer, mockState.json);
        await loadInitialPipelineData()(store.dispatch, store.getState);
        expect(store.getState().loading.pipeline).toBe(false);
      });

      it("should reset the active pipeline if its ID isn't included in the list of pipeline IDs", async () => {
        saveLocalStorage(localStorageName, {
          pipeline: { active: 'unknown-id' },
        });
        const store = createStore(reducer, mockState.json);
        await loadInitialPipelineData()(store.dispatch, store.getState);
        const state = store.getState();
        expect(state.pipeline.active).toBe(state.pipeline.main);
        expect(state.node).toEqual(mockState.spaceflights.node);
      });

      it('should request data from a different dataset if the active pipeline is set', async () => {
        const { pipeline } = mockState.spaceflights;
        const active = pipeline.ids.find((id) => id !== pipeline.main);
        saveLocalStorage(localStorageName, { pipeline: { active } });
        const store = createStore(reducer, mockState.json);
        await loadInitialPipelineData()(store.dispatch, store.getState);
        expect(store.getState().pipeline.active).toBe(active);
        expect(store.getState().node).toEqual(mockState.demo.node);
      });

      it("shouldn't make a second data request if the active pipeline is unset", async () => {
        const store = createStore(reducer, mockState.json);
        await loadInitialPipelineData()(store.dispatch, store.getState);
        const state = store.getState();
        expect(state.pipeline.active).toBe(state.pipeline.main);
        expect(state.node).toEqual(mockState.spaceflights.node);
      });

      it("shouldn't make a second data request if the dataset doesn't support pipelines", async () => {
        window.deletePipelines = true; // pass option to load-data mock
        const { pipeline } = mockState.spaceflights;
        const active = pipeline.ids.find((id) => id !== pipeline.main);
        saveLocalStorage(localStorageName, { pipeline: { active } });
        const store = createStore(reducer, mockState.json);
        await loadInitialPipelineData()(store.dispatch, store.getState);
        expect(store.getState().node).toEqual(mockState.spaceflights.node);
      });
    });
  });

  describe('loadPipelineData', () => {
    it('should do nothing if the pipelineID is already active', () => {
      const store = createStore(reducer, mockState.spaceflights);
      const { dispatch, getState, subscribe } = store;
      const storeListener = jest.fn();
      subscribe(storeListener);
      loadPipelineData(getState().pipeline.active)(dispatch, getState);
      expect(storeListener).toHaveBeenCalledTimes(0);
    });

    describe('if loading data synchronously', () => {
      it('updates the active pipeline', () => {
        const store = createStore(reducer, mockState.spaceflights);
        const { dispatch, getState, subscribe } = store;
        const storeListener = jest.fn();
        const { pipeline } = getState();
        const newActive = pipeline.ids.find((id) => id !== pipeline.active);
        subscribe(storeListener);
        loadPipelineData(newActive)(dispatch, getState);
        expect(storeListener).toHaveBeenCalledTimes(1);
        expect(getState().pipeline.active).toBe(newActive);
      });
    });

    describe('if loading data asynchronously', () => {
      const active = 'new active id';

      it('should set loading to true immediately', () => {
        const store = createStore(reducer, mockState.json);
        expect(store.getState().loading.pipeline).toBe(false);
        loadPipelineData(active)(store.dispatch, store.getState);
        expect(store.getState().loading.pipeline).toBe(true);
      });

      it('should set loading to false when complete', async () => {
        const store = createStore(reducer, mockState.json);
        await loadPipelineData(active)(store.dispatch, store.getState);
        expect(store.getState().loading.pipeline).toBe(false);
      });

      it('should load the new data, reset the state and update the active pipeline', async () => {
        const store = createStore(reducer, mockState.json);
        await loadPipelineData(active)(store.dispatch, store.getState);
        const state = store.getState();
        expect(state.pipeline.active).toBe(active);
        expect(state.node).toEqual(mockState.demo.node);
      });
    });
  });
});

import { createStore } from 'redux';
import reducer from '../reducers';
import { mockState } from '../utils/state.mock';
import { calculateGraph, updateGraph } from './graph';
import { getGraphInput } from '../selectors/layout';

describe('graph actions', () => {
  describe('calculateGraph', () => {
    it('returns updateGraph action if input is falsey', () => {
      expect(calculateGraph(null)).toEqual(updateGraph(null));
    });

    it('sets loading to true immediately', () => {
      const store = createStore(reducer, mockState.spaceflights);
      expect(store.getState().loading.graph).not.toBe(true);
      calculateGraph(getGraphInput(mockState.spaceflights))(store.dispatch);
      expect(store.getState().loading.graph).toBe(true);
    });

    it('sets loading to false and graph visibility to true after finishing calculation', () => {
      const store = createStore(reducer, mockState.spaceflights);
      return calculateGraph(getGraphInput(mockState.spaceflights))(
        store.dispatch
      ).then(() => {
        const state = store.getState();
        expect(state.loading.graph).toBe(false);
        expect(state.visible.graph).toBe(true);
      });
    });

    it('calculates a graph', () => {
      const state = Object.assign({}, mockState.spaceflights);
      delete state.graph;
      const store = createStore(reducer, state);
      expect(store.getState().graph).toEqual({});
      return calculateGraph(getGraphInput(state))(store.dispatch).then(() => {
        expect(store.getState().graph).toEqual(
          expect.objectContaining({
            nodes: expect.any(Array),
            edges: expect.any(Array),
            size: expect.any(Object),
          })
        );
      });
    });
  });
});

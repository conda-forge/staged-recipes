import { prepareState } from '../utils/state.mock';
import {
  getChartSize,
  getSidebarWidth,
  getGraphInput,
  getTriggerLargeGraphWarning,
} from './layout';
import { changeFlag, toggleIgnoreLargeWarning } from '../actions';
import { updateGraph } from '../actions/graph';
import { toggleTypeDisabled } from '../actions/node-type';
import reducer from '../reducers';
import { graphNew } from '../utils/graph';
import { sidebarWidth, largeGraphThreshold } from '../config';
import spaceflights from '../utils/data/spaceflights.mock.json';
import { getVisibleNodeIDs } from './disabled';
import { toggleModularPipelinesExpanded } from '../actions/modular-pipelines';

describe('Selectors', () => {
  const mockState = prepareState({
    data: spaceflights,
    beforeLayoutActions: [
      () => toggleModularPipelinesExpanded(['data_science', 'data_processing']),
    ],
  });
  describe('getTriggerLargeGraphWarning', () => {
    // Prepare excessively-large dataset
    const prepareLargeDataset = () => {
      const data = { ...spaceflights };
      let extraNodes = [];
      const visibleNodeCount = getVisibleNodeIDs(mockState).length;
      const iterations = Math.ceil(largeGraphThreshold / visibleNodeCount) + 1;
      new Array(iterations).fill().forEach((d, i) => {
        const extraNodeGroup = data.nodes.map((node) => ({
          ...node,
          id: node.id + i,
          //eslint-disable-next-line camelcase
          modular_pipelines: [],
        }));
        extraNodes = extraNodes.concat(extraNodeGroup);
      });
      data.nodes = data.nodes.concat(extraNodes);
      data.modular_pipelines['__root__'].children.push(
        ...extraNodes.map((node) => ({
          id: node.id,
          type: node.type,
        }))
      );
      return data;
    };

    it('returns false for a small dataset', () => {
      expect(getTriggerLargeGraphWarning(mockState)).toBe(false);
    });

    it('returns true for a large dataset', () => {
      const state = prepareState({
        data: prepareLargeDataset(),
        beforeLayoutActions: [
          () =>
            toggleModularPipelinesExpanded(['data_science', 'data_processing']),
        ],
      });
      expect(getTriggerLargeGraphWarning(state)).toBe(true);
    });

    it('returns false if the sizewarning flag is false', () => {
      const state = reducer(
        prepareState({ data: prepareLargeDataset() }),
        changeFlag('sizewarning', false)
      );
      expect(getTriggerLargeGraphWarning(state)).toBe(false);
    });

    it('returns false if ignoreLargeWarning is true', () => {
      const state = reducer(
        prepareState({ data: prepareLargeDataset() }),
        toggleIgnoreLargeWarning(true)
      );
      expect(getTriggerLargeGraphWarning(state)).toBe(false);
    });

    it('returns false if layout has already been calculated', () => {
      // The warning should only appear once on first load, if at all.
      // i.e. in cases where a user enables filters to reveal the graph,
      // then disables them again, the warning should not show repeatedly.
      const actions = [
        // Filter out all data nodes to reduce node-count below threshold
        () => toggleTypeDisabled('data', true),
        // Run layout to update state.graph
        (state) => {
          const layout = graphNew;
          return updateGraph(layout(getGraphInput(state)));
        },
        // Turn the filter back off
        () => toggleTypeDisabled('data', false),
      ];
      const state = actions.reduce(
        (state, action) => reducer(state, action(state)),
        prepareState({ data: prepareLargeDataset() })
      );
      expect(getTriggerLargeGraphWarning(state)).toBe(false);
    });
  });

  describe('getGraphInput', () => {
    it('returns a graph input object', () => {
      expect(getGraphInput(mockState)).toEqual(
        expect.objectContaining({
          nodes: expect.any(Array),
          edges: expect.any(Array),
          layers: expect.any(Array),
        })
      );
    });
  });

  describe('getSidebarWidth', () => {
    it(`if visible is true returns the 'open' width`, () => {
      expect(getSidebarWidth(true, sidebarWidth)).toEqual(sidebarWidth.open);
    });

    it(`if visble is false returns the 'closed' width`, () => {
      expect(getSidebarWidth(false, sidebarWidth)).toEqual(sidebarWidth.closed);
    });
  });

  describe('getChartSize', () => {
    it('returns a set of undefined properties if chartSize DOMRect is not supplied', () => {
      expect(getChartSize(mockState)).toEqual({
        height: undefined,
        left: undefined,
        outerHeight: undefined,
        outerWidth: undefined,
        sidebarWidth: undefined,
        top: undefined,
        width: undefined,
      });
    });

    it('returns a DOMRect converted into an Object, with some extra properties', () => {
      const newMockState = {
        ...mockState,
        chartSize: { left: 100, top: 100, width: 1000, height: 1000 },
      };
      expect(getChartSize(newMockState)).toEqual({
        height: expect.any(Number),
        left: expect.any(Number),
        outerHeight: expect.any(Number),
        outerWidth: expect.any(Number),
        sidebarWidth: expect.any(Number),
        metaSidebarWidth: expect.any(Number),
        codeSidebarWidth: expect.any(Number),
        minWidthScale: expect.any(Number),
        top: expect.any(Number),
        width: expect.any(Number),
      });
    });
  });
});

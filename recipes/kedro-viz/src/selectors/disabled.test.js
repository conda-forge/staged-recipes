import { toggleLayers } from '../actions';
import { toggleModularPipelinesExpanded } from '../actions/modular-pipelines';
import { toggleNodesDisabled } from '../actions/nodes';
import { toggleTypeDisabled } from '../actions/node-type';
import { toggleTagFilter } from '../actions/tags';
import reducer from '../reducers';
import spaceflights from '../utils/data/spaceflights.mock.json';
import { prepareState } from '../utils/state.mock';
import {
  getEdgeDisabled,
  getNodeDisabled,
  getNodeDisabledTag,
  getVisibleLayerIDs,
  getVisibleNodeIDs,
} from './disabled';

const getNodeIDs = (state) => state.node.ids;
const getEdgeIDs = (state) => state.edge.ids;
const getEdgeSources = (state) => state.edge.sources;
const getEdgeTargets = (state) => state.edge.targets;
const getNodeTags = (state) => state.node.tags;

describe('Selectors', () => {
  const mockState = prepareState({
    data: spaceflights,
    beforeLayoutActions: [
      () => toggleModularPipelinesExpanded(['data_science', 'data_processing']),
    ],
  });

  describe('getNodeDisabledTag', () => {
    it("returns an object whose keys match the current pipeline's nodes", () => {
      expect(Object.keys(getNodeDisabledTag(mockState))).toEqual(
        getNodeIDs(mockState)
      );
    });

    it('returns an object whose values are all Booleans', () => {
      expect(
        Object.values(getNodeDisabledTag(mockState)).every(
          (value) => typeof value === 'boolean'
        )
      ).toBe(true);
    });

    it('does not disable any nodes if all tags filters are inactive', () => {
      const nodeDisabled = getNodeDisabledTag(mockState);
      expect(Object.values(nodeDisabled)).toEqual(
        Object.values(nodeDisabled).map(() => false)
      );
    });

    it('disables a node with no tags if a tag filter is active', () => {
      const tag = mockState.tag.ids[0];
      const nodeTags = getNodeTags(mockState);
      // Choose a node that has no tags (and which should be disabled)
      const hasNoTags = (id) => !Boolean(nodeTags[id].length);
      const disabledNodeID = getNodeIDs(mockState).find(hasNoTags);
      // Update the state to enable one of the tags for that node
      const newMockState = reducer(mockState, toggleTagFilter(tag, true));
      expect(getNodeDisabledTag(newMockState)[disabledNodeID]).toEqual(true);
    });

    it('does not disable a node if only one of its several tag filters are active', () => {
      const nodeTags = getNodeTags(mockState);
      // Choose a node that has > 1 tag
      const enabledNodeID = getNodeIDs(mockState).find(
        (id) => nodeTags[id].length > 1
      );
      // Update the state to enable one of the tags for that node
      const enabledNodeTags = nodeTags[enabledNodeID];
      const newMockState = reducer(
        mockState,
        toggleTagFilter(enabledNodeTags[0], true)
      );
      expect(getNodeDisabledTag(newMockState)[enabledNodeID]).toEqual(false);
    });

    it('does not disable a node if all of its several tag filters are active', () => {
      const nodeTags = getNodeTags(mockState);
      // Choose a node that has > 1 tag
      const enabledNodeID = getNodeIDs(mockState).find(
        (id) => nodeTags[id].length > 1
      );
      // Update the state to activate all of the tag filters for that node
      const enabledNodeTags = nodeTags[enabledNodeID];
      const newMockState = enabledNodeTags.reduce(
        (state, tag) => reducer(state, toggleTagFilter(tag, true)),
        mockState
      );
      expect(getNodeDisabledTag(newMockState)[enabledNodeID]).toEqual(false);
    });
  });

  describe('getNodeDisabled', () => {
    it('returns an object', () => {
      expect(getNodeDisabled(mockState)).toEqual(expect.any(Object));
    });

    it("returns an object whose keys match the current pipeline's nodes", () => {
      expect(Object.keys(getNodeDisabled(mockState))).toEqual(
        getNodeIDs(mockState)
      );
    });

    it('returns an object whose values are all Booleans', () => {
      expect(
        Object.values(getNodeDisabled(mockState)).every(
          (value) => typeof value === 'boolean'
        )
      ).toBe(true);
    });
  });

  describe('getEdgeDisabled', () => {
    const nodeID = mockState.modularPipeline.tree['__root__'].children[0].id;
    const tempMockState = reducer(
      mockState,
      toggleNodesDisabled([nodeID], true)
    );
    const newMockState = reducer(
      tempMockState,
      toggleTypeDisabled('parameters', false)
    );
    const edgeDisabled = getEdgeDisabled(newMockState);
    const edges = getEdgeIDs(newMockState);
    it('returns an object', () => {
      expect(getEdgeDisabled(mockState)).toEqual(expect.any(Object));
    });

    it("returns an object whose keys match the current pipeline's edges", () => {
      expect(Object.keys(getEdgeDisabled(mockState))).toEqual(
        getEdgeIDs(mockState)
      );
    });

    it('returns an object whose values are all Booleans', () => {
      expect(
        Object.values(getEdgeDisabled(mockState)).every(
          (value) => typeof value === 'boolean'
        )
      ).toBe(true);
    });

    it('returns an object', () => {
      expect(getEdgeDisabled(mockState)).toEqual(expect.any(Object));
    });

    it("returns an object whose keys match the current pipeline's edges", () => {
      expect(Object.keys(getEdgeDisabled(mockState))).toEqual(
        getEdgeIDs(mockState)
      );
    });

    it('returns an object whose values are all Booleans', () => {
      expect(
        Object.values(getEdgeDisabled(mockState)).every(
          (value) => typeof value === 'boolean'
        )
      ).toBe(true);
    });
    it('disables an edge if one of its nodes is disabled', () => {
      const edgeDisabled = getEdgeDisabled(newMockState);
      const edges = getEdgeIDs(newMockState);
      const disabledEdges = Object.keys(edgeDisabled).filter(
        (id) => edgeDisabled[id]
      );
      const disabledEdgesMock = edges.filter(
        (id) =>
          getEdgeSources(newMockState)[id] === nodeID ||
          getEdgeTargets(newMockState)[id] === nodeID
      );
      expect(disabledEdges).toEqual(expect.arrayContaining(disabledEdgesMock));
    });
    it('does not disable an edge if none of its nodes are disabled', () => {
      const disabledEdges = Object.keys(edgeDisabled).filter(
        (id) => edgeDisabled[id]
      );
      const enabledEdgesMock = edges.filter(
        (id) =>
          getEdgeSources(newMockState)[id] !== nodeID &&
          getEdgeTargets(newMockState)[id] !== nodeID
      );
      expect(enabledEdgesMock).not.toEqual(
        expect.arrayContaining(disabledEdges)
      );
    });
  });

  describe('getVisibleNodeIDs', () => {
    const newMockState = reducer(
      mockState,
      toggleTypeDisabled('parameters', false)
    );
    it('returns an array of node IDs currently visible on the sidebar', () => {
      expect(new Set([...getVisibleNodeIDs(newMockState)])).toEqual(
        new Set([
          ...Object.keys(newMockState.modularPipeline.visible).filter(
            (nodeID) => newMockState.modularPipeline.visible[nodeID]
          ),
        ])
      );
    });
  });

  describe('getVisibleLayerIDs', () => {
    it('returns an array of layer IDs', () => {
      expect(getVisibleLayerIDs(mockState)).toEqual(mockState.layer.ids);
    });

    it('returns an empty array if layers are disabled', () => {
      const newMockState = reducer(mockState, toggleLayers(false));
      expect(getVisibleLayerIDs(newMockState)).toEqual([]);
    });

    it('returns an empty array if there are no layers', () => {
      const newMockState = {
        ...mockState,
        layer: {
          ids: [],
          visible: true,
        },
      };
      expect(getVisibleLayerIDs(newMockState)).toEqual([]);
    });
  });
});

import { mockState } from '../utils/state.mock';
import { getLayerNodes, getNodeRank } from './ranks';
import { getVisibleNodeIDs, getVisibleLayerIDs } from './disabled';
import { getVisibleEdges } from './edges';
import { toggleLayers } from '../actions';
import reducer from '../reducers';

const getNodeLayer = (state) => state.node.layer;

describe('Selectors', () => {
  describe('getLayerNodes', () => {
    it('returns an array containing an array of node IDs', () => {
      expect(getLayerNodes(mockState.spaceflights)).toEqual(
        expect.arrayContaining([expect.arrayContaining([expect.any(String)])])
      );
    });

    test('all node IDs are in the correct layer', () => {
      const layerIDs = getVisibleLayerIDs(mockState.spaceflights);
      const nodeLayer = getNodeLayer(mockState.spaceflights);
      expect(
        getLayerNodes(mockState.spaceflights).every((layerNodeIDs, i) =>
          layerNodeIDs.every((nodeID) => nodeLayer[nodeID] === layerIDs[i])
        )
      ).toBe(true);
    });

    it('returns an empty array if layers are disabled', () => {
      const newMockState = reducer(mockState.spaceflights, toggleLayers(false));
      expect(getLayerNodes(newMockState)).toEqual([]);
    });
  });

  describe('getNodeRank', () => {
    const nodeRank = getNodeRank(mockState.spaceflights);
    const nodeIDs = getVisibleNodeIDs(mockState.spaceflights);
    const edges = getVisibleEdges(mockState.spaceflights);

    it('returns an object', () => {
      expect(nodeRank).toEqual(expect.any(Object));
    });

    it('returns an object containing ranks for each node ID', () => {
      expect(nodeRank).toEqual(
        nodeIDs.reduce((ranks, nodeID) => {
          ranks[nodeID] = expect.any(Number);
          return ranks;
        }, {})
      );
    });

    test('for every edge, the source rank is less than the target rank', () => {
      expect(
        edges.every((edge) => nodeRank[edge.source] < nodeRank[edge.target])
      ).toBe(true);
    });

    it('returns an empty object if layers are disabled', () => {
      const newMockState = reducer(mockState.spaceflights, toggleLayers(false));
      expect(getNodeRank(newMockState)).toEqual({});
    });
  });
});

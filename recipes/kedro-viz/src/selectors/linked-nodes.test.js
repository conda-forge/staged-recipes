import { getLinkedNodes } from './linked-nodes';
import { prepareState } from '../utils/state.mock';
import { toggleNodeClicked } from '../actions/nodes';
import spaceflights from '../utils/data/spaceflights.mock.json';
import {
  toggleModularPipelinesExpanded,
  toggleSingleModularPipelineExpanded,
} from '../actions/modular-pipelines';
import reducer from '../reducers';

describe('getLinkedNodes function', () => {
  const mockState = prepareState({
    data: spaceflights,
    beforeLayoutActions: [
      () => toggleModularPipelinesExpanded(['data_science', 'data_processing']),
    ],
  });

  const { nodes } = mockState.graph;
  const nodeID = nodes.find((d) =>
    d.name.includes('Preprocess Companies Node')
  ).id;
  const newMockState = reducer(mockState, toggleNodeClicked(nodeID));
  const linkedNodes = getLinkedNodes(newMockState);

  it('should return an object', () => {
    expect(linkedNodes).toEqual(expect.any(Object));
  });

  describe('should return true for ancestor/descendant nodes', () => {
    test.each([
      // ancestor
      ['Companies', '0abef172'],
      // descendants
      ['Preprocessed Companies', 'daf35ba0'],
      ['Regressor', '04424659'],
      ['Metrics', '966b9734'],
    ])('node %s should be true', (name, id) => {
      expect(linkedNodes[id]).toBe(true);
    });
  });

  describe('should not return any linked nodes for non-ancestor/descendant nodes', () => {
    test.each([
      ['Parameters', 'f1f1425b'],
      ['Shuttles', 'f192326a'],
      ['Preprocess Shuttles Node', 'b7bb7198'],
    ])('node %s should be false', (name, id) => {
      expect(linkedNodes[id]).toBe(undefined);
    });
  });
});

describe('getLinkedNodes function of a single modular pipeline', () => {
  const mockState = prepareState({
    data: spaceflights,
    beforeLayoutActions: [
      () => toggleSingleModularPipelineExpanded('data_processing'),
    ],
  });

  const { nodes } = mockState.graph;
  const nodeID = nodes.find((d) =>
    d.name.includes('Preprocess Shuttles Node')
  ).id;
  const newMockState = reducer(mockState, toggleNodeClicked(nodeID));
  const linkedNodes = getLinkedNodes(newMockState);

  it('should return an object', () => {
    expect(linkedNodes).toEqual(expect.any(Object));
  });

  describe('should return true for ancestor/descendant nodes', () => {
    test.each([
      // ancestor
      ['Shuttles', 'f192326a'],
      // descendants
      ['Preprocessed Shuttles', 'e5a9ec27'],
      ['Create Model Input Table Node', '47b81aa6'],
      ['Model Input Table', '23c94afb'],
    ])('node %s should be true', (name, id) => {
      expect(linkedNodes[id]).toBe(true);
    });
  });

  describe('should not return any linked nodes for non-ancestor/descendant nodes', () => {
    test.each([
      ['Parameters', 'f1f1425b'],
      ['Companies', '0abef172'],
      ['Preprocess Companies Node', 'c09084f2'],
    ])('node %s should be false', (name, id) => {
      expect(linkedNodes[id]).toBe(undefined);
    });
  });
});

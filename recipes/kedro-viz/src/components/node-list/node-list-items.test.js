import {
  getFilteredNodes,
  getNodeIDs,
  highlightMatch,
  nodeMatchesSearch,
  filterNodeGroups,
  getFilteredTags,
  getFilteredTagItems,
  getFilteredElementTypes,
  getFilteredElementTypeItems,
  getGroups,
  getFilteredItems,
} from './node-list-items';
import { mockState } from '../../utils/state.mock';
import {
  getGroupedNodes,
  getInputOutputNodesForFocusedModularPipeline,
} from '../../selectors/nodes';
import { getNodeTypes } from '../../selectors/node-types';
import { getTagData, getTagNodeCounts } from '../../selectors/tags';
import { sidebarElementTypes } from '../../config';

const ungroupNodes = (groupedNodes) =>
  Object.keys(groupedNodes).reduce(
    (names, key) => names.concat(groupedNodes[key]),
    []
  );

describe('node-list-selectors', () => {
  describe('getFilteredNodes', () => {
    const nodes = getGroupedNodes(mockState.spaceflights);
    let searchValue = 'Split';
    const { filteredNodes } = getFilteredNodes({ nodes, searchValue });
    const nodeList = ungroupNodes(filteredNodes);

    test.each(nodeList.map((node) => node.name))(
      `node name "%s" contains search term "${searchValue}"`,
      (name) => {
        expect(name).toEqual(expect.stringMatching(searchValue));
      }
    );

    test.each(nodeList.map((node) => node.highlightedLabel))(
      `node label "%s" contains highlighted search term "<b>${searchValue}</b>"`,
      (name) => {
        expect(name).toEqual(expect.stringMatching(`<b>${searchValue}</b>`));
      }
    );
  });

  describe('getFilteredElementTypes', () => {
    const elementTypes = Object.keys(sidebarElementTypes);
    const searchValue = 'n';
    const filteredElementTypes = getFilteredElementTypes({
      searchValue,
    }).elementType;

    const elementType = expect.arrayContaining([
      expect.objectContaining({
        id: expect.any(String),
        name: expect.any(String),
      }),
    ]);

    it('returns expected number of element types', () => {
      expect(filteredElementTypes.length).not.toBe(elementTypes.length);
      expect(filteredElementTypes).toHaveLength(1);
    });

    it('returns element types of the correct format', () => {
      expect(filteredElementTypes).toEqual(elementType);
    });
  });

  describe('getFilteredElementTypeItems', () => {
    const nodeTypes = getNodeTypes(mockState.spaceflights);
    const searchValue = 'm';
    const filteredElementTypeItems = getFilteredElementTypeItems({
      nodeTypes,
      searchValue,
    }).elementType;

    const elementTypeItems = expect.arrayContaining([
      expect.objectContaining({
        id: expect.any(String),
        name: expect.any(String),
        highlightedLabel: expect.any(String),
        type: expect.any(String),
        visibleIcon: expect.any(Function),
        invisibleIcon: expect.any(Function),
        active: expect.any(Boolean),
        selected: expect.any(Boolean),
        faded: expect.any(Boolean),
        visible: expect.any(Boolean),
        disabled: expect.any(Boolean),
        checked: expect.any(Boolean),
        count: expect.any(Number),
      }),
    ]);

    it('returns expected items matching the searchValue', () => {
      expect(filteredElementTypeItems.length).not.toBe(nodeTypes.length);
      expect(filteredElementTypeItems).toHaveLength(1);

      expect(filteredElementTypeItems[0].name).toEqual('Parameters');
      expect(filteredElementTypeItems[0].id).toEqual('parameters');
    });

    it('returns items of the correct format', () => {
      expect(filteredElementTypeItems).toEqual(elementTypeItems);
    });

    it('returns filtered items that contain the search value', () => {
      filteredElementTypeItems.forEach((elementTypeItem) => {
        expect(elementTypeItem.name).toContain(searchValue);
        expect(elementTypeItem.id).toContain(searchValue);
      });
    });

    it('returns items with expected counts', () => {
      expect(filteredElementTypeItems[0].count).toEqual(1);
    });
  });

  describe('getFilteredTags', () => {
    const tags = getTagData(mockState.spaceflights);
    const searchValue = 'Split';
    const filteredTags = getFilteredTags({ tags, searchValue }).tag;

    it('returns expected number of tags', () => {
      expect(filteredTags.length).not.toBe(tags.length);
      expect(filteredTags).toHaveLength(1);
    });

    test.each(filteredTags.map((tag) => tag.name))(
      `tag name "%s" contains search term "${searchValue}"`,
      (name) => {
        expect(name).toEqual(expect.stringMatching(searchValue));
      }
    );

    test.each(filteredTags.map((tag) => tag.highlightedLabel))(
      `tag label "%s" contains highlighted search term "<b>${searchValue}</b>"`,
      (name) => {
        expect(name).toEqual(expect.stringMatching(`<b>${searchValue}</b>`));
      }
    );
  });

  describe('getFilteredTagItems', () => {
    const tags = getTagData(mockState.spaceflights);
    const searchValue = 's';
    const filteredTagItems = getFilteredTagItems({
      tagNodeCounts: getTagNodeCounts(mockState.spaceflights),
      tags,
      searchValue,
    }).tag;

    const tagItems = expect.arrayContaining([
      expect.objectContaining({
        id: expect.any(String),
        name: expect.any(String),
        highlightedLabel: expect.any(String),
        type: expect.any(String),
        visibleIcon: expect.any(Function),
        invisibleIcon: expect.any(Function),
        active: expect.any(Boolean),
        selected: expect.any(Boolean),
        faded: expect.any(Boolean),
        visible: expect.any(Boolean),
        disabled: expect.any(Boolean),
        checked: expect.any(Boolean),
        count: expect.any(Number),
      }),
    ]);

    it('returns expected items matching the searchValue', () => {
      expect(filteredTagItems.length).not.toBe(tags.length);
      expect(filteredTagItems).toHaveLength(3);

      expect(filteredTagItems[0].name).toEqual('Features');
      expect(filteredTagItems[0].id).toEqual('features');
      expect(filteredTagItems[1].name).toEqual('Preprocessing');
      expect(filteredTagItems[1].id).toEqual('preprocessing');
      expect(filteredTagItems[2].name).toEqual('Split');
      expect(filteredTagItems[2].id).toEqual('split');
    });

    it('returns items of the correct format', () => {
      expect(filteredTagItems).toEqual(tagItems);
    });

    it('returns the filtered items that contains the search value', () => {
      filteredTagItems.forEach((tagItem) => {
        expect(tagItem.name.toLowerCase()).toContain(searchValue);
        expect(tagItem.id).toContain(searchValue);
      });
    });

    it('returns tag items with expected counts', () => {
      expect(filteredTagItems[0].count).toEqual(5);
      expect(filteredTagItems[1].count).toEqual(6);
    });
  });

  describe('getFilteredItems', () => {
    const searchValue = 'a';

    const filteredItems = getFilteredItems({
      nodes: getGroupedNodes(mockState.spaceflights),
      nodeTypes: getNodeTypes(mockState.spaceflights),
      tags: getTagData(mockState.spaceflights),
      tagNodeCounts: getTagNodeCounts(mockState.spaceflights),
      nodeSelected: {},
      searchValue,
      inputOutputDataNodes: getInputOutputNodesForFocusedModularPipeline(
        mockState.spaceflights
      ),
    });

    const items = expect.arrayContaining([
      expect.objectContaining({
        id: expect.any(String),
        name: expect.any(String),
        highlightedLabel: expect.any(String),
        type: expect.any(String),
        visibleIcon: expect.any(Function),
        invisibleIcon: expect.any(Function),
        faded: expect.any(Boolean),
        visible: expect.any(Boolean),
        disabled: expect.any(Boolean),
        checked: expect.any(Boolean),
      }),
    ]);

    it('filters expected number of items', () => {
      expect(filteredItems.task).toHaveLength(5);
      expect(filteredItems.data).toHaveLength(5);
      expect(filteredItems.parameters).toHaveLength(1);
      expect(filteredItems.tag).toHaveLength(2);
      expect(filteredItems.modularPipeline).toHaveLength(2);
      expect(filteredItems.elementType).toHaveLength(2);
    });

    it('returns items for each type in the correct format', () => {
      expect(filteredItems).toEqual(
        expect.objectContaining({
          task: items,
          data: items,
          parameters: items,
          tag: items,
        })
      );
    });

    it('returns tag items with expected counts', () => {
      expect(filteredItems.tag[0].count).toEqual(5);
      expect(filteredItems.tag[1].count).toEqual(4);
    });
  });

  describe('getGroups', () => {
    const nodeTypes = getNodeTypes(mockState.spaceflights);

    const items = getFilteredItems({
      nodes: getGroupedNodes(mockState.spaceflights),
      nodeTypes,
      tags: getTagData(mockState.spaceflights),
      tagNodeCounts: getTagNodeCounts(mockState.spaceflights),
      nodeSelected: {},
      searchValue: '',
      inputOutputDataNodes: getInputOutputNodesForFocusedModularPipeline(
        mockState.spaceflights
      ),
    });

    const groups = getGroups({ nodeTypes, items });

    const groupType = expect.objectContaining({
      id: expect.any(String),
      name: expect.any(String),
      type: expect.any(String),
      visibleIcon: expect.any(Function),
      invisibleIcon: expect.any(Function),
      kind: expect.any(String),
      allUnchecked: expect.any(Boolean),
      allChecked: expect.any(Boolean),
      checked: expect.any(Boolean),
    });

    it('returns groups for each type in the correct format', () => {
      expect(groups).toEqual(
        expect.objectContaining({
          elementType: groupType,
          tag: groupType,
        })
      );
    });
  });

  describe('getNodeIDs', () => {
    const generateNodes = (type, count) =>
      Array.from(new Array(count)).map((d, i) => ({
        id: type + i,
      }));

    const nodes = {
      data: generateNodes('data', 10),
      task: generateNodes('task', 10),
      parameters: generateNodes('parameters', 10),
    };

    it('returns a list of node IDs', () => {
      const nodeIDs = getNodeIDs(nodes);
      expect(nodeIDs).toHaveLength(30);
      expect(nodeIDs).toEqual(expect.arrayContaining([expect.any(String)]));
      expect(nodeIDs).toContain('data0');
      expect(nodeIDs).toContain('task1');
      expect(nodeIDs).toContain('parameters1');
    });
  });

  describe('highlightMatch', () => {
    const nodes = getGroupedNodes(mockState.spaceflights);
    const searchValue = 'e';
    const formattedNodes = highlightMatch(nodes, searchValue);
    const nodeList = ungroupNodes(formattedNodes);

    describe(`nodes which match the search term "${searchValue}"`, () => {
      const matchingNodeList = nodeList.filter((node) =>
        node.name.includes(searchValue)
      );
      test.each(matchingNodeList.map((node) => node.highlightedLabel))(
        `node label "%s" contains highlighted search term "<b>${searchValue}</b>"`,
        (label) => {
          expect(label).toEqual(expect.stringMatching(`<b>${searchValue}</b>`));
        }
      );
    });

    describe(`nodes which do not match the search term "${searchValue}"`, () => {
      const notMatchingNodeList = nodeList.filter(
        (node) => !node.name.includes(searchValue)
      );
      test.each(notMatchingNodeList.map((node) => node.highlightedLabel))(
        `node label "%s" does not contain "<b>"`,
        (label) => {
          expect(label).not.toEqual(expect.stringMatching(`<b>`));
        }
      );
    });
  });

  describe('nodeMatchesSearch', () => {
    const node = { name: 'qwertyuiop' };

    it('returns true if the node name matches the search', () => {
      expect(nodeMatchesSearch(node, 'qwertyuiop')).toBe(true);
      expect(nodeMatchesSearch(node, 'qwe')).toBe(true);
      expect(nodeMatchesSearch(node, 'p')).toBe(true);
    });

    it('returns true if the search is falsey', () => {
      expect(nodeMatchesSearch(node, '')).toBe(true);
      expect(nodeMatchesSearch(node, null)).toBe(true);
      expect(nodeMatchesSearch(node, undefined)).toBe(true);
    });

    it('returns false if the node name does not match the search', () => {
      expect(nodeMatchesSearch(node, 'a')).toBe(false);
      expect(nodeMatchesSearch(node, 'qwe ')).toBe(false);
      expect(nodeMatchesSearch(node, ' ')).toBe(false);
      expect(nodeMatchesSearch(node, '_')).toBe(false);
    });
  });

  describe('filterNodeGroups', () => {
    const nodes = getGroupedNodes(mockState.spaceflights);
    const searchValue = 'a';
    const filteredNodes = filterNodeGroups(nodes, searchValue);
    const nodeList = ungroupNodes(filteredNodes);
    const notMatchingNodeList = ungroupNodes(nodes).filter(
      (node) => !node.name.includes(searchValue)
    );

    describe('nodes which match the search term', () => {
      test.each(nodeList.map((node) => node.name))(
        `node name "%s" should contain search term "${searchValue}"`,
        (name) => {
          expect(name).toEqual(expect.stringMatching(searchValue));
        }
      );
    });

    describe('nodes which do not match the search term', () => {
      test.each(notMatchingNodeList.map((node) => node.id))(
        `filtered node list should not contain a node with id "%s"`,
        (nodeID) => {
          expect(nodeList.map((node) => node.id)).not.toContain(
            expect.stringMatching(searchValue)
          );
        }
      );
    });
  });
});

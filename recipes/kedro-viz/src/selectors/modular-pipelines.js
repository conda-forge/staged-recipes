import { escapeRegExp, getHighlightedText } from '../utils/search-utils';
export const getModularPipelineIDs = (state) => state.modularPipeline.ids;
export const getFocusedModularPipeline = (state) =>
  state.visible.modularPipelineFocusMode;
export const getModularPipelinesTree = (state) => state.modularPipeline.tree;

/**
 * Search a given string in a string target.
 * Return whether there is a match.
 * @param {String} searchValue the string to search for.
 * @param {String} target the target to search in.
 * @return {Boolean} whether there is a match.
 */
export const searchString = (searchValue, target) => {
  if (!searchValue || !target) {
    return false;
  }
  return new RegExp(escapeRegExp(target), 'gi').test(searchValue);
};

/**
 * Return whether a tree node in a modular pipeline tree is a leaf.
 */
const isTreeLeaf = (treeNode) => treeNode.type !== 'modularPipeline';

/**
 * Search a given string in a (modular pipelines) tree.
 */
export const searchTree = (
  searchValue,
  tree,
  currentNodeID = '__root__',
  result = {}
) => {
  const treeNode = tree[currentNodeID];
  if (!treeNode) {
    return false;
  }

  const foundChildren = [];

  for (const childNode of treeNode.children) {
    if (isTreeLeaf(childNode)) {
      // if the child node is a leaf, simply search the leaf's name
      // and add to the search result if there is a match.
      const found = searchString(childNode.data.name, searchValue);
      if (found) {
        foundChildren.push({
          ...childNode,
          data: {
            ...childNode.data,
            highlightedLabel: getHighlightedText(
              childNode.data.name,
              searchValue
            ),
          },
        });
      }
    } else {
      // if the child node is a tree, recursively search it
      // and add the child node to the list of found children
      // if there is a matching value in its tree.
      const found = searchTree(searchValue, tree, childNode.id, result);
      if (found) {
        foundChildren.push({
          ...childNode,
          highlightedLabel: getHighlightedText(
            result[childNode.id]?.name || '',
            searchValue
          ),
        });
      }
    }
  }

  if (foundChildren.length > 0 || searchString(treeNode.name, searchValue)) {
    result[currentNodeID] = {
      ...treeNode,
      highlightedLabel: getHighlightedText(treeNode.name, searchValue),
      children: foundChildren,
    };
    return true;
  }

  return false;
};

/**
 * Search a given value in a modularPipelinesTree
 * and return a tree structure containing the searchResult.
 * @param {Object} modularPipelinesTree the modular pipelines tree to search in.
 * @param {String} searchValue the value to search for in the given modular pipelines tree.
 * @return {Object} a tree structure containing the searchResult.
 */
export const getModularPipelinesSearchResult = (
  modularPipelinesTree,
  searchValue
) => {
  if (!modularPipelinesTree) {
    return {};
  }
  const searchResult = {};
  searchTree(searchValue, modularPipelinesTree, '__root__', searchResult);
  return searchResult;
};

import { getUrl } from '../utils';
import loadJsonData from '../store/load-data';

export const TOGGLE_NODE_CLICKED = 'TOGGLE_NODE_CLICKED';

/**
 * Update the value of the currently-active clicked node
 * @param {String|null} nodeClicked The node's unique identifier
 */
export function toggleNodeClicked(nodeClicked) {
  return {
    type: TOGGLE_NODE_CLICKED,
    nodeClicked,
  };
}

export const TOGGLE_NODES_DISABLED = 'TOGGLE_NODES_DISABLED';

/**
 * Toggle a selected group of nodes' visibility on/off
 * @param {Array} nodeIDs The nodes' unique identifiers
 * @param {Boolean} isDisabled Whether the node should be visible
 */
export function toggleNodesDisabled(nodeIDs, isDisabled) {
  return {
    type: TOGGLE_NODES_DISABLED,
    nodeIDs,
    isDisabled,
  };
}

export const TOGGLE_NODE_HOVERED = 'TOGGLE_NODE_HOVERED';

/**
 * Update the value of the currently-active hovered node
 * @param {String|null} nodeHovered The node's unique identifier
 */
export function toggleNodeHovered(nodeHovered) {
  return {
    type: TOGGLE_NODE_HOVERED,
    nodeHovered,
  };
}

export const TOGGLE_NODE_DATA_LOADING = 'TOGGLE_NODE_DATA_LOADING';

/**
 * Toggle whether to display the loading spinner
 * @param {Boolean} loading True if pipeline is still loading
 */
export function toggleNodeDataLoading(loading) {
  return {
    type: TOGGLE_NODE_DATA_LOADING,
    loading,
  };
}

export const ADD_NODE_METADATA = 'ADD_NODE_METADATA';

/**
 * Toggle whether to display the loading spinner
 * @param {Object} data The node's data
 */
export function addNodeMetadata(data) {
  return {
    type: ADD_NODE_METADATA,
    data,
  };
}

/**
 * update node metadata on selection, loading new data if it has not been previously called
 * @param {String} nodeID node id of clicked node
 * @return {Function} A promise that resolves when the data is loaded
 */
export function loadNodeData(nodeID) {
  return async function (dispatch, getState) {
    const { dataSource, node } = getState();
    dispatch(toggleNodeClicked(nodeID));

    if (dataSource === 'json' && nodeID && !node.fetched[nodeID]) {
      dispatch(toggleNodeDataLoading(true));
      const url = getUrl('nodes', nodeID);
      const nodeData = await loadJsonData(url);
      dispatch(addNodeMetadata({ id: nodeID, data: nodeData }));
      dispatch(toggleNodeDataLoading(false));
    }
  };
}

import React from 'react';
import { connect } from 'react-redux';

import { makeStyles, withStyles } from '@mui/styles';
import TreeView from '@mui/lab/TreeView';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ChevronRightIcon from '@mui/icons-material/ChevronRight';
import sortBy from 'lodash.sortby';

import { loadNodeData } from '../../actions/nodes';
import { getNodeSelected } from '../../selectors/nodes';
import { isModularPipelineType } from '../../selectors/node-types';
import NodeListTreeItem from './node-list-tree-item';
import VisibleIcon from '../icons/visible';
import InvisibleIcon from '../icons/invisible';
import FocusModeIcon from '../icons/focus-mode';

// Display order of node groups
const GROUPED_NODES_DISPLAY_ORDER = {
  modularPipeline: 0,
  task: 1,
  data: 2,
  parameter: 3,
};

// please note that this setup is unique for initialization of the material-ui tree,
// and setup is only used here and not anywhere else in the app.
const useStyles = makeStyles({
  root: {
    height: 110,
    flexGrow: 1,
    maxWidth: 400,
  },
});

const StyledTreeView = withStyles({
  root: {
    padding: '0 0 0 20px',
  },
})(TreeView);

/**
 * Return whether the given modular pipeline ID is on focus mode path, i.e.
 * it's not the currently focused pipeline nor one of its children.
 * @param {String} focusModeID The currently focused modular pipeline ID.
 * @param {String} modularPipelineID The modular pipeline ID to check.
 * @return {Boolean} Whether the given modular pipeline ID is on focus mode path.
 */
const isOnFocusedModePath = (focusModeID, modularPipelineID) => {
  return (
    modularPipelineID === focusModeID ||
    modularPipelineID.startsWith(`${focusModeID}.`)
  );
};

/**
 * Return the data of a modular pipeline to display as a row in the node list.
 * @param {Object} params
 * @param {String} params.id The modular pipeline ID
 * @param {String} params.highlightedLabel The modular pipeline name with highlights when matched under search
 * @param {Object} params.data The modular pipeline data to display
 * @param {Boolean} params.disabled Whether the modular pipeline is disabled, e.g. when it's not the focused one
 * @param {Boolean} params.focused Whether the modular pipeline is the focused one in focus mode
 * @return {Object} The modular pipeline's data needed to render as a row in the node list tree.
 */
const getModularPipelineRowData = ({
  id,
  highlightedLabel,
  data,
  disabled,
  focused,
  focusModeIcon,
}) => {
  const checked = !data.disabledModularPipeline;
  return {
    id: id,
    name: highlightedLabel || data.name,
    type: 'modularPipeline',
    icon: 'modularPipeline',
    focusModeIcon: focusModeIcon,
    active: false,
    selected: false,
    faded: disabled || !checked,
    visible: !disabled && checked,
    enabled: true,
    disabled: disabled,
    focused: focused,
    checked,
  };
};

/**
 * Return the data of a node to display as a row in the node list
 * @param {Object} node The node to display
 * @param {Boolean} selected Whether the node is currently disabled
 * @param {Boolean} selected Whether the node is currently selected
 */
const getNodeRowData = (node, disabled, selected) => {
  const checked = !node.disabledNode;
  return {
    ...node,
    visibleIcon: VisibleIcon,
    invisibleIcon: InvisibleIcon,
    active: node.active,
    selected,
    faded: disabled || node.disabledNode,
    visible: !disabled && checked,
    checked,
    disabled,
  };
};

const TreeListProvider = ({
  nodeSelected,
  modularPipelinesSearchResult,
  modularPipelinesTree,
  onItemChange,
  onItemMouseEnter,
  onItemMouseLeave,
  onItemClick,
  onNodeToggleExpanded,
  focusMode,
  disabledModularPipeline,
  expanded,
  onToggleNodeSelected,
}) => {
  const classes = useStyles();

  // render a leaf node in the modular pipelines tree
  const renderLeafNode = (node) => {
    const disabled =
      node.disabledTag ||
      node.disabledType ||
      (focusMode &&
        !node.modularPipelines
          .map((modularPipelineID) =>
            isOnFocusedModePath(focusMode.id, modularPipelineID)
          )
          .some(Boolean)) ||
      (node.modularPipelines &&
        node.modularPipelines
          .map(
            (modularPipelineID) => disabledModularPipeline[modularPipelineID]
          )
          .some(Boolean));

    const selected = nodeSelected[node.id];
    return (
      <NodeListTreeItem
        data={getNodeRowData(node, disabled, selected)}
        onItemMouseEnter={onItemMouseEnter}
        onItemMouseLeave={onItemMouseLeave}
        onItemChange={onItemChange}
        onItemClick={onItemClick}
        key={node.id}
      />
    );
  };

  // recursively renders the modular pipeline tree
  const renderTree = (tree, modularPipelineID) => {
    // current tree node to render
    const node = tree[modularPipelineID];
    if (!node) {
      return;
    }

    // render each child of the tree node first
    const children = sortBy(
      node.children,
      (child) => GROUPED_NODES_DISPLAY_ORDER[child.type],
      (child) => child.data.name
    ).map((child) =>
      isModularPipelineType(child.type)
        ? renderTree(tree, child.id)
        : renderLeafNode(child.data)
    );

    // then render the node itself wrapping around the children
    // except when it's the root node,
    // because we don't want to display the __root__ modular pipeline.
    if (modularPipelineID === '__root__') {
      return children;
    }

    const isFocusedModularPipeline = focusMode?.id === node.id;
    let focusModeIcon;
    if (!focusMode) {
      focusModeIcon = FocusModeIcon;
    } else {
      focusModeIcon = isFocusedModularPipeline ? FocusModeIcon : null;
    }

    return (
      <NodeListTreeItem
        data={getModularPipelineRowData({
          ...node,
          focusModeIcon,
          disabled: focusMode && !isOnFocusedModePath(focusMode.id, node.id),
          focused: isFocusedModularPipeline,
        })}
        onItemMouseEnter={onItemMouseEnter}
        onItemMouseLeave={onItemMouseLeave}
        onItemChange={onItemChange}
        onItemClick={onItemClick}
        key={node.id}
      >
        {children}
      </NodeListTreeItem>
    );
  };

  const onItemExpandCollapseToggle = (event, expandedItemIds) => {
    onNodeToggleExpanded(expandedItemIds);
    //when the parent modular pipeline tree of the selected node is collapsed
    if (expandedItemIds.length === 0) {
      onToggleNodeSelected(null);
    }
  };

  return modularPipelinesSearchResult ? (
    <StyledTreeView
      className={classes.root}
      expanded={Object.keys(modularPipelinesSearchResult)}
      defaultCollapseIcon={<ExpandMoreIcon />}
      defaultExpandIcon={<ChevronRightIcon />}
      key="modularPipelinesSearchResult"
    >
      {renderTree(modularPipelinesSearchResult, '__root__')}
    </StyledTreeView>
  ) : (
    <StyledTreeView
      expanded={expanded}
      className={classes.root}
      defaultCollapseIcon={<ExpandMoreIcon />}
      defaultExpandIcon={<ChevronRightIcon />}
      onNodeToggle={onItemExpandCollapseToggle}
      key="modularPipelinesTree"
    >
      {renderTree(modularPipelinesTree, '__root__')}
    </StyledTreeView>
  );
};

export const mapStateToProps = (state) => ({
  nodeSelected: getNodeSelected(state),
  expanded: state.modularPipeline.expanded,
});

export const mapDispatchToProps = (dispatch) => ({
  onToggleNodeSelected: (nodeID) => {
    dispatch(loadNodeData(nodeID));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(TreeListProvider);

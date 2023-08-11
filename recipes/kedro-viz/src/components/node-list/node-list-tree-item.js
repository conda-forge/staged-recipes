import React from 'react';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ChevronRightIcon from '@mui/icons-material/ChevronRight';
import TreeItem from '@mui/lab/TreeItem';
import NodeListRow from './node-list-row';

const arrowIconColor = '#8e8e90';

const NodeListTreeItem = ({
  data,
  onItemClick,
  onItemMouseEnter,
  onItemMouseLeave,
  onItemChange,
  children,
}) => (
  <TreeItem
    className="pipeline-treeItem__root--overwrite"
    key={data.id}
    nodeId={data.id}
    // this setup is to allow flexibility for adjusting the setting for individual arrow icons
    collapseIcon={<ExpandMoreIcon style={{ color: arrowIconColor }} />}
    expandIcon={<ChevronRightIcon style={{ color: arrowIconColor }} />}
    label={
      <NodeListRow
        container="div"
        key={data.id}
        id={data.id}
        kind="element"
        label={data.highlightedLabel || data.name}
        name={data.name}
        icon={data.icon}
        type={data.type}
        active={data.active}
        checked={data.checked}
        disabled={data.disabled}
        faded={data.faded}
        visible={data.visible}
        selected={data.selected}
        allUnchecked={true}
        visibleIcon={data.visibleIcon}
        invisibleIcon={data.invisibleIcon}
        focusModeIcon={data.focusModeIcon}
        onClick={() => onItemClick(data)}
        onMouseEnter={() => onItemMouseEnter(data)}
        onMouseLeave={() => onItemMouseLeave(data)}
        onChange={(e) =>
          onItemChange(data, !e.target.checked, e.target.dataset.iconType)
        }
        rowType="tree"
        focused={data.focused}
      />
    }
  >
    {children}
  </TreeItem>
);

export default NodeListTreeItem;

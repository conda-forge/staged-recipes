import React, { useState } from 'react';
import { loadLocalStorage, saveLocalStorage } from '../../store/helpers';
import NodeListGroup from './node-list-group';
import { localStorageName } from '../../config';

const storedState = loadLocalStorage(localStorageName);

const NodeListGroups = ({
  groups,
  items,
  onGroupToggleChanged,
  onItemChange,
  onItemClick,
  onItemMouseEnter,
  onItemMouseLeave,
  searchValue,
}) => {
  const [collapsed, setCollapsed] = useState(storedState.groupsCollapsed || {});

  // Collapse/expand node group
  const onToggleGroupCollapsed = (groupID) => {
    const groupsCollapsed = {
      ...collapsed,
      [groupID]: !collapsed[groupID],
    };

    setCollapsed(groupsCollapsed);
    saveLocalStorage(localStorageName, { groupsCollapsed });
  };

  return (
    <nav className="pipeline-nodelist-section kedro">
      <ul className="pipeline-nodelist__list">
        {Object.values(groups).map((group) => (
          <NodeListGroup
            allUnchecked={group.allUnchecked}
            checked={group.checked}
            collapsed={Boolean(searchValue) ? false : collapsed[group.id]}
            group={group}
            id={group.id}
            invisibleIcon={group.invisibleIcon}
            items={items[group.id] || []}
            key={group.id}
            kind={group.kind}
            name={group.name}
            onItemChange={onItemChange}
            onItemClick={onItemClick}
            onItemMouseEnter={onItemMouseEnter}
            onItemMouseLeave={onItemMouseLeave}
            onToggleChecked={onGroupToggleChanged}
            onToggleCollapsed={onToggleGroupCollapsed}
            visibleIcon={group.visibleIcon}
          />
        ))}
      </ul>
    </nav>
  );
};

export default NodeListGroups;

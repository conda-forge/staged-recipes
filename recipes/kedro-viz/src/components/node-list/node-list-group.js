import React from 'react';
import classnames from 'classnames';
import NodeListRow from './node-list-row';
import NodeRowList from './node-list-row-list';

export const NodeListGroup = ({
  allUnchecked,
  checked,
  collapsed,
  group,
  id,
  invisibleIcon,
  items,
  kind,
  name,
  onItemChange,
  onItemClick,
  onItemMouseEnter,
  onItemMouseLeave,
  onToggleChecked,
  onToggleCollapsed,
  visibleIcon,
}) => {
  const disabledGroup = items.length === 0;

  return (
    <li
      className={classnames(
        'pipeline-nodelist__group',
        `pipeline-nodelist__group--type-${id}`,
        `pipeline-nodelist__group--kind-${kind}`,
        {
          'pipeline-nodelist__group--all-unchecked': allUnchecked,
        }
      )}
    >
      <h3 className="pipeline-nodelist__heading">
        <NodeListRow
          allUnchecked={allUnchecked}
          checked={checked}
          disabled={disabledGroup}
          id={id}
          invisibleIcon={invisibleIcon}
          kind={kind}
          label={name}
          name={name}
          onChange={(e) => {
            onToggleChecked(id, !e.target.checked);
          }}
          rowType="filter"
          visibleIcon={visibleIcon}
        >
          <button
            aria-label={`${collapsed ? 'Show' : 'Hide'} ${name.toLowerCase()}`}
            className={classnames('pipeline-type-group-toggle', {
              'pipeline-type-group-toggle--alt': collapsed,
              'pipeline-type-group-toggle--disabled': disabledGroup,
            })}
            disabled={disabledGroup}
            onClick={() => onToggleCollapsed(id)}
          />
        </NodeListRow>
      </h3>
      <NodeRowList
        collapsed={collapsed}
        group={group}
        items={items}
        onItemChange={onItemChange}
        onItemClick={onItemClick}
        onItemMouseEnter={onItemMouseEnter}
        onItemMouseLeave={onItemMouseLeave}
      />
    </li>
  );
};

export default NodeListGroup;

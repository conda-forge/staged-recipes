import React from 'react';
import modifiers from '../../utils/modifiers';
import NodeListRow, { nodeListRowHeight } from './node-list-row';
import LazyList from '../lazy-list';

const NodeRowList = ({
  items = [],
  group,
  collapsed,
  onItemClick,
  onItemChange,
  onItemMouseEnter,
  onItemMouseLeave,
}) => (
  <LazyList
    height={(start, end) => (end - start) * nodeListRowHeight}
    total={items.length}
  >
    {({
      start,
      end,
      total,
      listRef,
      upperRef,
      lowerRef,
      listStyle,
      upperStyle,
      lowerStyle,
    }) => (
      <ul
        ref={listRef}
        style={listStyle}
        className={modifiers(
          'pipeline-nodelist__children',
          { closed: collapsed },
          'pipeline-nodelist__list pipeline-nodelist__list--nested'
        )}
      >
        <li
          className={modifiers('pipeline-nodelist__placeholder-upper', {
            fade: start !== end && start > 0,
          })}
          ref={upperRef}
          style={upperStyle}
        />
        <li
          className={modifiers('pipeline-nodelist__placeholder-lower', {
            fade: start !== end && end < total,
          })}
          ref={lowerRef}
          style={lowerStyle}
        />
        {items.slice(start, end).map((item) => (
          <NodeListRow
            container="li"
            key={item.id}
            id={item.id}
            kind={group.kind}
            label={item.highlightedLabel}
            count={item.count}
            name={item.name}
            type={item.type}
            icon={item.icon}
            active={item.active}
            checked={item.checked}
            disabled={item.disabled}
            faded={item.faded}
            visible={item.visible}
            selected={item.selected}
            allUnchecked={group.allUnchecked}
            visibleIcon={item.visibleIcon}
            invisibleIcon={item.invisibleIcon}
            onClick={() => onItemClick(item)}
            onMouseEnter={() => onItemMouseEnter(item)}
            onMouseLeave={() => onItemMouseLeave(item)}
            onChange={(e) => onItemChange(item, !e.target.checked)}
            rowType="filter"
          />
        ))}
      </ul>
    )}
  </LazyList>
);

export default NodeRowList;

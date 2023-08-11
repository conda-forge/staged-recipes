import React from 'react';
import classnames from 'classnames';
import { Scrollbars } from 'react-custom-scrollbars-2';
import SearchList from '../search-list';
import NodeListGroups from './node-list-groups';
import NodeListTree from './node-list-tree';
import SplitPanel from '../split-panel';

import './styles/node-list.css';

/**
 * Scrollable list of toggleable items, with search & filter functionality
 */
const NodeList = ({
  faded,
  items,
  modularPipelinesTree,
  modularPipelinesSearchResult,
  groups,
  searchValue,
  getGroupState,
  onUpdateSearchValue,
  onGroupToggleChanged,
  onItemClick,
  onItemMouseEnter,
  onItemMouseLeave,
  onItemChange,
  onModularPipelineToggleExpanded,
  focusMode,
  disabledModularPipeline,
}) => {
  return (
    <div
      className={classnames('pipeline-nodelist', {
        'pipeline-nodelist--fade': faded,
      })}
    >
      <SearchList
        onUpdateSearchValue={onUpdateSearchValue}
        searchValue={searchValue}
      />
      <SplitPanel>
        {({ isResizing, props: { container, panelA, panelB, handle } }) => (
          <div
            className={classnames('pipeline-nodelist__split', {
              'pipeline-nodelist__split--resizing': isResizing,
            })}
            {...container}
          >
            <div className="pipeline-nodelist__elements-panel" {...panelA}>
              <Scrollbars
                className="pipeline-nodelist-scrollbars"
                style={{ width: 'auto' }}
                autoHide
                hideTracksWhenNotNeeded
              >
                <div className="pipeline-nodelist-section">
                  <NodeListTree
                    modularPipelinesSearchResult={modularPipelinesSearchResult}
                    modularPipelinesTree={modularPipelinesTree}
                    searchValue={searchValue}
                    faded={faded}
                    onItemClick={onItemClick}
                    onItemMouseEnter={onItemMouseEnter}
                    onItemMouseLeave={onItemMouseLeave}
                    onItemChange={onItemChange}
                    onNodeToggleExpanded={onModularPipelineToggleExpanded}
                    focusMode={focusMode}
                    disabledModularPipeline={disabledModularPipeline}
                  />
                </div>
              </Scrollbars>
            </div>
            <div className="pipeline-nodelist__filter-panel" {...panelB}>
              <div className="pipeline-nodelist__split-handle" {...handle} />
              <Scrollbars
                className="pipeline-nodelist-scrollbars"
                style={{ width: 'auto' }}
                autoHide
                hideTracksWhenNotNeeded
              >
                <h2 className="pipeline-nodelist-section__title">Filters</h2>
                <NodeListGroups
                  items={items}
                  groups={groups}
                  searchValue={searchValue}
                  getGroupState={getGroupState}
                  onItemClick={onItemClick}
                  onItemMouseEnter={onItemMouseEnter}
                  onItemMouseLeave={onItemMouseLeave}
                  onItemChange={onItemChange}
                  onGroupToggleChanged={onGroupToggleChanged}
                />
              </Scrollbars>
            </div>
          </div>
        )}
      </SplitPanel>
    </div>
  );
};

export default NodeList;

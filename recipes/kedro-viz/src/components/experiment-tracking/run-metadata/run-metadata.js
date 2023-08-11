import React, { useCallback, useState } from 'react';
import classnames from 'classnames';
import { useOutsideClick } from '../../../utils/hooks';
import { useUpdateRunDetails } from '../../../apollo/mutations';
import { toHumanReadableTime } from '../../../utils/date-utils';
import CloseIcon from '../../icons/close';
import IconButton from '../../ui/icon-button';
import KebabIcon from '../../icons/kebab';
import SelectedPin from '../../icons/selected-pin';
import UnSelectedPin from '../../icons/un-selected-pin';
import { TransitionGroup, CSSTransition } from 'react-transition-group';
import { MetaDataLoader } from './run-metadata-loader';

import './run-metadata.css';
import './animation.css';

// Return a '-' character if the value is empty or null
const sanitiseEmptyValue = (value) => {
  return value === '' || value === null ? '-' : value;
};

const HiddenMenu = ({ isBookmarked, runId }) => {
  const [isVisible, setIsVisible] = useState(false);
  const { updateRunDetails } = useUpdateRunDetails();

  const handleClickOutside = useCallback(() => {
    setIsVisible(false);
  }, []);

  const menuRef = useOutsideClick(handleClickOutside);

  const toggleBookmark = () => {
    updateRunDetails({
      runId,
      runInput: { bookmark: !isBookmarked },
    });

    // Close the menu when the bookmark is toggled.
    setIsVisible(false);
  };

  return (
    <div
      className="hidden-menu-wrapper"
      onClick={() => setIsVisible(!isVisible)}
      ref={menuRef}
    >
      <div
        className={classnames('hidden-menu', {
          'hidden-menu--visible': isVisible,
        })}
      >
        <div
          className="hidden-menu__item"
          onClick={(e) => {
            toggleBookmark();
            e.stopPropagation();
          }}
        >
          {isBookmarked ? 'Unbookmark' : 'Bookmark'}
        </div>
      </div>
      <IconButton
        active={isVisible}
        ariaLabel="Runs menu"
        className="pipeline-menu-button--labels"
        icon={KebabIcon}
      />
    </div>
  );
};

const RunMetadata = ({
  activeTab,
  enableComparisonView,
  enableShowChanges = false,
  isSingleRun,
  onRunSelection,
  pinnedRun,
  runs = [],
  setPinnedRun,
  setRunMetadataToEdit,
  setShowRunDetailsModal,
  showLoader,
  theme,
}) => {
  let initialState = {};
  for (let i = 0; i < runs.length; i++) {
    initialState[i] = false;
  }

  const [toggleNotes, setToggleNotes] = useState(initialState);

  const onToggleNoteExpand = (index) => {
    setToggleNotes({ ...toggleNotes, [index]: !toggleNotes[index] });
  };

  const onTitleOrNoteClick = (id) => {
    const metadata = runs.find((run) => run.id === id);

    setRunMetadataToEdit(metadata);
    setShowRunDetailsModal(true);
  };

  return (
    <div
      className={classnames('details-metadata', {
        'details-metadata--not-overview': activeTab !== 'Overview',
      })}
    >
      <table
        className={classnames('details-metadata__table', {
          'details-metadata__table-comparison-view': enableComparisonView,
        })}
      >
        {runs.map((run, i) => (
          <React.Fragment key={run.id + i}>
            {i === 0 ? (
              <tbody>
                <tr
                  className={classnames(
                    'details-metadata__run',
                    'details-metadata__labels',
                    {
                      'details-metadata__labels-comparison-view':
                        enableComparisonView,
                    }
                  )}
                >
                  <td className="details-metadata__title">
                    <span
                      className="details-metadata__title-detail"
                      onClick={() => onTitleOrNoteClick(run.id)}
                      title={sanitiseEmptyValue(run.title)}
                    >
                      {sanitiseEmptyValue(run.title)}
                    </span>
                  </td>
                  {activeTab !== 'Plots' ? (
                    <>
                      <td className="details-metadata__table-label">
                        Created By
                      </td>
                      <td className="details-metadata__table-label">
                        Creation Date
                      </td>
                      <td className="details-metadata__table-label">Git SHA</td>
                      <td className="details-metadata__table-label">
                        Git Branch
                      </td>
                      <td className="details-metadata__table-label">
                        Run Command
                      </td>
                      <td className="details-metadata__table-label">Notes</td>
                    </>
                  ) : null}
                </tr>
              </tbody>
            ) : null}
          </React.Fragment>
        ))}
        <TransitionGroup
          className="details-metadata__run--wrapper"
          component={'tbody'}
        >
          {runs.map((run, i) => {
            const humanReadableTime = toHumanReadableTime(run.id);

            return (
              <CSSTransition
                classNames={'details-metadata__run-animation'}
                enter={isSingleRun ? false : true}
                exit={isSingleRun ? false : true}
                key={run.id}
                timeout={300}
              >
                <tr
                  className={classnames('details-metadata__run', {
                    'details-metadata__run--first-run': i === 0,
                    'details-metadata__run--first-run-comparison-view':
                      i === 0 && enableComparisonView,
                  })}
                >
                  <td className="details-metadata__title">
                    <div
                      className={classnames('details-metadata__indicator', {
                        'details-metadata__indicator--selected-first': i === 0,
                        'details-metadata__indicator--selected-second': i === 1,
                        'details-metadata__indicator--selected-third': i === 2,
                      })}
                    ></div>
                    <span
                      className="details-metadata__title-detail"
                      onClick={() => onTitleOrNoteClick(run.id)}
                      title={sanitiseEmptyValue(run.title)}
                    >
                      {sanitiseEmptyValue(run.title)}
                    </span>
                    <ul className="details-metadata__buttons">
                      {!isSingleRun ? (
                        <>
                          <IconButton
                            active={run.id === pinnedRun}
                            ariaLive="polite"
                            className={classnames(
                              'pipeline-menu-button--labels',
                              'pipeline-menu-button__pin',
                              {
                                'details-metadata__buttons--selected-pin':
                                  run.id === pinnedRun,
                              }
                            )}
                            icon={
                              run.id === pinnedRun ? SelectedPin : UnSelectedPin
                            }
                            labelText={
                              run.id === pinnedRun
                                ? 'Baseline'
                                : 'Make baseline'
                            }
                            labelTextPosition="bottom"
                            onClick={() => setPinnedRun(run.id)}
                            visible={enableShowChanges}
                          />
                          <IconButton
                            ariaLive="polite"
                            className="pipeline-menu-button--labels__close"
                            icon={CloseIcon}
                            labelText="Remove run"
                            labelTextPosition="bottom"
                            onClick={() => onRunSelection(run.id)}
                          />
                        </>
                      ) : null}
                      <HiddenMenu isBookmarked={run.bookmark} runId={run.id} />
                    </ul>
                  </td>
                  {activeTab !== 'Plots' ? (
                    <>
                      <td className="details-metadata__table-value">
                        {sanitiseEmptyValue(run.author)}
                      </td>
                      <td className="details-metadata__table-value">{`${humanReadableTime} (${sanitiseEmptyValue(
                        run.id
                      )})`}</td>
                      <td className="details-metadata__table-value">
                        {sanitiseEmptyValue(run.gitSha)}
                      </td>
                      <td className="details-metadata__table-value">
                        {sanitiseEmptyValue(run.gitBranch)}
                      </td>
                      <td className="details-metadata__table-value">
                        {sanitiseEmptyValue(run.runCommand)}
                      </td>
                      <td className="details-metadata__table-value">
                        <p
                          className={classnames(
                            'details-metadata__notes',
                            'details-metadata__table-label'
                          )}
                          onClick={() => onTitleOrNoteClick(run.id)}
                          style={toggleNotes[i] ? { display: 'block' } : null}
                        >
                          {run.notes !== '' ? run.notes : '- Add notes here'}
                        </p>
                        {run.notes.length > 100 ? (
                          <button
                            className="details-metadata__show-more kedro"
                            onClick={() => onToggleNoteExpand(i)}
                          >
                            {toggleNotes[i] ? 'Show less' : 'Show more'}
                          </button>
                        ) : null}
                      </td>
                    </>
                  ) : null}
                </tr>
              </CSSTransition>
            );
          })}
        </TransitionGroup>
        {showLoader && <MetaDataLoader length={runs.length} theme={theme} />}
      </table>
    </div>
  );
};

export default RunMetadata;

import React, { useEffect, useState, useContext } from 'react';
import { useUpdateRunDetails } from '../../../apollo/mutations';
import classnames from 'classnames';
import {
  getHighlightedText,
  textMatchesSearch,
} from '../../../utils/search-utils';
import { toHumanReadableTime } from '../../../utils/date-utils';
import BookmarkIcon from '../../icons/bookmark';
import BookmarkStrokeIcon from '../../icons/bookmark-stroke';
import { HoverStateContext } from '../utils/hover-state-context';

import './runs-list-card.css';

/**
 * Display a card showing run info from an experiment
 * @param {Object} data High-level data from the run (id, etc.)
 */
const RunsListCard = ({
  data,
  disableRunSelection = false,
  enableComparisonView = false,
  onRunSelection,
  selectedRunIds = [],
  searchValue,
  selectedIndex,
}) => {
  const { id, notes, title = null, bookmark, gitSha } = data;
  const [active, setActive] = useState(false);
  const { updateRunDetails } = useUpdateRunDetails();
  const humanReadableTime = toHumanReadableTime(id);

  const { setHoveredElementId, hoveredElementId } =
    useContext(HoverStateContext);

  const isMatchSearchValue = (text) =>
    searchValue ? textMatchesSearch(text, searchValue) : false;

  const displayValue = (value) =>
    isMatchSearchValue(value) ? getHighlightedText(value, searchValue) : value;

  const isSearchValueInNotes = isMatchSearchValue(notes);

  const onRunsListCardClick = (id, e) => {
    /**
     * If we click the bookmark icon or the path HTML element within the SVG,
     * then update the bookmark boolean. If we didn't check for the path, the
     * user could hit a dead zone, and nothing would happen.
     */
    if (
      e.target.classList.contains('runs-list-card__bookmark') ||
      e.target.tagName === 'path'
    ) {
      updateRunDetails({
        runId: id,
        runInput: { bookmark: !bookmark },
      });

      return;
    }

    onRunSelection(id);
  };

  useEffect(() => {
    setActive(selectedRunIds.includes(id));
  }, [id, selectedRunIds]);

  return (
    <div
      className={classnames('kedro', 'runs-list-card', {
        'runs-list-card--active': active,
        'runs-list-card--disabled': disableRunSelection && !active,
        'runs-list-card--hovered': hoveredElementId === id,
      })}
      onClick={(e) => onRunsListCardClick(id, e)}
      onMouseOver={() => setHoveredElementId(id)}
      onMouseLeave={() => setHoveredElementId(null)}
    >
      {enableComparisonView && (
        <div
          className={classnames('runs-list-card__checked', {
            'runs-list-card__checked--active': active,
            'runs-list-card__checked--comparing': enableComparisonView,
            'runs-list-card__checked--selected-first': selectedIndex === 0,
            'runs-list-card__checked--selected-second': selectedIndex === 1,
            'runs-list-card__checked--selected-third': selectedIndex === 2,
          })}
        />
      )}
      <div>
        <div
          className="runs-list-card__title"
          dangerouslySetInnerHTML={{
            __html: displayValue(title),
          }}
        />

        <div
          className="runs-list-card__gitsha"
          dangerouslySetInnerHTML={{
            __html: displayValue(gitSha),
          }}
        />
        <div className="runs-list-card__timestamp">{humanReadableTime}</div>
        {isSearchValueInNotes && (
          <div
            className="runs-list-card__notes"
            dangerouslySetInnerHTML={{
              __html: `Notes:  <em>${displayValue(notes)}</em>`,
            }}
          />
        )}
      </div>
      {bookmark ? (
        <BookmarkIcon
          className={'runs-list-card__bookmark runs-list-card__bookmark--solid'}
        />
      ) : (
        <BookmarkStrokeIcon
          className={
            'runs-list-card__bookmark runs-list-card__bookmark--stroke'
          }
        />
      )}
    </div>
  );
};

export default RunsListCard;

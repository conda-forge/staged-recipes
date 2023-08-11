import React, { memo } from 'react';
import { connect } from 'react-redux';
import classnames from 'classnames';
import { changed, replaceMatches } from '../../utils';
import NodeIcon from '../icons/node-icon';
import VisibleIcon from '../icons/visible';
import InvisibleIcon from '../icons/invisible';
import FocusModeIcon from '../icons/focus-mode';
import { getNodeActive } from '../../selectors/nodes';
import { toggleHoveredFocusMode } from '../../actions';

// The exact fixed height of a row as measured by getBoundingClientRect()
export const nodeListRowHeight = 32;

// This allows lambda and partial Python functions to render via dangerouslySetInnerHTML
const replaceTagsWithEntities = {
  '<lambda>': '&lt;lambda&gt;',
  '<partial>': '&lt;partial&gt;',
};

/**
 * Returns `true` if there are no props changes, therefore the last render can be reused.
 * Performance: Checks only the minimal set of props known to change after first render.
 */
const shouldMemo = (prevProps, nextProps) =>
  !changed(
    [
      'active',
      'checked',
      'allUnchecked',
      'disabled',
      'faded',
      'focused',
      'visible',
      'selected',
      'label',
      'children',
      'count',
    ],
    prevProps,
    nextProps
  );

const NodeListRow = memo(
  ({
    container: Container = 'div',
    active,
    checked,
    allUnchecked,
    children,
    disabled,
    faded,
    focused,
    visible,
    id,
    label,
    count,
    name,
    kind,
    onMouseEnter,
    onMouseLeave,
    onChange,
    onClick,
    selected,
    type,
    icon,
    visibleIcon = VisibleIcon,
    invisibleIcon = InvisibleIcon,
    focusModeIcon = FocusModeIcon,
    rowType,
    onToggleHoveredFocusMode,
  }) => {
    const isModularPipeline = type === 'modularPipeline';
    const FocusIcon = isModularPipeline ? focusModeIcon : null;
    const isChecked = isModularPipeline ? checked || focused : checked;
    const VisibilityIcon = isChecked ? visibleIcon : invisibleIcon;
    const isButton = onClick && kind !== 'filter';
    const TextButton = isButton ? 'button' : 'div';

    return (
      <Container
        className={classnames(
          'pipeline-nodelist__row kedro',
          `pipeline-nodelist__row--kind-${kind}`,
          {
            'pipeline-nodelist__row--visible': visible,
            'pipeline-nodelist__row--active': active,
            'pipeline-nodelist__row--selected': selected,
            'pipeline-nodelist__row--disabled': disabled,
            'pipeline-nodelist__row--unchecked': !isChecked,
            'pipeline-nodelist__row--overwrite': !(active || selected),
          }
        )}
        title={name}
        onMouseEnter={visible ? onMouseEnter : null}
        onMouseLeave={visible ? onMouseLeave : null}
      >
        {icon && (
          <NodeIcon
            className={classnames(
              'pipeline-nodelist__row__type-icon',
              'pipeline-nodelist__row__icon',
              {
                'pipeline-nodelist__row__type-icon--faded': faded,
                'pipeline-nodelist__row__type-icon--disabled': disabled,
                'pipeline-nodelist__row__type-icon--nested': !children,
                'pipeline-nodelist__row__type-icon--active': active,
                'pipeline-nodelist__row__type-icon--selected': selected,
              }
            )}
            icon={icon}
          />
        )}
        <TextButton
          className={classnames(
            'pipeline-nodelist__row__text',
            `pipeline-nodelist__row__text--kind-${kind}`,
            `pipeline-nodelist__row__text--${rowType}`
          )}
          data-heap-event={`clicked.sidebar.${icon}`}
          data-test={`node-${children ? null : name}`}
          onClick={onClick}
          onFocus={onMouseEnter}
          onBlur={onMouseLeave}
          title={children ? null : name}
        >
          <span
            className={classnames(
              'pipeline-nodelist__row__label',
              `pipeline-nodelist__row__label--kind-${kind}`,
              {
                'pipeline-nodelist__row__label--faded': faded,
                'pipeline-nodelist__row__label--disabled': disabled,
              }
            )}
            dangerouslySetInnerHTML={{
              __html: replaceMatches(label, replaceTagsWithEntities),
            }}
          />
        </TextButton>
        {typeof count === 'number' && (
          <span onClick={onClick} className={'pipeline-nodelist__row__count'}>
            {count}
          </span>
        )}
        {VisibilityIcon && (
          <label
            htmlFor={id}
            className={classnames(
              'pipeline-row__toggle',
              `pipeline-row__toggle--kind-${kind}`,
              {
                'pipeline-row__toggle--disabled': isModularPipeline
                  ? focused
                  : disabled,
                'pipeline-row__toggle--selected': selected,
              }
            )}
            onClick={(e) => e.stopPropagation()}
          >
            <input
              id={id}
              className="pipeline-nodelist__row__checkbox"
              data-heap-event={kind === `visible.${name}.${isChecked}`}
              type="checkbox"
              checked={isChecked}
              disabled={disabled}
              name={name}
              onChange={onChange}
            />
            <VisibilityIcon
              aria-label={name}
              checked={isChecked}
              className={classnames(
                'pipeline-nodelist__row__icon',
                'pipeline-row__toggle-icon',
                `pipeline-row__toggle-icon--kind-${kind}`,
                {
                  'pipeline-row__toggle-icon--parent': Boolean(children),
                  'pipeline-row__toggle-icon--child': !children,
                  'pipeline-row__toggle-icon--checked': isChecked,
                  'pipeline-row__toggle-icon--unchecked': !isChecked,
                  'pipeline-row__toggle-icon--all-unchecked': allUnchecked,
                  'pipeline-row__toggle-icon--focus-checked': isModularPipeline
                    ? false
                    : focused,
                }
              )}
            />
          </label>
        )}
        {FocusIcon && (
          <label
            htmlFor={id + '-focus'}
            className={classnames(
              'pipeline-row__toggle',
              `pipeline-row__toggle--kind-${kind}`,
              {
                'pipeline-row__toggle--disabled': disabled,
                'pipeline-row__toggle--selected': selected,
              }
            )}
            onClick={(e) => e.stopPropagation()}
            onMouseEnter={() => onToggleHoveredFocusMode(true)}
            onMouseLeave={() => onToggleHoveredFocusMode(false)}
          >
            <input
              id={id + '-focus'}
              className="pipeline-nodelist__row__checkbox"
              data-heap-event={kind === `focusMode.checked.${isChecked}`}
              type="checkbox"
              checked={isChecked}
              disabled={disabled}
              name={name}
              onChange={onChange}
              data-icon-type="focus"
            />
            <FocusIcon
              aria-label={name}
              checked={isChecked}
              className={classnames(
                'pipeline-nodelist__row__icon',
                'pipeline-row__toggle-icon',
                `pipeline-row__toggle-icon--kind-${kind}`,
                {
                  'pipeline-row__toggle-icon--parent': Boolean(children),
                  'pipeline-row__toggle-icon--child': !children,
                  'pipeline-row__toggle-icon--checked': isChecked,
                  'pipeline-row__toggle-icon--unchecked': !isChecked,
                  'pipeline-row__toggle-icon--all-unchecked': allUnchecked,
                  'pipeline-row__toggle-icon--focus-checked': focused,
                }
              )}
            />
          </label>
        )}
        {children}
      </Container>
    );
  },
  shouldMemo
);

export const mapDispatchToProps = (dispatch) => ({
  onToggleHoveredFocusMode: (active) => {
    dispatch(toggleHoveredFocusMode(active));
  },
});

export const mapStateToProps = (state, ownProps) => ({
  ...ownProps,
  active:
    typeof ownProps.active !== 'undefined'
      ? ownProps.active
      : getNodeActive(state)[ownProps.id] || false,
});

export default connect(mapStateToProps, mapDispatchToProps)(NodeListRow);

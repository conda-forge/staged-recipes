import React from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';
import handleKeyEvent from '../../../utils/key-events';
import uniqueId from 'lodash/uniqueId';
import DropdownArrow from '../../icons/dropdown-arrow';
import Button from '../button';

/**
 * Renderer for the Dropdown component
 */
const DropdownRenderer = ({
  children,
  defaultText,
  disabled,
  focusedOption,
  handleRef,
  haveSelectedValues,
  onApplyAndClose,
  onCancel,
  onLabelClicked,
  onOptionSelected,
  onSelectChanged,
  open,
  selectedOption,
  showCancelApplyBtns,
  title,
  width,
}) => {
  const wrapperClasses = classnames('kedro', 'dropdown', {
    'dropdown--open': open,
    'dropdown--disabled': disabled,
  });
  let optionIndex = 0;

  /**
   * Clone a React element and extend with extra props tieing it to a new scope
   */
  const _extendMenuOption = (element, id, index) => {
    const extraProps = {
      id,
      onSelected: onOptionSelected,
      focused: focusedOption === index,
      selected:
        selectedOption.id === id ||
        (!selectedOption.id && element.props.selected),
    };
    optionIndex += 1;

    return React.cloneElement(element, extraProps);
  };

  /**
   * Handle keyboard events
   * @param {Object} e - The key event object
   */
  const _handleKeyDown = (e) => {
    if (open) {
      handleKeyEvent(e.keyCode, {
        escape: onLabelClicked,
        up: onSelectChanged.bind(this, -1),
        down: onSelectChanged.bind(this, 1),
      });
    } else {
      handleKeyEvent(e.keyCode, {
        up: onLabelClicked,
        down: onLabelClicked,
      });
    }
    // Prevent the page from scrolling etc when using the dropdown:
    handleKeyEvent(e.keyCode)('escape, up, down', () => e.preventDefault());
  };

  const childElements = React.Children.toArray(children);
  const sectionWrapRequired =
    childElements[0] && typeof childElements[0].type === 'function';

  // create options node
  // we may have a plain array of Menu Options, in which case we'll wrap it with a section
  // an array of sections, each containing an array of Menu Options
  // sections may contain headings, which are defined as spans
  const options = React.Children.map(childElements, (child, i) => {
    switch (child.type) {
      case 'section':
        // one level of sections to iterate before we get to the Menu Options
        return (
          <section key={`menu-section-${uniqueId(i)}`}>
            {React.Children.map(child.props.children, (sectionChild, j) => {
              switch (sectionChild.type) {
                case 'span':
                  // Heading
                  return sectionChild;
                default:
                  // Menu Option
                  return _extendMenuOption(
                    sectionChild,
                    `menu-option-${i}.${j}`,
                    optionIndex
                  );
              }
            })}
          </section>
        );
      case 'span':
        // Heading
        return child;
      case 'div':
        return child;
      default:
        // Menu Option
        return _extendMenuOption(child, `menu-option-${i}`, optionIndex);
    }
  });

  const optionsNode = sectionWrapRequired ? (
    <section>{options}</section>
  ) : (
    options
  );

  return (
    <div
      aria-expanded={open.toString()}
      data-test="kedro-pipeline-selector"
      aria-haspopup="true"
      className={wrapperClasses}
      onKeyDown={_handleKeyDown}
      ref={handleRef}
      style={{ width: `${width}px` }}
      title={title}
    >
      <button
        type="button"
        disabled={disabled}
        className="dropdown__label"
        onClick={onLabelClicked}
      >
        <span>{selectedOption.label || defaultText}</span>
        <span className="dropdown__icon">
          <DropdownArrow />
        </span>
      </button>
      <div className="dropdown__options">
        {optionsNode}

        {showCancelApplyBtns && (
          <div className="select-dropdown__btn-wrapper">
            <Button mode="secondary" onClick={onCancel} size="small">
              Cancel
            </Button>
            <Button
              disabled={!haveSelectedValues}
              dataTest={'btnMetricsChange'}
              onClick={onApplyAndClose}
              mode={'primary'}
              size="small"
            >
              Apply and Close
            </Button>
          </div>
        )}
      </div>
    </div>
  );
};

DropdownRenderer.defaultProps = {
  children: null,
  defaultText: 'Please select...',
  disabled: false,
  focusedOption: null,
  handleRef: null,
  haveSelectedValues: false,
  onLabelClicked: null,
  onOptionSelected: null,
  onSelectChanged: null,
  open: false,
  selectedOption: null,
  title: null,
  width: 160,
};

DropdownRenderer.propTypes = {
  /**
   * Child items. The nodes which React will pass down, defined inside the DropdownRenderer tag.
   */
  children: PropTypes.node,
  /**
   * Default text to show in a closed unselected state
   */
  defaultText: PropTypes.string,
  /**
   * Whether to disable the dropdown
   */
  disabled: PropTypes.bool,
  /**
   * The index of the currently-focused menu option
   */
  focusedOption: PropTypes.number,
  /**
   * Retrieve a reference to the dropdown DOM node
   */
  handleRef: PropTypes.func,
  /**
   * Whether user has selected any value from the dropdown
   */
  haveSelectedValues: PropTypes.bool,
  /**
   * Callback function to be excecuted when a Apply and Close button is clicked
   */
  onApplyAndClose: PropTypes.func,
  /**
   * Callback function to be excecuted when a Cancel button is clicked
   */
  onCancel: PropTypes.func,
  /**
   * Callback to be executed when the main label is clicked
   */
  onLabelClicked: PropTypes.func,
  /**
   * Callback to be executed when an option is selected
   */
  onOptionSelected: PropTypes.func,
  /**
   * Callback to be executed when the focused option changes
   */
  onSelectChanged: PropTypes.func,
  /**
   * Whether the dropdown is in an open state
   */
  open: PropTypes.bool,
  /**
   * An object containing selected option details.
   * This will be created based on the id, primaryText, value of a selected Menu Option.
   */
  selectedOption: PropTypes.shape({
    id: PropTypes.string,
    label: PropTypes.string,
    value: PropTypes.any,
  }),

  /**
   * Title text for native tooltip
   */
  title: PropTypes.string,
  /**
   * The width for the component. Both the label and options are the same width
   */
  width: PropTypes.number,
};

export default DropdownRenderer;

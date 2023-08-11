import React from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';
import handleKeyEvent from '../../../utils/key-events';
import './menu-option.css';

/**
 * Generic Kedro Menu Option
 */
const MenuOption = ({
  className,
  focused,
  id,
  onSelected,
  primaryText,
  selected,
  value,
}) => {
  const wrapperClasses = classnames('kedro', 'menu-option', className, {
    'menu-option--focused': focused,
    'menu-option--selected': selected,
  });

  /**
   * Event handler executed when the option is selected
   * @param  {Object} e The event object
   * @return {Function}   The event handler
   */
  const _handleClicked = (e) =>
    onSelected({
      event: e,
      id,
      label: primaryText,
      value,
    });

  /**
   * Event handler executed when key events are triggered on the focused option
   * @param {Object} e - The key event object
   */
  const _handleKeyDown = (e) =>
    handleKeyEvent(e.keyCode)('enter, space', () => {
      _handleClicked(e);
      // Prevent the page from scrolling when selecting an item:
      e.preventDefault();
    });

  return (
    <div
      aria-selected={selected.toString()}
      className={wrapperClasses}
      onClick={_handleClicked}
      onKeyDown={_handleKeyDown}
      role="option"
      tabIndex="-1"
    >
      <div className="menu-option__content" title={primaryText}>
        <span>{primaryText}</span>
      </div>
    </div>
  );
};

MenuOption.defaultProps = {
  className: null,
  focused: false,
  id: null,
  onSelected: null,
  selected: false,
  value: null,
};

MenuOption.propTypes = {
  /**
   * Container class
   */
  className: PropTypes.string,
  /**
   * Whether the option is focused
   */
  focused: PropTypes.bool,
  /**
   * A unique key for this element, which will be set by the parent menu component.
   * This is used by the parent menu component to determine which option is selected.
   */
  id: PropTypes.string,
  /**
   * A callback which is automatically implemented by a parent menu component
   */
  onSelected: PropTypes.func,
  /**
   * The main label displayed
   */
  primaryText: PropTypes.string.isRequired,
  /**
   * Whether the option is selected
   */
  selected: PropTypes.bool,
  /**
   * The value to send to the parent menu component when this item is selected
   */
  value: PropTypes.any,
};

export default MenuOption;

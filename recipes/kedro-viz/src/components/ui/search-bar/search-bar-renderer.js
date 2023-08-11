import React from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';

import CloseIcon from '../../icons/close';
import SearchIcon from '../../icons/search';
import SearchInput from './search-input';

/**
 * SearchBarRenderer, used to output the actual DOM markup for the component
 */
const SearchBarRenderer = (props) => {
  const {
    children,
    isFocused,
    placeholder,
    onBlur,
    onChange,
    onClear,
    onFocus,
    onSubmit,
    theme,
    showClearButton,
    value,
  } = props;

  return (
    <form
      className={classnames('kedro', 'search-bar', `kui-theme--${theme}`, {
        'search-bar--focused': isFocused,
      })}
      onSubmit={onSubmit}
      role={children ? 'combobox' : 'search'}
    >
      <label className="search-bar__label" htmlFor="search-bar">
        Search
      </label>
      <div className="search-bar__icon-wrapper">
        <SearchIcon className="icon icon__graphics" />
      </div>
      <SearchInput
        id="search-bar"
        placeholder={placeholder}
        onChange={onChange}
        onFocus={onFocus}
        onBlur={onBlur}
        value={value}
        theme={theme}
        type="search"
      />
      <div
        className={classnames('search-bar__dynamic-icon', {
          'search-bar__dynamic-icon--visible': showClearButton,
        })}
      >
        <button
          className="icon--close"
          onBlur={onBlur}
          onClick={onClear}
          onFocus={onFocus}
        >
          <CloseIcon className="icon icon__graphics" />
        </button>
      </div>
      {children}
    </form>
  );
};

SearchBarRenderer.defaultProps = {
  children: null,
  onSubmit: null,
};

SearchBarRenderer.propTypes = {
  /**
   * Child component, usually search-bar-results
   */
  children: PropTypes.node,
  /**
   * Indicating whether the search bar is focused or blurred
   */
  isFocused: PropTypes.bool.isRequired,
  /**
   * Place holder text for search input
   */
  placeholder: PropTypes.string.isRequired,
  /**
   * On blur method, triggered by clicking outside the input
   */
  onBlur: PropTypes.func.isRequired,
  /**
   * On change method called after wait time has passed
   */
  onChange: PropTypes.func.isRequired,
  /**
   * On close method, triggered by icon click
   */
  onClear: PropTypes.func.isRequired,
  /**
   * On focus method, triggered by clicking into the input
   */
  onFocus: PropTypes.func.isRequired,
  /**
   * On submit method, triggered by hitting enter on the input
   */
  onSubmit: PropTypes.func,
  /**
   * Theme of the component
   */
  theme: PropTypes.oneOf(['light', 'dark']).isRequired,
  /**
   * Show clear button on right
   */
  showClearButton: PropTypes.bool.isRequired,
  /**
   * Text value for the input
   */
  value: PropTypes.string.isRequired,
};

export default SearchBarRenderer;

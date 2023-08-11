import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import SearchBarRenderer from './search-bar-renderer';

import './search-bar.css';

const SearchBar = ({
  children,
  onBlur,
  onChange,
  onClear,
  onFocus,
  onSubmit,
  placeholder,
  theme,
  value: inputValue,
}) => {
  const [value, setValue] = useState(inputValue);
  const [isFocused, setIsFocused] = useState(false);
  const [showClearButton, setShowClearButton] = useState(inputValue !== '');

  useEffect(() => {
    setValue(inputValue);
    setShowClearButton(inputValue !== '');
  }, [inputValue]);

  /**
   * onChange - fired for onChange events in input field
   * @param  {Event} e native change event
   */
  const _handleChanged = (e) => {
    setValue(e.target.value);
    setShowClearButton(e.target.value !== '');

    // trigger onChange prop if available
    if (typeof onChange === 'function') {
      onChange(e.target.value);
    }
  };

  /**
   * onFocus - fired for onFocus events in input field
   * @param  {Event} e native change event
   */
  const _handleFocused = (e) => {
    setIsFocused(true);

    // trigger onFocus prop if available
    if (typeof onFocus === 'function') {
      onFocus(e.target.value);
    }
  };

  /**
   * onBlurred - fired for onBlur events in input field
   * @param  {Event} e native change event
   */
  const _handleBlurred = (e) => {
    setIsFocused(false);

    // trigger onBlur prop if available
    if (typeof onBlur === 'function') {
      onBlur(e.target.value);
    }
  };

  /**
   * onClose - clear the text in the input
   */
  const _handleCleared = (event) => {
    setValue('');
    setShowClearButton(false);

    // trigger onClear prop if available
    if (typeof onClear === 'function') {
      onClear();
    }

    // trigger onChange prop if available
    if (typeof onChange === 'function') {
      onChange('');
    }

    event.preventDefault();
  };

  /**
   * Trigger onSubmit prop if available
   * @param {Object} e native change event
   */
  const _handleSubmit = (e) => {
    if (typeof onSubmit === 'function') {
      onSubmit({
        e,
        data: value,
      });
    }
  };

  return (
    <SearchBarRenderer
      onBlur={_handleBlurred}
      isFocused={isFocused}
      placeholder={placeholder}
      onChange={_handleChanged}
      onClear={_handleCleared}
      onFocus={_handleFocused}
      onSubmit={_handleSubmit}
      showClearButton={showClearButton}
      value={value}
      theme={theme}
    >
      {children}
    </SearchBarRenderer>
  );
};

SearchBar.defaultProps = {
  children: null,
  placeholder: 'Search Here...',
  onBlur: null,
  onChange: null,
  onClear: null,
  onFocus: null,
  onSubmit: null,
  theme: 'dark',
  value: '',
};

SearchBar.propTypes = {
  /**
   * Child component, usually search-bar-results
   */
  children: PropTypes.node,
  /**
   * On blur method, triggered by clicking outside the input
   */
  onBlur: PropTypes.func,
  /**
   * Subscribe to change events from input field
   */
  onChange: PropTypes.func,
  /**
   * On clear, triggered when clear button is pressed
   */
  onClear: PropTypes.func,
  /**
   * On focus method, triggered by clicking into the input
   */
  onFocus: PropTypes.func,
  /**
   * On submit method, triggered by hitting enter on the input
   */
  onSubmit: PropTypes.func,
  /**
   * Place holder text for search input
   */
  placeholder: PropTypes.string,
  /**
   * Theme of the component
   */
  theme: PropTypes.oneOf(['light', 'dark']).isRequired,
  /**
   * Value of the inner input bar
   */
  value: PropTypes.string,
};

export default SearchBar;

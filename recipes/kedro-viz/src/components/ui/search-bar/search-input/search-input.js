import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';
import 'what-input';

import './search-input.css';

const SearchInput = ({
  disabled,
  label,
  onBlur,
  onChange,
  onFocus,
  placeholder,
  theme,
  value: inputValue,
}) => {
  const [focused, setFocused] = useState(false);
  const [value, setValue] = useState(inputValue);

  useEffect(() => {
    if (inputValue !== null) {
      setValue(inputValue);
    }
  }, [inputValue]);

  const _handleFocused = (event) => {
    setFocused(true);

    if (typeof onFocus === 'function') {
      onFocus(event, { focused: true });
    }
  };

  /**
   * _handleBlurred - changes the focus to disabled state.
   */
  const _handleBlurred = (event) => {
    setFocused(false);

    if (typeof onBlur === 'function') {
      onBlur(event, { focused: false, value: event.target.value });
    }
  };

  /**
   * _handleChanged - updates the state with the value from the input and triggers the passed on change callback.
   * @param  {Object} event
   */
  const _handleChanged = (event) => {
    setValue(event.target.value);

    if (typeof onChange === 'function') {
      onChange(event, { value: event.target.value });
    }
  };

  const labelWrapper = label && (
    <div className="search-input__label">{label}</div>
  );

  return (
    <div className="kedro search-input-wrapper">
      <div
        className={classnames(
          'search-input',
          `search-theme--${theme}`,
          { 'search-input--disabled': disabled },
          { 'search-input--focused': focused }
        )}
        onFocus={_handleFocused}
        onBlur={_handleBlurred}
      >
        {labelWrapper}
        <input
          className="search-input__field"
          disabled={disabled}
          onBlur={_handleBlurred}
          onChange={_handleChanged}
          onFocus={_handleFocused}
          placeholder={placeholder || ''}
          type="text"
          value={value || ''}
        />
        <div
          aria-hidden="true"
          className="search-input__line"
          data-value={value || ''}
        />
      </div>
    </div>
  );
};

SearchInput.defaultProps = {
  disabled: false,
  label: null,
  onBlur: null,
  onChange: null,
  onFocus: null,
  placeholder: null,
  theme: 'light',
  value: null,
};

SearchInput.propTypes = {
  /**
   * Whether the input should be editable or not.
   */
  disabled: PropTypes.bool,
  /**
   * Label indicating what should be written in the input.
   */
  label: PropTypes.string,
  /**
   * Event listener which will be triggered on losing focus of the input (in other words, on blur).
   */
  onBlur: PropTypes.func,
  /**
   * Event listener which will be triggered when input will gain focus,
   */
  onFocus: PropTypes.func,
  /**
   * Event listener which will be trigerred on change of the input.
   */
  onChange: PropTypes.func,
  /**
   * Placeholder hint text which is displayed inside the input field and dissapers when something is written inside.
   */
  placeholder: PropTypes.string,
  /**
   * Theme of the input - either 'dark' or 'light'.
   */
  theme: PropTypes.oneOf(['dark', 'light']),
  /**
   * Value to be displayed inside the input field, it is editable and can change if not disabled.
   */
  value: PropTypes.string,
};

export default SearchInput;

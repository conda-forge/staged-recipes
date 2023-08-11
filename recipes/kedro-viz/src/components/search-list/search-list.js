import React, { useEffect, useRef } from 'react';
import SearchBar from '../ui/search-bar';
import { connect } from 'react-redux';
import './search-list.css';

/**
 * Handle Searching of List
 * @param {Function} onUpdateSearchValue Event handler
 * @param {String} searchValue Search text
 * @param {String} theme Light/dark theme for SearchBar component
 */
export const SearchList = ({ onUpdateSearchValue, searchValue, theme }) => {
  const container = useRef(null);

  /**
   * Focus search on CMD+F/CTRL+F, but only if not already focused, so that if
   * you hit the shortcut again you will receive the default browser behaviour
   * @param {Object} event Keydown event
   */
  const handleWindowKeyDown = (event) => {
    const isKeyF = event.key === 'f' || event.keyCode === 70;
    const isKeyCtrlOrCmd = event.ctrlKey || event.metaKey;
    if (isKeyF && isKeyCtrlOrCmd) {
      const input = container.current.querySelector('input');
      if (document.activeElement !== input) {
        input.focus();
        event.preventDefault();
      } else {
        input.blur();
      }
    }
  };

  /**
   * Add window keydown event listener on mount, and remove on unmount
   */
  useEffect(() => {
    window.addEventListener('keydown', handleWindowKeyDown);
    return () => window.removeEventListener('keydown', handleWindowKeyDown);
  });

  /**
   * Listen for keyboard events, and trigger relevant actions
   * @param {Number} keyCode The key event keycode
   */
  const handleKeyDown = (event) => {
    const isKeyEscape = event.key === 'Escape' || event.keyCode === 27;
    if (isKeyEscape) {
      onUpdateSearchValue('');
      container.current.querySelector('input').blur();
    }
  };

  return (
    <div
      className="pipeline-search-list"
      onKeyDown={handleKeyDown}
      ref={container}
    >
      <SearchBar
        onChange={onUpdateSearchValue}
        placeholder={'Search'}
        theme={theme}
        value={searchValue}
      />
    </div>
  );
};

export const mapStateToProps = (state) => ({
  theme: state.theme,
});

export default connect(mapStateToProps)(SearchList);

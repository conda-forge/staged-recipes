import React, { useCallback, useEffect, useState, useRef } from 'react';
import PropTypes from 'prop-types';
import 'what-input';
import { flatten, find, flow, isEqual, map } from 'lodash/fp';
import EventController from './event-controller.js';
import { usePrevious } from '../../../utils/hooks';
import DropdownRenderer from './dropdown-renderer';

import './dropdown.css';

const Dropdown = (props) => {
  const {
    children,
    defaultText,
    disabled,
    haveSelectedValues,
    onApplyAndClose,
    onCancel,
    onChanged,
    onClosed,
    onOpened,
    showCancelApplyBtns,
    width,
  } = props;

  /**
   * Format the selected option props for adding to state
   * @param {Object} props - Component props
   * @return {Object} Selected option object for use in the state
   */
  const _findSelectedOption = useCallback((props) => {
    const selectedOptionElement = _findSelectedOptionElement(props);

    // check children for a selected option
    if (selectedOptionElement) {
      const { id, primaryText, value } = selectedOptionElement.props;

      return {
        id,
        label: primaryText,
        value,
      };
    }

    // otherwise, default to first
    return {
      id: null,
      label: null,
      value: null,
    };
  }, []);

  /**
   * Find the selected option by traversing sections and MenuOptions
   * @param {Object} props - Component props (optional)
   * @return {Object} Selected option element
   */
  const _findSelectedOptionElement = (props) => {
    const children = React.Children.toArray(props.children);

    if (!children.length) {
      return null;
    }

    // we may have an array of options
    // or an array of sections, containing options
    if (children[0].type === 'section') {
      return flow(
        map((x) => x.props.children),
        flatten,
        find((x) => x.props.selected)
      )(children);
    }

    return find((child) => child.props.selected)(children);
  };

  const prevProps = usePrevious(props);
  const [focusedOption, setFocusedOption] = useState(null);
  const [haveClicked, setHaveClicked] = useState(false); // tracker for detecting _handleLabelClicked
  const [selectedOption, setSelectedOption] = useState(
    _findSelectedOption(props)
  );
  const [open, setOpen] = useState(false);
  const [selectedObject, setSelectedObject] = useState(null); // this is to store the object that was passed from the handleOptionSelected event handler

  const dropdownRef = useRef();
  const handleOptionSelectedRef = useRef({ open, selectedOption });
  const selectedObjRef = useRef(selectedObject);

  const mounted = useRef(false); // ref for detecting mounting of component

  useEffect(() => {
    /**
     * Check whether new props contain updated children
     * @param {Object} nextProps - New component props
     * @return {Boolean} True if new children are different from current ones
     */
    const _childrenHaveChanged = (nextProps) => {
      const children = [props, nextProps].map((props) =>
        React.Children.toArray(props.children)
      );

      return !isEqual(...children);
    };

    if (!mounted.current) {
      // update mounted on componentDidMount
      mounted.current = true;
    } else {
      // triggers every time on componentDidUpdate
      if (_childrenHaveChanged(prevProps)) {
        setSelectedOption(_findSelectedOption(prevProps));
      }
    }
  }, [_findSelectedOption, prevProps, props]);

  useEffect(() => {
    if (haveClicked === true) {
      if (typeof onOpened === 'function' && open) {
        onOpened();
      } else if (typeof onClosed === 'function' && !open) {
        onClosed();
      }

      setHaveClicked(false);
    }
  }, [haveClicked, onOpened, onClosed, open]);

  // to be fired after state changes triggered by handleOptionSelected event handler
  useEffect(() => {
    // This check is to ensure that only the changes in the handleOptionSelected event handler will trigger this effect
    if (selectedObjRef.current !== selectedObject) {
      if (
        !open &&
        handleOptionSelectedRef.current.handleOptionSelectedRef !==
          selectedOption
      ) {
        if (typeof onChanged === 'function') {
          onChanged(selectedObject);
        }
      }
      if (!open && typeof onClosed === 'function') {
        onClosed();
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedObject, selectedObjRef]);

  // Event to be fired on componentWillUnmount
  useEffect(() => {
    return () => EventController.removeBodyListeners();
  }, []);

  useEffect(() => {
    // Focus either the button label or the active option.
    // This is so screen-readers will follow the active element
    const focusClass =
      focusedOption !== null ? '.menu-option--focused' : '.dropdown__label';

    dropdownRef.current.querySelector(focusClass).focus();
  }, [focusedOption]);

  /**
   * Handler for closing a dropdown if a click occurred outside the dropdown.
   * @param {Object} e - event object
   */
  const _handleBodyClicked = (e) => {
    if (!dropdownRef.current.contains(e.target) && open) {
      _handleClose();
    }
  };

  /**
   * Event handler which is fired when the label is clicked
   */
  const _handleLabelClicked = () => {
    // remove or add the event listeners for
    if (open) {
      EventController.removeBodyListeners();
    } else {
      EventController.addBodyListener(_handleBodyClicked);
    }
    // revert the state of open
    setOpen(!open);
    // set the click tracker to true to trigger the userEffect callback
    setHaveClicked(true);

    _focusLabel();
  };

  /**
   * Sort, filter and flatten the list of children to retrieve just the MenuOptions,
   * with any Sections removed.
   * @return {Object} A flat list of MenuOptions
   */
  const _getOptionsList = () => {
    /**
     * Recurse through sections to retrieve a list of all MenuOptions
     * @param  {Object} previous The Options array as of the previous iteration
     * @param  {Object} current  The current item (either a MenuOption or Section)
     * @return {Object}          The current state of the Options array
     */
    const getSectionChildren = (previous, current) => {
      if (current.props.primaryText) {
        // MenuOption: Add to list
        return previous.concat(current);
      }
      if (current.type === 'section') {
        // Section: Keep recursing
        return previous.concat(
          current.props.children.reduce(getSectionChildren, [])
        );
      }
      return previous;
    };

    return React.Children.toArray(props.children).reduce(
      getSectionChildren,
      []
    );
  };

  /**
   * Convenience method to return focus from an option to the label.
   * This is particularly useful for screen-readers and keyboard users.
   */
  const _focusLabel = () => {
    dropdownRef.current.querySelector('.dropdown__label').focus();

    setFocusedOption(null);
  };

  /**
   * When the focused option changes (e.g. via up/down keyboard controls),
   * update the focusedOption index state and select the new one
   * @param {Number} direction - The direction that focus is travelling through the list:
   * negative is up and positive is down.
   */
  const _handleFocusChange = (direction) => {
    let newFocusedOption = focusedOption;
    const optionsLength = _getOptionsList().length;

    if (focusedOption === null) {
      newFocusedOption = direction > 0 ? 0 : optionsLength - 1;
    } else {
      newFocusedOption += direction;
    }
    if (newFocusedOption >= optionsLength || newFocusedOption < 0) {
      newFocusedOption = null;
    }

    setFocusedOption(newFocusedOption);
  };

  /**
   * Event handler which is fired when a child item is selected
   */
  const _handleOptionSelected = (obj) => {
    const { label, id, value } = obj;

    setSelectedObject(obj);

    // detect if the selected item has changed
    const hasChanged = value !== selectedOption.value;
    if (hasChanged) {
      const newSelectedOption = { label, value, id };

      setOpen(false);
      setSelectedOption(newSelectedOption);
    } else {
      setOpen(false);
    }
    _focusLabel();
  };

  /**
   * Retrieve a reference to the dropdown DOM node (from the renderer component),
   * and assign it to a class-wide variable property.
   * @param {Object} el - The ref for the Dropdown container node
   */
  const _handleRef = (el) => {
    dropdownRef.current = el;
  };

  /**
   * API method to close the dropdown
   */
  const _handleClose = () => {
    setOpen(false);

    // remove event listener
    EventController.removeBodyListeners();
  };

  return (
    <DropdownRenderer
      defaultText={defaultText}
      disabled={disabled}
      focusedOption={focusedOption}
      handleRef={_handleRef}
      haveSelectedValues={haveSelectedValues}
      onApplyAndClose={() => {
        setOpen(false);
        onApplyAndClose();
      }}
      onCancel={() => {
        setOpen(false);
        onCancel();
      }}
      onLabelClicked={_handleLabelClicked}
      onOptionSelected={_handleOptionSelected}
      onSelectChanged={_handleFocusChange}
      open={open}
      selectedOption={selectedOption}
      showCancelApplyBtns={showCancelApplyBtns}
      width={width}
    >
      {children}
    </DropdownRenderer>
  );
};

Dropdown.defaultProps = {
  children: null,
  defaultText: 'Please select...',
  disabled: false,
  haveSelectedValues: false,
  onChanged: null,
  onClosed: null,
  onOpened: null,
  width: 160,
};

Dropdown.propTypes = {
  /**
   * Child items. The nodes which React will pass down, defined inside the DropdownRenderer tag
   */
  children: PropTypes.node.isRequired,
  /**
   * Default text to show in a closed unselected state
   */
  defaultText: PropTypes.string,
  /**
   * Whether to disable the dropdown
   */
  disabled: PropTypes.bool,
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
   * Callback function to be executed when a menu item is clicked, other than the one currently selected.
   */
  onChanged: PropTypes.func,
  /**
   * Callback to be executed after menu opens
   */
  onOpened: PropTypes.func,
  /**
   * Callback to be executed after menu closed
   */
  onClosed: PropTypes.func,
  /**
   * The width for the component. Both the label and options are the same width
   */
  width: PropTypes.number,
};

export default Dropdown;

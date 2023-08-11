import React from 'react';
import classnames from 'classnames';
import modifiers from '../../../utils/modifiers';
import './toggle.css';

/**
 * Shows a toggle button for code panel
 */
const Toggle = ({
  id = '',
  checked,
  enabled = true,
  title,
  onChange,
  className = '',
}) => (
  <div
    className={modifiers(classnames('pipeline-toggle', className), {
      enabled,
    })}
  >
    <input
      id={`pipeline-toggle-input-${id}`}
      data-test={`pipeline-toggle-input-${id}`}
      className="pipeline-toggle-input"
      type="checkbox"
      data-heap-event={`visible.code.${checked}`}
      checked={checked}
      disabled={!enabled}
      onChange={onChange}
    />
    <label
      className={modifiers('pipeline-toggle-label', {
        checked: enabled && checked,
      })}
      htmlFor={`pipeline-toggle-input-${id}`}
    >
      {title}
    </label>
  </div>
);

export default Toggle;

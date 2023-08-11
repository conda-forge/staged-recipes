import React from 'react';
import Toggle from '../ui/toggle';

/**
 * Shows a list of MetaDataValue
 */
const SettingsModalRow = ({
  id,
  name,
  toggleValue,
  description,
  onToggleChange,
}) => (
  <div className="pipeline-settings-modal__column" key={id}>
    <div className="pipeline-settings-modal__name">{name}</div>
    <Toggle
      id={id}
      className="pipeline-settings-modal__state"
      title={toggleValue ? 'On' : 'Off'}
      checked={toggleValue}
      onChange={onToggleChange}
    ></Toggle>
    <div className="pipeline-settings-modal__description">{description}</div>
  </div>
);

export default SettingsModalRow;

import React, { useState, useEffect } from 'react';
import classnames from 'classnames';

import './switch.css';

const Switch = ({ defaultChecked = false, onChange }) => {
  const [checked, setChecked] = useState(defaultChecked);

  useEffect(() => {
    setChecked(defaultChecked);
  }, [defaultChecked]);

  const onClick = () => {
    setChecked(!checked);
    onChange && onChange();
  };

  return (
    <div className="switch" onClick={onClick}>
      <span className="switch__label">{checked ? 'On' : 'Off'}</span>
      <div className="switch__root">
        <div
          className={classnames('switch__base', {
            'switch__base--active': checked,
          })}
        >
          <input
            className="switch__input"
            defaultChecked={checked}
            type="checkbox"
          />
          <div className="switch__circle"></div>
        </div>
        <div className="switch__track"></div>
      </div>
    </div>
  );
};

export default Switch;

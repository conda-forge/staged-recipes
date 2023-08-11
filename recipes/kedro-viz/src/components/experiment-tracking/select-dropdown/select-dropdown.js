import React, { useState, useEffect, useCallback } from 'react';

import Dropdown from '../../ui/dropdown';

import './select-dropdown.css';

const CheckboxOption = ({ text, selectedValues, onChange }) => {
  return (
    <label className="select-dropdown__checkbox">
      <span className="select-dropdown__checkbox-text" title={text}>
        {text}
      </span>
      <input
        checked={selectedValues && selectedValues.includes(text)}
        id={text}
        onChange={() => onChange(text)}
        type="checkbox"
      />
    </label>
  );
};

const SelectDropdown = ({
  dropdownValues,
  onChange,
  selectedDropdownValues,
}) => {
  const [selected, setSelected] = useState(selectedDropdownValues);
  const [haveSelectedValues, setHaveSelectedValues] = useState(false);

  useEffect(() => {
    if (selectedDropdownValues) {
      setSelected(selectedDropdownValues);
    }
  }, [selectedDropdownValues]);

  const onSelectedHandler = useCallback(
    (value) => {
      setHaveSelectedValues(true);

      if (selected.includes(value)) {
        setSelected(selected.filter((each) => each !== value));
      } else {
        setSelected([...selected, value]);
      }
    },
    [selected]
  );

  return (
    <div className="select-dropdown">
      <Dropdown
        onClosed={() => {
          setSelected(selectedDropdownValues);
          setHaveSelectedValues(false);
        }}
        showCancelApplyBtns
        onApplyAndClose={() => {
          onChange(selected);
          setHaveSelectedValues(false);
        }}
        onCancel={() => {
          setSelected(selectedDropdownValues);
          setHaveSelectedValues(false);
        }}
        haveSelectedValues={haveSelectedValues}
        defaultText={`Metrics ${selected ? selected.length : 0}/${
          dropdownValues ? dropdownValues.length : 0
        }`}
      >
        <div className="select-dropdown__title">Metrics</div>
        {dropdownValues &&
          dropdownValues.map((text, i) => (
            <CheckboxOption
              key={text + i}
              onChange={onSelectedHandler}
              selectedValues={selected}
              text={text}
            />
          ))}
      </Dropdown>
    </div>
  );
};

export default SelectDropdown;

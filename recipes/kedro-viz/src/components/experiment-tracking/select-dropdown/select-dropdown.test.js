import React from 'react';
import sinon from 'sinon';
import { shallow, mount } from 'enzyme';
import SelectDropdown from '.';

const mockData = {
  dropdownValues: [1, 2, 3, 4, 5],
  onChange: sinon.spy(() => {}),
  selectedDropdownValues: [1, 2, 3],
};

describe('SelectDropdown', () => {
  it('renders without crashing', () => {
    const wrapper = shallow(
      <SelectDropdown
        dropdownValues={mockData.dropdownValues}
        onChange={mockData.onChange}
        selectedDropdownValues={mockData.selectedDropdownValues}
      />
    );

    expect(wrapper.find('.select-dropdown').length).toBe(1);
  });

  it('renders the correct amount of checkbox', () => {
    const wrapper = mount(
      <SelectDropdown
        dropdownValues={mockData.dropdownValues}
        onChange={mockData.onChange}
        selectedDropdownValues={mockData.selectedDropdownValues}
      />
    );

    expect(wrapper.find('.select-dropdown__checkbox').length).toBe(
      mockData.dropdownValues.length
    );
  });

  it('renders the correct text', () => {
    const wrapper = mount(
      <SelectDropdown
        dropdownValues={mockData.dropdownValues}
        onChange={mockData.onChange}
        selectedDropdownValues={mockData.selectedDropdownValues}
      />
    );

    expect(wrapper.find('.dropdown__label').text()).toEqual(
      `Metrics ${mockData.selectedDropdownValues.length}/${mockData.dropdownValues.length}`
    );
  });
});

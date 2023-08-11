import React from 'react';
import { shallow } from 'enzyme';
import SearchBarRenderer from './search-bar-renderer';

test('SearchBarRenderer should be a function', () => {
  expect(typeof SearchBarRenderer).toBe('function');
});

test('SearchBarRenderer should render correct structure', () => {
  const wrapper = shallow(
    <SearchBarRenderer
      placeholder="hello world"
      isFocused={true}
      onBlur={() => {}}
      onChange={() => {}}
      onClear={() => {}}
      onFocus={() => {}}
      showClearButton={true}
      theme="dark"
      value="hello world"
    />
  );

  expect(wrapper.find('SearchIcon')).toHaveLength(1);
  expect(wrapper.find('CloseIcon')).toHaveLength(1);
});

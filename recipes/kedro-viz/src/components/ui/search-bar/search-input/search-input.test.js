import React from 'react';
import { shallow, configure, mount } from 'enzyme';
import Adapter from '@wojtekmaj/enzyme-adapter-react-17';

import SearchInput from './search-input';

configure({ adapter: new Adapter() });

test('SearchInput should be a function', () => {
  expect(typeof SearchInput).toBe('function');
});

test('SearchInput should include only one input field', () => {
  const wrapper = shallow(<SearchInput />);

  expect(wrapper.find('input').length === 1).toBeTruthy();
});

test('SearchInput should correctly render the value', () => {
  const valueText = 'Value of input!';
  const wrapper = shallow(<SearchInput value={valueText} />);

  wrapper.find('input').html().includes(`value="${valueText}"`);
});

test('SearchInput should correctly be disabled', () => {
  const wrapper = shallow(<SearchInput disabled={true} />);

  wrapper.find('input').html().includes('disabled');
});

test('SearchInput should correctly have light theme class', () => {
  const wrapper = shallow(<SearchInput theme="light" />);

  expect(wrapper.find('.search-theme--light').length === 1).toBeTruthy();
});

test('SearchInput should correctly have dark theme class', () => {
  // dark theme is default, so it should be automatically assigned
  const wrapper = shallow(<SearchInput theme="dark" />);

  expect(wrapper.find('.search-theme--dark').length === 1).toBeTruthy();
});

test('It should trigger onFocus correctly', () => {
  const callback = jest.fn();

  const wrapper = mount(<SearchInput onFocus={callback} />);

  wrapper.find('input').simulate('focus');

  expect(callback).toHaveBeenCalled();
  expect(wrapper.find('.search-input').hasClass('search-input--focused'));
});

test('It should trigger onBlur correctly', () => {
  const callback = jest.fn();

  const wrapper = mount(<SearchInput onBlur={callback} />);

  wrapper.find('input').simulate('blur');

  expect(callback).toHaveBeenCalled();
});

test('It should trigger onChange correctly', () => {
  const callback = jest.fn();

  const wrapper = mount(<SearchInput onChange={callback} />);
  const event = { target: { name: 'TestName', value: 'new value' } };

  wrapper.find('input').simulate('change', event);

  expect(callback).toHaveBeenCalled();
  expect(wrapper.find('.search-input__field').props().value).toEqual(
    'new value'
  );
});

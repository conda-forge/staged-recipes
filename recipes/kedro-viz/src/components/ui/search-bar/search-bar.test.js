import React from 'react';
import { shallow, configure } from 'enzyme';
import Adapter from '@wojtekmaj/enzyme-adapter-react-17';
import SearchBar from './search-bar';

configure({ adapter: new Adapter() });

// check the type of the component
test('SearchBar should be a function', () => {
  expect(typeof SearchBar).toBe('function');
});

// should render correctly
test('SearchBar should render correctly', () => {
  const wrapper = shallow(<SearchBar />);

  expect(typeof wrapper.props().onChange).toBe('function');
  expect(typeof wrapper.props().onClear).toBe('function');
});

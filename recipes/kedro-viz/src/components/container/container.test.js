import React from 'react';
import { mount } from 'enzyme';
import Container from './index';

describe('Container', () => {
  it('renders without crashing', () => {
    const wrapper = mount(<Container />);
    expect(wrapper.find('App')).toHaveLength(1);
  });
});

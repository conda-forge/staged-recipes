import React from 'react';
import Switch from './switch';
import Adapter from '@wojtekmaj/enzyme-adapter-react-17';
import { configure, mount, shallow } from 'enzyme';

configure({ adapter: new Adapter() });

describe('RunsListCard', () => {
  it('renders without crashing', () => {
    const wrapper = shallow(<Switch />);

    expect(wrapper.find('.switch').length).toBe(1);
  });

  it('renders with a default checked option', () => {
    const wrapper = shallow(<Switch defaultChecked />);

    expect(wrapper.find('.switch__base--active').length).toBe(1);
  });

  it('calls a function on click and adds an active class', () => {
    const setChecked = jest.fn();
    const wrapper = mount(<Switch />);
    const onClick = jest.spyOn(React, 'useState');

    onClick.mockImplementation((checked) => [checked, setChecked]);
    wrapper.simulate('click');
    expect(setChecked).toBeTruthy();
    expect(wrapper.find('.switch__base--active').length).toBe(1);
  });
});

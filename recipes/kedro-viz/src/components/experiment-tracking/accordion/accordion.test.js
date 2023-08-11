import React from 'react';
import Accordion from '.';
import Adapter from '@wojtekmaj/enzyme-adapter-react-17';
import { configure, mount, shallow } from 'enzyme';

configure({ adapter: new Adapter() });

jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useLocation: () => ({
    pathname: 'localhost:3000/',
  }),
}));

describe('Accordion', () => {
  it('renders without crashing', () => {
    const wrapper = shallow(
      <Accordion heading="Title here">
        <div className="child">1</div>
        <div className="child">2</div>
      </Accordion>
    );

    expect(wrapper.find('.accordion').length).toBe(1);
    expect(wrapper.find('.accordion__title').length).toBe(1);
    expect(wrapper.find('.child').length).toBe(2);
  });

  it('renders the toggle button on the left', () => {
    const wrapper = shallow(
      <Accordion heading="Title here" layout="left">
        <div className="child">1</div>
        <div className="child">2</div>
      </Accordion>
    );

    expect(
      wrapper.find(
        '.accordion__heading > .accordion__toggle + .accordion__title'
      ).length
    ).toBe(1);
  });

  it('renders the toggle button on the right', () => {
    const wrapper = shallow(
      <Accordion heading="Title here" layout="right">
        <div className="child">1</div>
        <div className="child">2</div>
      </Accordion>
    );

    expect(
      wrapper.find(
        '.accordion__heading > .accordion__title + .accordion__toggle'
      ).length
    ).toBe(1);
  });

  it('handles collapsing the accordion with a prop', () => {
    const wrapper = shallow(
      <Accordion heading="Title here" isCollapsed>
        <div className="child">1</div>
        <div className="child">2</div>
      </Accordion>
    );

    expect(wrapper.find('.accordion__content--hide').length).toBe(1);
  });

  it('handles collapse button click event', () => {
    const setCollapsed = jest.fn();
    const wrapper = mount(
      <Accordion>
        <div className="child">1</div>
        <div className="child">2</div>
      </Accordion>
    );
    const onClick = jest.spyOn(React, 'useState');

    onClick.mockImplementation((collapsed) => [collapsed, setCollapsed]);
    wrapper.find('.accordion__toggle').simulate('click');
    expect(setCollapsed).toBeTruthy();
    expect(wrapper.find('.accordion__content--hide').length).toBe(1);
  });
});

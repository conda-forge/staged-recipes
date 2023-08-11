import React from 'react';
import sinon from 'sinon';
import { shallow } from 'enzyme';
import Dropdown from './dropdown';
import MenuOption from '../menu-option';

const mockData = [
  {
    defaultText: 'Test 123',
    onOpened: sinon.spy(() => {}),
    onClosed: sinon.spy(() => {}),
    onChanged: sinon.spy(() => {}),
  },
  {
    defaultText: 'Test 456',
    onOpened: sinon.spy(() => {}),
    onClosed: sinon.spy(() => {}),
    onChanged: sinon.spy(() => {}),
  },
];

mockData.forEach((dataSet, i) => {
  const jsx = (
    <Dropdown {...dataSet}>
      <MenuOption key={1} primaryText="Menu Item One" value={1} />
      <MenuOption key={2} primaryText="Menu Item Two" value={2} />
      <MenuOption key={3} primaryText="Menu Item Three" value={3} />
    </Dropdown>
  );
  describe(`Dropdown - Test ${i}`, () => {
    it('should be a function', () => {
      expect(typeof Dropdown).toBe('function');
    });

    it('should create a valid React Component when called with required props', () => {
      const wrapper = shallow(jsx);
      expect(wrapper.children().length === 3).toBeTruthy();
    });
  });
});

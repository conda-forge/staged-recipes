import React from 'react';
import { setup } from '../../../utils/state.mock';
import sinon from 'sinon';
import MenuOption from '.';

const mockData = [
  {
    primaryText: 'Test 123',
    onSelected: sinon.spy(() => {}),
  },
  {
    primaryText: 'Test 456',
    onSelected: sinon.spy(() => {}),
  },
];

mockData.forEach((dataSet, i) => {
  const jsx = <MenuOption {...dataSet} />;

  describe(`Menu Option - Test ${i}`, () => {
    it('should be a function', () => {
      expect(typeof MenuOption).toBe('function');
    });

    it('should contain text', () => {
      const wrapper = setup.mount(jsx);
      expect(
        wrapper.find('.menu-option__content').text() === dataSet.primaryText
      ).toBeTruthy();

      expect(
        wrapper.find(`.menu-option__content[title="${dataSet.primaryText}"]`)
          .length === 1
      ).toBeTruthy();
    });

    if (typeof dataSet.onSelected === 'function') {
      it('should fire onSelected event handler when clicked', () => {
        const wrapper = setup.mount(jsx);
        wrapper.simulate('click');
        expect(dataSet.onSelected.called).toBeTruthy();
      });
    }
  });
});

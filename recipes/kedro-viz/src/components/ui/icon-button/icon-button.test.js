import React from 'react';
import { mount } from 'enzyme';
import { act } from '@testing-library/react';
import IconButton from '.';
import { setup } from '../../../utils/state.mock';
import MenuIcon from '../../icons/menu';

describe('IconButton', () => {
  it('renders without crashing', () => {
    const wrapper = setup.shallow(IconButton, {
      ariaLive: 'polite',
      ariaLabel: `Change theme`,
      onClick: () => {},
      icon: MenuIcon,
      labelText: 'Toggle theme',
      visible: true,
    });
    expect(wrapper.find('Wrapper').length).toBe(1);
    expect(wrapper.find('.pipeline-icon-toolbar__button').length).toBe(1);
  });

  it('calls a function on click', () => {
    const onClick = jest.fn();
    const wrapper = setup.shallow(IconButton, { onClick });
    expect(onClick.mock.calls.length).toBe(0);
    wrapper.find('button').simulate('click');
    expect(onClick.mock.calls.length).toBe(1);
  });

  it('hides when visibility is false', () => {
    const wrapper = setup.shallow(IconButton, { visible: false });
    expect(wrapper.find('li').length).toBe(0);
    expect(wrapper.find('.pipeline-icon-toolbar__button').length).toBe(0);
  });

  it('when passing a value for labelText without specifically defined labelTextPosition, the default value for labelTextPosition should be "right"', () => {
    const wrapper = setup.shallow(IconButton, {
      labelText: 'Toggle theme',
      visible: true,
    });

    expect(wrapper.find('.pipeline-toolbar__label-right').length).toBe(1);
  });

  it('classnames of the tooltip should reflect the value of labelTextPosition', () => {
    const wrapper = setup.shallow(IconButton, {
      labelText: 'Toggle theme',
      labelTextPosition: 'bottom',
      visible: true,
    });

    expect(wrapper.find('.pipeline-toolbar__label-bottom').length).toBe(1);
  });

  it('when passing the wrong value for labelTextPosition, it should return back to the default value "right"', () => {
    const wrapper = setup.shallow(IconButton, {
      labelText: 'Toggle theme',
      labelTextPosition: 'random position',
      visible: true,
    });

    expect(wrapper.find('.pipeline-toolbar__label-right').length).toBe(1);
  });

  it('show tooltip', () => {
    jest.useFakeTimers();
    const setIsTooltipVisible = jest.fn();
    const wrapper = mount(
      <IconButton
        labelText="Toggle theme"
        labelTextPosition="randon position"
        visible
      />
    );

    const onHover = jest.spyOn(React, 'useState');
    const button = wrapper.find('.pipeline-icon-toolbar__button');

    onHover.mockImplementation((isTooltipVisible) => [
      isTooltipVisible,
      setIsTooltipVisible,
    ]);
    button.simulate('mouseenter');
    act(() => jest.runOnlyPendingTimers());
    wrapper.update();
    expect(wrapper.find('.pipeline-toolbar__label__visible').length).toBe(1);
  });

  it('hide tooltip', () => {
    const setIsTooltipVisible = jest.fn();
    const wrapper = mount(
      <IconButton
        labelText="Toggle theme"
        labelTextPosition="randon position"
        visible
      />
    );
    const onHover = jest.spyOn(React, 'useState');
    const button = wrapper.find('.pipeline-icon-toolbar__button');

    onHover.mockImplementation((isTooltipVisible) => [
      isTooltipVisible,
      setIsTooltipVisible,
    ]);
    button.simulate('mouseleave');
    expect(wrapper.find('.pipeline-toolbar__label__visible').length).toBe(0);
  });
});

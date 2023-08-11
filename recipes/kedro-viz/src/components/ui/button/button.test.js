import React from 'react';
import sinon from 'sinon';
import Button from './button';
import { setup } from '../../../utils/state.mock';

describe('Button', () => {
  it('should be a function', () => {
    expect(typeof Button).toBe('function');
  });

  it(' should include only one button field', () => {
    const wrapper = setup.mount(<Button />);

    expect(wrapper.find('button').length === 1).toBeTruthy();
  });

  it('should correctly render its text value', () => {
    const text = 'I am a button!';
    const wrapper = setup.mount(<Button>{text}</Button>);

    expect(wrapper.find('button').text()).toBe(text);
  });

  it('should handle click events', () => {
    const onClick = sinon.spy();
    const wrapper = setup.mount(<Button onClick={onClick} />);

    wrapper.find('button').simulate('click');

    expect(onClick.callCount).toBe(1);
  });

  it('should handle submit events in form', () => {
    const onSubmit = sinon.spy();
    const wrapper = setup.mount(
      <form onSubmit={onSubmit}>
        <Button type="submit" />
      </form>
    );

    wrapper.find('button').simulate('submit');

    expect(onSubmit.callCount).toBe(1);
  });
});

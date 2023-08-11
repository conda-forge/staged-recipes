import React from 'react';
import Toggle from './toggle';
import { setup } from '../../../utils/state.mock';

describe('Toggle', () => {
  const input = (wrapper) => wrapper.find('.pipeline-toggle-input');
  const label = (wrapper) => wrapper.find('.pipeline-toggle-label');

  it('is checked when checked is true', () => {
    const wrapper = setup.mount(
      <Toggle checked={true} onChange={jest.fn()}></Toggle>
    );
    expect(input(wrapper).prop('checked')).toBe(true);
    expect(label(wrapper).hasClass('pipeline-toggle-label--checked')).toBe(
      true
    );
  });

  it('is not checked when checked is false', () => {
    const wrapper = setup.mount(
      <Toggle checked={false} onChange={jest.fn()}></Toggle>
    );
    expect(input(wrapper).prop('checked')).toBe(false);
    expect(label(wrapper).hasClass('pipeline-toggle-label--checked')).toBe(
      false
    );
  });

  it('is disabled when enabled is false', () => {
    const wrapper = setup.mount(
      <Toggle checked={true} enabled={false} onChange={jest.fn()} />
    );
    expect(input(wrapper).prop('disabled')).toBe(true);
  });

  it('is not disabled when enabled is true', () => {
    const wrapper = setup.mount(
      <Toggle checked={true} enabled={true} onChange={jest.fn()} />
    );
    expect(input(wrapper).prop('disabled')).toBe(false);
  });

  it('onChange callback fires when input changed', () => {
    const wrapper = setup.mount(
      <Toggle checked={true} enabled={true} onChange={jest.fn()} />
    );

    expect(input(wrapper).prop('checked')).toBe(true);

    // Simulate user changing the input (directly as Enzyme doesn't support it)
    input(wrapper).prop('onChange')();

    expect(wrapper.find(Toggle).prop('onChange')).toHaveBeenCalled();
  });
});

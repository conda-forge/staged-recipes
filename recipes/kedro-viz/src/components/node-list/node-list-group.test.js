import React from 'react';
import { NodeListGroup } from './node-list-group';
import { getNodeTypes } from '../../selectors/node-types';
import { setup, mockState } from '../../utils/state.mock';

describe('NodeListGroup', () => {
  const items = [];

  it('renders without throwing', () => {
    const type = getNodeTypes(mockState.spaceflights)[0];
    expect(() =>
      setup.mount(<NodeListGroup id={type.id} name={type.name} items={items} />)
    ).not.toThrow();
  });

  it('handles checkbox change events', () => {
    const type = getNodeTypes(mockState.spaceflights)[0];
    const onToggleChecked = jest.fn();
    const wrapper = setup.mount(
      <NodeListGroup
        id={type.id}
        name={type.name}
        onToggleChecked={onToggleChecked}
        items={items}
      />
    );
    const checkbox = () => wrapper.find('input');
    checkbox().simulate('change', { target: { checked: false } });
    expect(onToggleChecked.mock.calls.length).toEqual(1);
  });

  it('handles collapse button click events', () => {
    const type = getNodeTypes(mockState.spaceflights)[0];
    const onToggleCollapsed = jest.fn();
    const wrapper = setup.mount(
      <NodeListGroup
        id={type.id}
        name={type.name}
        onToggleCollapsed={onToggleCollapsed}
        items={items}
      />
    );
    wrapper.find('.pipeline-type-group-toggle').simulate('click');
    expect(() => onToggleCollapsed.mock.calls.length.toEqual(1)).toThrow();
  });

  it('adds class when collapsed prop true', () => {
    const type = getNodeTypes(mockState.spaceflights)[0];
    const wrapper = setup.mount(
      <NodeListGroup
        id={type.id}
        name={type.name}
        collapsed={true}
        items={items}
      />
    );
    const children = wrapper.find('.pipeline-nodelist__children');
    expect(children.hasClass('pipeline-nodelist__children--closed')).toBe(true);
  });

  it('removes class when collapsed prop false', () => {
    const type = getNodeTypes(mockState.spaceflights)[0];
    const wrapper = setup.mount(
      <NodeListGroup
        id={type.id}
        name={type.name}
        collapsed={false}
        items={items}
      />
    );
    const children = wrapper.find('.pipeline-nodelist__children');
    expect(children.hasClass('pipeline-nodelist__children--closed')).toBe(
      false
    );
  });

  it('adds disabled class when items list is empty', () => {
    const type = getNodeTypes(mockState.spaceflights)[0];
    const wrapper = setup.mount(
      <NodeListGroup id={type.id} name={type.name} items={items} />
    );
    expect(items.length).toBe(0);
    const button = () => wrapper.find('button');
    expect(button().hasClass('pipeline-type-group-toggle--disabled')).toBe(
      true
    );
  });
});

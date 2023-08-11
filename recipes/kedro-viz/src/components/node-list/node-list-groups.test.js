import React from 'react';
import NodeListGroups from './node-list-groups';
import { mockState, setup } from '../../utils/state.mock';
import { getNodeTypes } from '../../selectors/node-types';
import { getGroupedNodes } from '../../selectors/nodes';
import { getGroups } from './node-list-items';

describe('NodeListGroups', () => {
  const mockProps = () => {
    const items = getGroupedNodes(mockState.spaceflights);
    const nodeTypes = getNodeTypes(mockState.spaceflights);
    const groups = getGroups({ nodeTypes, items });
    return { items, groups };
  };

  it('renders without throwing', () => {
    expect(() =>
      setup.mount(<NodeListGroups {...mockProps()} />)
    ).not.toThrow();
  });

  it('handles collapse button click events', () => {
    const wrapper = setup.mount(<NodeListGroups {...mockProps()} />);
    const nodeList = () =>
      wrapper.find('.pipeline-nodelist__list--nested').first();
    const toggle = () => wrapper.find('.pipeline-type-group-toggle').first();
    expect(nodeList().length).toBe(1);
    expect(toggle().hasClass('pipeline-type-group-toggle--alt')).toBe(false);
    expect(() => {
      toggle().hasClass('pipeline-type-group-toggle--disabled').toBe(false);
      toggle().simulate('click');
      expect(nodeList().length).toBe(1);
      expect(toggle().hasClass('pipeline-type-group-toggle--alt')).toBe(true);
    }).toThrow();
  });

  it('handles group checkbox change events', () => {
    const onGroupToggleChanged = jest.fn();
    const wrapper = setup.mount(
      <NodeListGroups
        {...mockProps()}
        onGroupToggleChanged={onGroupToggleChanged}
      />
    );
    const checkbox = () => wrapper.find('input').first();
    checkbox().simulate('change', { target: { checked: false } });
    expect(onGroupToggleChanged.mock.calls.length).toEqual(1);
  });
});

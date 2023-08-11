import React from 'react';
import PipelineList, {
  mapStateToProps,
  mapDispatchToProps,
} from './pipeline-list';
import { mockState, setup } from '../../utils/state.mock';

const mockHistoryPush = jest.fn();

jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useHistory: () => ({
    push: mockHistoryPush,
  }),
}));

describe('PipelineList', () => {
  const pipelineIDs = mockState.spaceflights.pipeline.ids.map((id, i) => [
    id,
    i,
  ]);

  it('renders without crashing', () => {
    const wrapper = setup.mount(<PipelineList onToggleOpen={jest.fn()} />);
    const container = wrapper.find('.pipeline-list');
    expect(container.length).toBe(1);
  });

  it('should call onToggleOpen when opening/closing', () => {
    const onToggleOpen = jest.fn();
    const wrapper = setup.mount(<PipelineList onToggleOpen={onToggleOpen} />);
    wrapper.find('.dropdown__label').simulate('click');
    expect(onToggleOpen).toHaveBeenLastCalledWith(true);
    wrapper.find('.dropdown__label').simulate('click');
    expect(onToggleOpen).toHaveBeenLastCalledWith(false);
  });

  it('should be disabled when there are no pipelines in the store', () => {
    const wrapper = setup.mount(<PipelineList />, { data: 'json' });
    expect(wrapper.find('.dropdown__label').prop('disabled')).toBe(true);
  });

  test.each(pipelineIDs)(
    'should change the active pipeline to %s on clicking menu option %s, and the URL should be set to "/" ',
    (id, i) => {
      const wrapper = setup.mount(<PipelineList onToggleOpen={jest.fn()} />);
      wrapper.find('MenuOption').at(i).simulate('click');

      expect(wrapper.find('PipelineList').props().pipeline.active).toBe(id);
      expect(mockHistoryPush).toHaveBeenCalledWith(`/?pipeline_id=${id}`);
    }
  );

  it('should apply an active class to an active pipeline row', () => {
    const wrapper = setup.mount(<PipelineList />);
    const { active, ids } = wrapper.find('PipelineList').props().pipeline;
    const hasClass = wrapper
      .find('MenuOption')
      .at(ids.indexOf(active))
      .hasClass('pipeline-list__option--active');
    expect(hasClass).toBe(true);
  });

  it('should not apply an active class to an inactive pipeline row', () => {
    const wrapper = setup.mount(<PipelineList />);
    const { active, ids } = wrapper.find('PipelineList').props().pipeline;
    const hasClass = wrapper
      .find('MenuOption')
      .at(ids.findIndex((id) => id !== active))
      .hasClass('pipeline-list__option--active');
    expect(hasClass).toBe(false);
  });

  it('maps state to props', () => {
    expect(mapStateToProps(mockState.spaceflights)).toEqual({
      asyncDataSource: expect.any(Boolean),
      pipeline: {
        active: expect.any(String),
        main: expect.any(String),
        name: expect.any(Object),
        ids: expect.any(Array),
      },
      isPrettyName: expect.any(Boolean),
    });
  });

  it('maps dispatch to props', async () => {
    const dispatch = jest.fn();
    mapDispatchToProps(dispatch).onUpdateActivePipeline({ value: '123' });
    // The calls would also include the action to reset focus mode
    expect(dispatch.mock.calls.length).toEqual(2);
    // ensure that the action to reset focus mode is being called
    expect(dispatch.mock.calls[1][0]).toEqual({
      type: 'TOGGLE_MODULAR_PIPELINE_FOCUS_MODE',
      modularPipeline: null,
    });
  });
});

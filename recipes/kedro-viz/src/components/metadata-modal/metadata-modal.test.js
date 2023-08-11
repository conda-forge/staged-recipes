import React from 'react';
import MetadataModal from './metadata-modal';
import { toggleNodeClicked, addNodeMetadata } from '../../actions/nodes';
import { setup } from '../../utils/state.mock';
import { togglePlotModal } from '../../actions';
import nodePlot from '../../utils/data/node_plot.mock.json';

const metricsNodeID = '966b9734';

describe('Plotly Modal', () => {
  const mount = (props) => {
    return setup.mount(<MetadataModal />, {
      beforeLayoutActions: [() => toggleNodeClicked(props.nodeId)],
      afterLayoutActions: [
        () => togglePlotModal(true),
        () => addNodeMetadata({ id: metricsNodeID, data: nodePlot }),
      ],
    });
  };
  it('renders without crashing', () => {
    const wrapper = mount({ nodeId: metricsNodeID });
    expect(wrapper.find('.pipeline-metadata-modal').length).toBe(1);
  });

  it('modal closes when collapse button is clicked', () => {
    const wrapper = mount({ nodeId: metricsNodeID });
    wrapper.find('.pipeline-metadata-modal__collapse-plot').simulate('click');
    expect(wrapper.find('.pipeline-metadata-modal').length).toBe(0);
  });

  it('modal closes when back button is clicked', () => {
    const wrapper = mount({ nodeId: metricsNodeID });
    wrapper.find('.pipeline-metadata-modal__back').simulate('click');
    expect(wrapper.find('.pipeline-metadata-modal').length).toBe(0);
  });

  it('shows plot when a plot node is clicked', () => {
    const wrapper = mount({ nodeId: metricsNodeID });
    expect(wrapper.find('.pipeline-metadata-modal__header').length).toBe(1);
    expect(wrapper.find('.pipeline-plotly-chart').length).toBe(1);
  });
});

import React from 'react';
import ExportModal, { mapStateToProps } from './export-modal';
import { mockState, setup } from '../../utils/state.mock';
import { toggleExportModal } from '../../actions';

describe('ExportModal', () => {
  it('renders without crashing', () => {
    const wrapper = setup.mount(<ExportModal />);
    expect(wrapper.find('.pipeline-export-modal').length).toBe(1);
  });

  it('modal closes when X button is clicked', () => {
    const mount = () => {
      return setup.mount(<ExportModal />, {
        afterLayoutActions: [() => toggleExportModal(true)],
      });
    };
    const wrapper = mount();
    expect(wrapper.find('.modal__content--visible').length).toBe(1);
  });

  it('maps state to props', () => {
    const expectedResult = {
      graphSize: expect.objectContaining({
        height: expect.any(Number),
        width: expect.any(Number),
        marginx: expect.any(Number),
        marginy: expect.any(Number),
      }),
      theme: expect.stringMatching(/light|dark/),
      visible: expect.objectContaining({
        exportBtn: expect.any(Boolean),
        exportModal: expect.any(Boolean),
        settingsModal: expect.any(Boolean),
      }),
    };
    expect(mapStateToProps(mockState.spaceflights)).toEqual(expectedResult);
  });
});

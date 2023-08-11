import React from 'react';
import SettingsModal, {
  mapStateToProps,
  mapDispatchToProps,
} from './settings-modal';
import { mockState, setup } from '../../utils/state.mock';
import { toggleSettingsModal } from '../../actions';

describe('SettingsModal', () => {
  it('renders without crashing', () => {
    const wrapper = setup.mount(<SettingsModal />);
    expect(wrapper.find('.pipeline-settings-modal__content').length).toBe(1);
  });

  it('renders with a disabled primary button', () => {
    const mount = () => {
      return setup.mount(<SettingsModal />, {
        afterLayoutActions: [() => toggleSettingsModal(true)],
      });
    };
    const wrapper = mount();

    const content = wrapper.find('.pipeline-settings-modal__content');
    expect(content.find('.button__btn--primary').length).toBe(1);
  });

  it('modal closes when cancel button is clicked', () => {
    const mount = () => {
      return setup.mount(<SettingsModal />, {
        afterLayoutActions: [() => toggleSettingsModal(true)],
      });
    };
    const wrapper = mount();
    expect(wrapper.find('.modal__content--visible').length).toBe(1);
    const closeButton = wrapper.find(
      '.pipeline-settings-modal .button__btn.button__btn--secondary'
    );
    closeButton.simulate('click');
    expect(wrapper.find('.modal__content--visible').length).toBe(0);
  });

  it('maps state to props', () => {
    const expectedResult = {
      visible: expect.objectContaining({
        exportBtn: expect.any(Boolean),
        exportModal: expect.any(Boolean),
        settingsModal: expect.any(Boolean),
      }),
      flags: expect.any(Object),
      isPrettyName: expect.any(Boolean),
    };
    expect(mapStateToProps(mockState.spaceflights)).toEqual(expectedResult);
  });

  it('maps dispatch to props', async () => {
    const dispatch = jest.fn();

    mapDispatchToProps(dispatch).showSettingsModal(false);
    expect(dispatch.mock.calls[0][0]).toEqual({
      type: 'TOGGLE_SETTINGS_MODAL',
      visible: false,
    });

    mapDispatchToProps(dispatch).onToggleFlag('sizewarning', false);
    expect(dispatch.mock.calls[1][0]).toEqual({
      type: 'CHANGE_FLAG',
      name: 'sizewarning',
      value: false,
    });

    mapDispatchToProps(dispatch).onToggleIsPrettyName(false);
    expect(dispatch.mock.calls[2][0]).toEqual({
      type: 'TOGGLE_IS_PRETTY_NAME',
      isPrettyName: false,
    });
  });
});

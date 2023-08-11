import React from 'react';
import Modal from './index';
import { setup } from '../../../utils/state.mock';

describe('Modal', () => {
  const closeModal = jest.fn();

  it('renders without crashing', () => {
    const wrapper = setup.mount(<Modal visible={true} />);
    expect(wrapper.find('.modal__content').length).toBe(1);
  });

  it('should be a function', () => {
    expect(typeof Modal).toBe('function');
  });

  it('should have correct structure', () => {
    const wrapper = setup.mount(
      <Modal title="Hello Test" closeModal={closeModal}>
        <div />
      </Modal>
    );

    expect(wrapper.find('.modal__bg').length === 1).toBeTruthy();
    expect(wrapper.find('.modal__content').length === 1).toBeTruthy();
    expect(wrapper.find('.modal__wrapper').length === 1).toBeTruthy();
    expect(wrapper.find('.modal__content').length === 1).toBeTruthy();
  });

  it('should have button and description when supplied no children', () => {
    const wrapper = setup.mount(
      <Modal title="Hello Test" closeModal={closeModal} />
    );
    expect(wrapper.find('.modal__description').length === 1).toBeTruthy();
  });

  it('Modal should have correct structure when supplied children', () => {
    const wrapper = setup.mount(
      <Modal title="Hello Test" closeModal={closeModal}>
        <button>Hello World</button>
      </Modal>
    );
    expect(
      wrapper.find('.modal__wrapper').find('button').length === 1
    ).toBeTruthy();
  });
});

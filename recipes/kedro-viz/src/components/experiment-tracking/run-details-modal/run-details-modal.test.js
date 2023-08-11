import React from 'react';
import RunDetailsModal from './index';
import Adapter from '@wojtekmaj/enzyme-adapter-react-17';
import { configure, mount } from 'enzyme';
import { render } from '@testing-library/react';
import { ButtonTimeoutContext } from '../../../utils/button-timeout-context';

configure({ adapter: new Adapter() });

// Mocked methods

const mockReset = jest.fn();
const mockUpdateRunDetails = jest.fn();

jest.mock('../../../apollo/mutations', () => {
  return {
    useUpdateRunDetails: () => {
      return {
        reset: mockReset,
        updateRunDetails: mockUpdateRunDetails,
      };
    },
  };
});

const mockValue = {
  handleClick: jest.fn(),
  hasNotInteracted: true,
  isSuccessful: false,
  setHasNotInteracted: jest.fn(),
  setIsSuccessful: jest.fn(),
  showModal: false,
};

// Tests

describe('RunDetailsModal', () => {
  it('renders without crashing', () => {
    const wrapper = mount(
      <ButtonTimeoutContext.Provider value={mockValue}>
        <RunDetailsModal visible />
      </ButtonTimeoutContext.Provider>
    );

    expect(
      wrapper.find('.pipeline-settings-modal--experiment-tracking').length
    ).toBe(1);
  });

  it('renders with a disabled primary button', () => {
    const { getByText } = render(
      <ButtonTimeoutContext.Provider value={mockValue}>
        <RunDetailsModal visible />
      </ButtonTimeoutContext.Provider>
    );

    expect(getByText(/Apply changes and close/i)).toBeDisabled();
  });

  it('modal closes when cancel button is clicked', () => {
    const setVisible = jest.fn();
    const wrapper = mount(
      <ButtonTimeoutContext.Provider value={mockValue}>
        <RunDetailsModal setShowRunDetailsModal={() => setVisible(true)} />
      </ButtonTimeoutContext.Provider>
    );
    const onClick = jest.spyOn(React, 'useState');
    const closeButton = wrapper.find(
      '.pipeline-settings-modal--experiment-tracking .button__btn.button__btn--secondary'
    );

    onClick.mockImplementation((visible) => [visible, setVisible]);

    closeButton.simulate('click');

    expect(
      wrapper.find(
        '.pipeline-settings-modal--experiment-tracking .kui-modal--visible'
      ).length
    ).toBe(0);
  });
});

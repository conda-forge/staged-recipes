import { Wrapper, mapStateToProps } from './wrapper';
import { mockState, setup } from '../../utils/state.mock';

const { theme } = mockState.spaceflights;
const mockProps = {
  displayGlobalToolbar: true,
  theme,
};

const mockPropsNoGlobalToolbar = {
  displayGlobalToolbar: false,
  theme,
};

describe('Wrapper', () => {
  it('renders without crashing', () => {
    const wrapper = setup.shallow(Wrapper, mockProps);
    const container = wrapper.find('.kedro-pipeline');
    expect(container.length).toBe(1);
  });

  it('sets a class based on the theme', () => {
    const wrapper = setup.shallow(Wrapper, mockProps);
    const container = wrapper.find('.kedro-pipeline');
    expect(container.hasClass(`kui-theme--light`)).toBe(theme === 'light');
    expect(container.hasClass(`kui-theme--dark`)).toBe(theme === 'dark');
  });

  it('only displays the h1 and the FlowChartWrapper when displayGlobalToolbar is false', () => {
    const wrapper = setup.shallow(Wrapper, mockPropsNoGlobalToolbar);
    expect(wrapper.children()).toHaveLength(2);
  });

  it('maps state to props', () => {
    expect(mapStateToProps(mockState.spaceflights)).toEqual({
      displayGlobalToolbar: true,
      theme,
    });
  });
});

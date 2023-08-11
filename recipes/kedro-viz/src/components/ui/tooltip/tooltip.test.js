import Tooltip, { insertZeroWidthSpace } from './tooltip';
import { setup } from '../../../utils/state.mock';
import { globalToolbarWidth, sidebarWidth } from '../../../config';

const mockProps = {
  chartSize: {
    height: 766,
    left: 0,
    outerHeight: 766,
    outerWidth: 1198,
    sidebarWidth: sidebarWidth.open,
    top: 0,
    width: 898,
  },
  targetRect: {
    bottom: 341.05895,
    height: 2.1011,
    left: 856.19622,
    right: 866.03076,
    top: 338.95785,
    width: 9.83453,
    x: 856.19622,
    y: 338.95785,
  },
  text: 'lorem_ipsum-dolor: sit [amet]',
  visible: true,
};

describe('Tooltip', () => {
  it('renders without crashing', () => {
    const wrapper = setup.shallow(Tooltip);
    const container = wrapper.find('.pipeline-tooltip');
    expect(container.length).toBe(1);
  });

  it('should not add the top class when the tooltip is towards the bottom', () => {
    const targetRect = {
      ...mockProps.targetRect,
      top: mockProps.chartSize.height - 10,
    };
    const wrapper = setup.shallow(Tooltip, { ...mockProps, targetRect });
    const container = wrapper.find('.pipeline-tooltip--top');
    expect(container.length).toBe(0);
  });

  it('should not add the right class when the tooltip is towards the left', () => {
    const targetRect = {
      ...mockProps.targetRect,
      left: 10,
    };
    const wrapper = setup.shallow(Tooltip, { ...mockProps, targetRect });
    const container = wrapper.find('.pipeline-tooltip--right');
    expect(container.length).toBe(0);
  });

  it("should add the 'top' class when the tooltip is towards the top", () => {
    const targetRect = {
      ...mockProps.targetRect,
      top: 10,
    };
    const wrapper = setup.shallow(Tooltip, { ...mockProps, targetRect });
    const container = wrapper.find('.pipeline-tooltip--top');
    expect(container.length).toBe(1);
  });

  it("should add the 'right' class when the tooltip is towards the right", () => {
    const targetRect = {
      ...mockProps.targetRect,
      left: mockProps.chartSize.width - 10 + globalToolbarWidth,
    };
    const wrapper = setup.shallow(Tooltip, { ...mockProps, targetRect });
    const container = wrapper.find('.pipeline-tooltip--right');
    expect(container.length).toBe(1);
  });
});

describe('insertZeroWidthSpace', () => {
  describe('special characters', () => {
    const zero = String.fromCharCode(0x200b);
    const wrap = (text) => zero + text + zero;
    const characters = '-_[]/:\\!@£$%^&*()'.split('');
    test.each(characters)('wraps %s with a zero-width space', (d) => {
      expect(insertZeroWidthSpace(d)).toBe(wrap(d));
      expect(insertZeroWidthSpace(d).length).toBe(3);
    });
  });

  describe('alphanumeric characters', () => {
    const characters = ['a', 'B', '123', 'aBc123', '0', ''];
    test.each(characters)('does not wrap %s with a zero-width space', (d) => {
      expect(insertZeroWidthSpace(d)).toBe(d);
      expect(insertZeroWidthSpace(d).length).toBe(d.length);
    });
  });

  describe('spaces', () => {
    const characters = [' ', '\t', '\n', 'a b', ' a '];
    test.each(characters)('does not wrap %s with a zero-width space', (d) => {
      expect(insertZeroWidthSpace(d)).toBe(d);
      expect(insertZeroWidthSpace(d).length).toBe(d.length);
    });
  });
});

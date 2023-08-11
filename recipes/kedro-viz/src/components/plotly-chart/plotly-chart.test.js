import React from 'react';
import PlotlyChart from './plotly-chart';
import { setup } from '../../utils/state.mock';
import { toggleTheme } from '../../actions';

describe('PlotlyChart', () => {
  const mount = (props) =>
    setup.mount(<PlotlyChart {...props} />, {
      afterLayoutActions: [
        () => {
          return toggleTheme(props?.theme || 'dark');
        },
      ],
    });

  it('renders without crashing', () => {
    const wrapper = mount();
    expect(wrapper.find('.pipeline-plotly-chart').length).toBe(1);
  });

  it('renders dark theme plotly preview', () => {
    const props = {
      data: [],
      layout: {},
      theme: 'dark',
      view: 'preview',
    };
    const wrapper = mount(props);
    const instance = wrapper.find('PlotlyComponent').instance();
    const layout = instance.props.layout;
    expect(layout.height).toBe(300);
    expect(layout.paper_bgcolor).toBe('#111111');
  });

  it('renders dark theme plotly modal', () => {
    const props = {
      data: [],
      layout: {},
      theme: 'dark',
      view: 'modal',
    };
    const wrapper = mount(props);
    const instance = wrapper.find('PlotlyComponent').instance();
    const layout = instance.props.layout;
    expect(layout.height).toBe(null);
    expect(layout.paper_bgcolor).toBe('#111111');
  });

  it('renders light theme plotly modal', () => {
    const props = {
      data: [],
      layout: {},
      theme: 'light',
      view: 'modal',
    };
    const wrapper = mount(props);
    const instance = wrapper.find('PlotlyComponent').instance();
    const layout = instance.props.layout;
    expect(layout.height).toBe(null);
    expect(layout.paper_bgcolor).toBe('#EEEEEE');
  });

  it('renders light theme plotly preview', () => {
    const props = {
      data: [],
      layout: {},
      theme: 'light',
      view: 'preview',
    };
    const wrapper = mount(props);
    const instance = wrapper.find('PlotlyComponent').instance();
    const layout = instance.props.layout;
    expect(layout.height).toBe(300);
    expect(layout.paper_bgcolor).toBe('#EEEEEE');
  });

  it('renders with a one-chart template', () => {
    const props = {
      data: [],
      layout: {},
      theme: 'light',
      view: 'oneChart',
    };
    const wrapper = mount(props);
    const instance = wrapper.find('PlotlyComponent').instance();
    const layout = instance.props.layout;
    expect(layout.height).toBe(null);
    expect(layout.paper_bgcolor).toBe('#EEEEEE');
    expect(wrapper.find('.pipeline-plotly__oneChart').length).toBe(1);
  });

  it('renders with a two-chart template', () => {
    const props = {
      data: [],
      layout: {},
      theme: 'light',
      view: 'twoCharts',
    };
    const wrapper = mount(props);
    const instance = wrapper.find('PlotlyComponent').instance();
    const layout = instance.props.layout;
    expect(layout.height).toBe(375);
    expect(layout.paper_bgcolor).toBe('#EEEEEE');
    expect(wrapper.find('.pipeline-plotly__twoCharts').length).toBe(1);
  });

  it('renders with a three-chart template', () => {
    const props = {
      data: [],
      layout: {},
      theme: 'light',
      view: 'threeCharts',
    };
    const wrapper = mount(props);
    const instance = wrapper.find('PlotlyComponent').instance();
    const layout = instance.props.layout;
    expect(layout.height).toBe(250);
    expect(layout.paper_bgcolor).toBe('#EEEEEE');
    expect(wrapper.find('.pipeline-plotly__threeCharts').length).toBe(1);
  });
});

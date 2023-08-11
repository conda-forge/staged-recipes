import React from 'react';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from 'plotly.js-dist-min';
import deepmerge from 'deepmerge';
import { connect } from 'react-redux';
import './plotly-chart.css';
import {
  darkPreviewTemplate,
  darkExpPreviewTemplate,
  darkOneChartTemplate,
  darkTwoChartsTemplate,
  darkThreeChartsTemplate,
} from '../../utils/plot-templates/dark';
import {
  lightPreviewTemplate,
  lightExpPreviewTemplate,
  lightOneChartTemplate,
  lightTwoChartsTemplate,
  lightThreeChartsTemplate,
} from '../../utils/plot-templates/light';
import classNames from 'classnames';

/**
 * Display plotly chart
 * @param {Object} chartSize Chart dimensions in pixels
 * @param {Object} targetRect event.target.getBoundingClientRect()
 * @param {Boolean} visible Whether to show the tooltip
 * @param {String} text Tooltip display label
 */

const Plot = createPlotlyComponent(Plotly);

const PlotlyChart = ({ theme, view = '', data = [], layout = {} }) => {
  const plotConfig = view.includes('preview')
    ? { staticPlot: true }
    : undefined;

  return (
    <div
      className={classNames(
        'pipeline-plotly-chart',
        `pipeline-plotly__${view}`
      )}
    >
      <Plot
        data={data}
        layout={updateLayout(theme, view, layout)}
        config={plotConfig}
        style={{ width: '100%', height: '100%' }}
        useResizeHandler={true}
      />
    </div>
  );
};

const updateLayout = (theme, view, layout) => {
  if (theme === 'dark') {
    if (view === 'experiment_preview') {
      return deepmerge(layout, darkExpPreviewTemplate);
    } else if (view === 'preview') {
      return deepmerge(layout, darkPreviewTemplate);
    } else if (view === 'twoCharts') {
      return deepmerge(layout, darkTwoChartsTemplate);
    } else if (view === 'threeCharts') {
      return deepmerge(layout, darkThreeChartsTemplate);
    } else {
      return deepmerge(layout, darkOneChartTemplate);
    }
  } else {
    if (view === 'experiment_preview') {
      return deepmerge(layout, lightExpPreviewTemplate);
    } else if (view === 'preview') {
      return deepmerge(layout, lightPreviewTemplate);
    } else if (view === 'twoCharts') {
      return deepmerge(layout, lightTwoChartsTemplate);
    } else if (view === 'threeCharts') {
      return deepmerge(layout, lightThreeChartsTemplate);
    } else {
      return deepmerge(layout, lightOneChartTemplate);
    }
  }
};

const mapStateToProps = (state) => ({
  theme: state.theme,
});

export default connect(mapStateToProps)(PlotlyChart);

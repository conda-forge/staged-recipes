export const pathRoot = './api';

export const localStorageName = 'KedroViz';
export const localStorageFlowchartLink = 'KedroViz-link-to-flowchart';
export const localStorageMetricsSelect = 'KedroViz-metrics-chart-select';

export const linkToFlowchartInitialVal = {
  fromURL: null,
  showGoBackBtn: false,
};

// These values are used in both SCSS and JS, and we don't have variable-sharing
// across Sass and JavaScript, so they're defined in two places. If you update their
// value here, please also update their corresponding value in src/styles/_variables.scss
export const globalToolbarWidth = 80;

export const metaSidebarWidth = {
  closed: 0,
  open: 400,
};

export const sidebarWidth = {
  breakpoint: 700,
  closed: 56 + globalToolbarWidth,
  open: 400 + globalToolbarWidth,
  pipelineUI: 344,
};

export const codeSidebarWidth = {
  closed: 0,
  open: 480,
};

// These colours variables come from styles/variables;
const slate600 = '#0e222d';
const slate200 = '#21333e';

const grey200 = '#d5d8da';
const grey100 = '#eaebed';

export const experimentTrackingLazyLoadingColours = {
  backgroundLightTheme: grey200,
  foregroundLightTheme: grey100,
  backgroundDarkTheme: slate600,
  foregroundDarkTheme: slate200,
};

export const metricLimit = 50;

export const experimentTrackingLazyLoadingGap = 38;

export const chartMinWidthScale = 0.25;

// Determine the number of nodes and edges in pipeline to trigger size warning
export const largeGraphThreshold = 1000;

// Remember to update the 'Flags' section in the README when updating these:
export const flags = {
  sizewarning: {
    name: 'Size warning',
    description: 'Show a warning before rendering very large graphs',
    default: true,
    icon: '🐳',
  },
  expandAllPipelines: {
    name: 'Expand all modular pipelines',
    description: 'Expand all modular pipelines on first load',
    default: false,
    icon: '🔛',
  },
};

export const settings = {
  isPrettyName: {
    name: 'Pretty name',
    description: 'Display a formatted name for the kedro nodes',
    default: true,
  },
};

// Sidebar groups is an ordered map of { id: label }
export const sidebarGroups = {
  elementType: 'Element types',
  tag: 'Tags',
};

// Sidebar element types is an ordered map of { id: label }
export const sidebarElementTypes = {
  task: 'Nodes',
  data: 'Datasets',
  parameters: 'Parameters',
};

export const shortTypeMapping = {
  'plotly.plotly_dataset.PlotlyDataSet': 'plotly',
  'plotly.json_dataset.JSONDataSet': 'plotly',
  'matplotlib.matplotlib_writer.MatplotlibWriter': 'image',
  'tracking.json_dataset.JSONDataSet': 'JSONTracking',
  'tracking.metrics_dataset.MetricsDataSet': 'metricsTracking',
};

export const tabLabels = ['Overview', 'Metrics', 'Plots'];

// URL parameters for each element/section
export const params = {
  focused: 'focused_id',
  selected: 'selected_id',
  selectedName: 'selected_name',
  pipeline: 'pipeline_id',
  run: 'run_ids',
  view: 'view',
  comparisonMode: 'comparison',
};

const activePipeline = `${params.pipeline}=:pipelineId`;

export const routes = {
  flowchart: {
    main: '/',
    focusedNode: `/?${activePipeline}&${params.focused}=:id`,
    selectedNode: `/?${activePipeline}&${params.selected}=:id`,
    selectedName: `/?${activePipeline}&${params.selectedName}=:fullName`,
    selectedPipeline: `/?${activePipeline}`,
  },
  experimentTracking: {
    main: '/experiment-tracking',
    selectedView: `/experiment-tracking?${params.view}=:view`,
    selectedRuns: `/experiment-tracking?${params.run}=:ids&${params.view}=:view&${params.comparisonMode}=:isComparison`,
  },
};

export const errorMessages = {
  node: 'Please check the value of "selected_id" or "selected_name" in the URL',
  modularPipeline: 'Please check the value of "focused_id" in the URL',
  pipeline: 'Please check the value of "pipeline_id" in the URL',
  experimentTracking: `Please check the spelling of "run_ids" or "view" or "comparison" in the URL. It may be a typo 😇`,
  runIds: `Please check the value of "run_ids" in the URL. Perhaps you've deleted the entity 🙈 or it may be a typo 😇`,
};

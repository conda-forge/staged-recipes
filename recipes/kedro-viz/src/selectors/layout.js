import { createSelector } from 'reselect';
import { getVisibleNodes } from './nodes';
import { getVisibleEdges } from './edges';
import { getVisibleLayerIDs } from './disabled';
import { getVisibleMetaSidebar } from './metadata';
import {
  sidebarWidth,
  metaSidebarWidth,
  chartMinWidthScale,
  largeGraphThreshold,
  codeSidebarWidth,
} from '../config';

const getSizeWarningFlag = (state) => state.flags.sizewarning;
const getVisibleSidebar = (state) => state.visible.sidebar;
const getVisibleCode = (state) => state.visible.code;
const getIgnoreLargeWarning = (state) => state.ignoreLargeWarning;
const getGraphHasNodes = (state) => Boolean(state.graph?.nodes?.length);
const getChartSizeState = (state) => state.chartSize;

/**
 * Show the large graph warning only if there are sufficient nodes + edges,
 * and it hasn't been toggled off (by clicking the Render Anyway button), and
 * the graph layout hasn't already previously been calculated (due to a user
 * filtering the graph to a smaller subset), and the flag isn't set to false.
 */
export const getTriggerLargeGraphWarning = createSelector(
  [
    getVisibleNodes,
    getVisibleEdges,
    getIgnoreLargeWarning,
    getGraphHasNodes,
    getSizeWarningFlag,
  ],
  (nodes, edges, ignoreLargeWarning, graphHasNodes, sizeWarningFlag) =>
    nodes.length + 1.5 * edges.length > largeGraphThreshold &&
    !ignoreLargeWarning &&
    !graphHasNodes &&
    sizeWarningFlag
);

/**
 * Select a subset of state that is watched by graph layout calculators
 * and used to prepare state.graph via async web worker actions
 */
export const getGraphInput = createSelector(
  [
    getVisibleNodes,
    getVisibleEdges,
    getVisibleLayerIDs,
    getTriggerLargeGraphWarning,
  ],
  (nodes, edges, layers, triggerLargeGraphWarning) => {
    if (triggerLargeGraphWarning) {
      return null;
    }

    return { nodes, edges, layers };
  }
);

/**
 * Calculate the displayed width of a sidebar
 */
export const getSidebarWidth = (visible, { open, closed }) =>
  visible ? open : closed;

/**
 * Convert the DOMRect into an Object, mutate some of the properties,
 * and add some useful new ones
 */
export const getChartSize = createSelector(
  [getVisibleSidebar, getVisibleMetaSidebar, getVisibleCode, getChartSizeState],
  (visibleSidebar, visibleMetaSidebar, visibleCodeSidebar, chartSize) => {
    const { left, top, width, height } = chartSize;
    if (!width || !height) {
      return {};
    }

    // Get the actual sidebar width
    const sidebarWidthActual = getSidebarWidth(visibleSidebar, sidebarWidth);
    const metaSidebarWidthActual = getSidebarWidth(
      visibleMetaSidebar,
      metaSidebarWidth
    );
    const codeSidebarWidthActual = getSidebarWidth(
      visibleCodeSidebar,
      codeSidebarWidth
    );

    // Find the resulting space for the chart
    let chartWidth =
      width -
      sidebarWidthActual -
      metaSidebarWidthActual -
      codeSidebarWidthActual;

    return {
      left,
      top,
      outerWidth: width,
      outerHeight: height,
      height,
      width: chartWidth,
      minWidthScale: chartMinWidthScale,
      sidebarWidth: sidebarWidthActual,
      metaSidebarWidth: metaSidebarWidthActual,
      codeSidebarWidth: codeSidebarWidthActual,
    };
  }
);

/**
 * Gets the current chart zoom
 */
export const getChartZoom = createSelector([(state) => state.zoom], (zoom) => ({
  ...zoom,
}));

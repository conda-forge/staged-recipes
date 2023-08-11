import { matchPath } from 'react-router-dom';
import { routes } from '../config';

export const findMatchedPath = (pathname, search) => {
  const matchedFlowchartMainPage = matchPath(pathname + search, {
    exact: true,
    path: [routes.flowchart.main],
  });

  const matchedSelectedPipeline = matchPath(pathname + search, {
    exact: true,
    path: [routes.flowchart.selectedPipeline],
  });

  const matchedSelectedNodeId = matchPath(pathname + search, {
    exact: true,
    path: [routes.flowchart.selectedNode],
  });

  const matchedSelectedNodeName = matchPath(pathname + search, {
    exact: true,
    path: [routes.flowchart.selectedName],
  });

  const matchedFocusedNode = matchPath(pathname + search, {
    exact: true,
    path: [routes.flowchart.focusedNode],
  });

  const matchedExperimentTrackingMainPage = matchPath(pathname + search, {
    exact: true,
    path: [routes.experimentTracking.main],
  });

  const matchedSelectedView = matchPath(pathname + search, {
    exact: true,
    path: [routes.experimentTracking.selectedView],
  });

  const matchedSelectedRuns = matchPath(pathname + search, {
    exact: true,
    path: [routes.experimentTracking.selectedRuns],
  });

  return {
    matchedFlowchartMainPage,
    matchedSelectedPipeline,
    matchedSelectedNodeId,
    matchedSelectedNodeName,
    matchedFocusedNode,
    matchedExperimentTrackingMainPage,
    matchedSelectedView,
    matchedSelectedRuns,
  };
};

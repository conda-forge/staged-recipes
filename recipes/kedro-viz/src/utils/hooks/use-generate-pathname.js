import { useCallback } from 'react';
import { useHistory, generatePath } from 'react-router-dom';
import { localStorageName, routes } from '../../config';

const getCurrentActivePipeline = () => {
  const localStorage = window.localStorage.getItem(localStorageName);
  return JSON.parse(localStorage)?.pipeline?.active;
};

/**
 * To generate different pathnames based on each action
 * E.g.: click on a node, or focus on a modular pipeline
 * or to reset the pathname to the main page
 */
export const useGeneratePathname = () => {
  const history = useHistory();

  const toFlowchartPage = useCallback(() => {
    const url = generatePath(routes.flowchart.main);
    history.push(url);
  }, [history]);

  const toSelectedPipeline = useCallback(
    (pipelineValue) => {
      // Get the value from param if it exists first
      // before checking from localStorage
      const activePipeline = pipelineValue
        ? pipelineValue
        : getCurrentActivePipeline();

      const url = generatePath(routes.flowchart.selectedPipeline, {
        pipelineId: activePipeline,
      });

      history.push(url);
    },
    [history]
  );

  const toSelectedNode = useCallback(
    (item) => {
      const activePipeline = getCurrentActivePipeline();

      const url = generatePath(routes.flowchart.selectedNode, {
        pipelineId: activePipeline,
        id: item.id,
      });
      history.push(url);
    },
    [history]
  );

  const toFocusedModularPipeline = useCallback(
    (item) => {
      const activePipeline = getCurrentActivePipeline();

      const url = generatePath(routes.flowchart.focusedNode, {
        pipelineId: activePipeline,
        id: item.id,
      });
      history.push(url);
    },
    [history]
  );

  return {
    toSelectedPipeline,
    toFlowchartPage,
    toSelectedNode,
    toFocusedModularPipeline,
  };
};

export const useGeneratePathnameForExperimentTracking = () => {
  const history = useHistory();

  const toExperimentTrackingPath = useCallback(() => {
    const url = generatePath(routes.experimentTracking.main);

    history.push(url);
  }, [history]);

  const toMetricsViewPath = useCallback(() => {
    const url = generatePath(routes.experimentTracking.selectedView, {
      view: 'Metrics',
    });
    history.push(url);
  }, [history]);

  const toSelectedRunsPath = useCallback(
    (ids, view, isComparison) => {
      const url = generatePath(routes.experimentTracking.selectedRuns, {
        ids: ids.length === 1 ? ids[0] : ids.toString(),
        view,
        isComparison,
      });

      history.push(url);
    },
    [history]
  );

  return {
    toExperimentTrackingPath,
    toMetricsViewPath,
    toSelectedRunsPath,
  };
};

import React, { useState, useEffect, useCallback, useRef } from 'react';
import { useHistory, useLocation } from 'react-router-dom';
import { connect } from 'react-redux';
import classnames from 'classnames';
import { isLoading } from '../../selectors/loading';
import {
  getModularPipelinesTree,
  getNodeFullName,
} from '../../selectors/nodes';
import { getVisibleMetaSidebar } from '../../selectors/metadata';
import {
  toggleModularPipelineActive,
  toggleModularPipelinesExpanded,
} from '../../actions/modular-pipelines';
import { toggleFocusMode } from '../../actions';
import { loadNodeData } from '../../actions/nodes';
import { loadPipelineData } from '../../actions/pipelines';
import ExportModal from '../export-modal';
import FlowChart from '../flowchart';
import PipelineWarning from '../pipeline-warning';
import LoadingIcon from '../icons/loading';
import MetaData from '../metadata';
import MetadataModal from '../metadata-modal';
import Sidebar from '../sidebar';
import Button from '../ui/button';
import CircleProgressBar from '../ui/circle-progress-bar';
import { loadLocalStorage, saveLocalStorage } from '../../store/helpers';
import {
  errorMessages,
  linkToFlowchartInitialVal,
  localStorageFlowchartLink,
  params,
} from '../../config';
import { findMatchedPath } from '../../utils/match-path';
import { getKeyByValue } from '../../utils/get-key-by-value';

import './flowchart-wrapper.css';

/**
 * Main flowchart container. Handles showing/hiding the sidebar nav for flowchart view,
 * the rendering of the flowchart, as well as the display of all related modals.
 */
export const FlowChartWrapper = ({
  fullNodeNames,
  graph,
  loading,
  metadataVisible,
  modularPipelinesTree,
  nodes,
  onToggleFocusMode,
  onToggleModularPipelineActive,
  onToggleModularPipelineExpanded,
  onToggleNodeSelected,
  onUpdateActivePipeline,
  pipelines,
  sidebarVisible,
}) => {
  const history = useHistory();
  const { pathname, search } = useLocation();
  const searchParams = new URLSearchParams(search);

  const [errorMessage, setErrorMessage] = useState({});
  const [isInvalidUrl, setIsInvalidUrl] = useState(false);
  const [usedNavigationBtn, setUsedNavigationBtn] = useState(false);

  const [counter, setCounter] = useState(60);
  const [goBackToExperimentTracking, setGoBackToExperimentTracking] =
    useState(false);

  const graphRef = useRef(null);

  const {
    matchedFlowchartMainPage,
    matchedSelectedPipeline,
    matchedSelectedNodeId,
    matchedSelectedNodeName,
    matchedFocusedNode,
  } = findMatchedPath(pathname, search);

  const resetErrorMessage = () => {
    setErrorMessage({});
    setIsInvalidUrl(false);
  };

  const checkIfPipelineExists = () => {
    const pipelineId = searchParams.get(params.pipeline);
    const foundPipeline = pipelines.find((id) => id === pipelineId);

    if (!foundPipeline) {
      setErrorMessage(errorMessages.pipeline);
      setIsInvalidUrl(true);
    }
  };

  const redirectSelectedPipeline = () => {
    const pipelineId = searchParams.get(params.pipeline);
    const foundPipeline = pipelines.find((id) => id === pipelineId);

    if (foundPipeline) {
      onUpdateActivePipeline(foundPipeline);
      onToggleNodeSelected(null);
      onToggleFocusMode(null);
    } else {
      setErrorMessage(errorMessages.pipeline);
      setIsInvalidUrl(true);
    }
  };

  const redirectToSelectedNode = () => {
    const node =
      searchParams.get(params.selected) ||
      searchParams.get(params.selectedName);

    const nodeId =
      getKeyByValue(fullNodeNames, node) ||
      Object.keys(nodes).find((nodeId) => nodeId === node);

    if (nodeId) {
      const modularPipeline = nodes[nodeId];
      const hasModularPipeline = modularPipeline?.length > 0;

      const isParameterType =
        graph.nodes &&
        graph.nodes.find(
          (node) => node.id === nodeId && node.type === 'parameters'
        );

      if (hasModularPipeline && !isParameterType) {
        onToggleModularPipelineExpanded(modularPipeline);
      }
      onToggleNodeSelected(nodeId);

      if (isInvalidUrl) {
        resetErrorMessage();
      }
    } else {
      setErrorMessage(errorMessages.node);
      setIsInvalidUrl(true);
    }

    checkIfPipelineExists();
  };

  const redirectToFocusedNode = () => {
    const focusedId = searchParams.get(params.focused);
    const foundModularPipeline = modularPipelinesTree[focusedId];

    if (foundModularPipeline) {
      onToggleModularPipelineActive(focusedId, true);
      onToggleFocusMode(foundModularPipeline.data);

      if (isInvalidUrl) {
        resetErrorMessage();
      }
    } else {
      setErrorMessage(errorMessages.modularPipeline);
      setIsInvalidUrl(true);
    }

    checkIfPipelineExists();
  };

  const handlePopState = useCallback(() => {
    setUsedNavigationBtn((usedNavigationBtn) => !usedNavigationBtn);
  }, []);

  useEffect(() => {
    window.addEventListener('popstate', handlePopState);

    return () => {
      window.removeEventListener('popstate', handlePopState);
    };
  }, [handlePopState]);

  useEffect(() => {
    setGoBackToExperimentTracking(loadLocalStorage(localStorageFlowchartLink));
  }, []);

  /**
   * To handle redirecting to a different location via the URL (e.g. selectedNode,
   * focusNode, etc.) we only need to call the matchPath actions when:
   * 1. graphRef.current is null, meaning the page has just loaded
   * 2. or when the user navigates using the back and forward buttons
   * 3. or when invalidUrl is true, meaning the user entered something wrong in
   * the URL and we should allow them to reset by clicking on a different node.
   */
  useEffect(() => {
    const isGraphEmpty = Object.keys(graph).length === 0;

    if (
      (graphRef.current === null || usedNavigationBtn || isInvalidUrl) &&
      !isGraphEmpty
    ) {
      if (matchedFlowchartMainPage) {
        onToggleNodeSelected(null);
        onToggleFocusMode(null);

        resetErrorMessage();
      }

      if (matchedSelectedPipeline) {
        // Redirecting to a different pipeline is also handled at `preparePipelineState`
        // to ensure the data is ready before being passed to here
        redirectSelectedPipeline();
      }

      if (matchedSelectedNodeName || matchedSelectedNodeId) {
        redirectToSelectedNode();
      }

      if (matchedFocusedNode) {
        redirectToFocusedNode();
      }

      // Once all the matchPath checks are finished
      // ensure the local states are reset
      graphRef.current = graph;
      setUsedNavigationBtn(false);
    }

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [graph, usedNavigationBtn, isInvalidUrl]);

  const resetLinkingToFlowchartLocalStorage = useCallback(() => {
    saveLocalStorage(localStorageFlowchartLink, linkToFlowchartInitialVal);

    setGoBackToExperimentTracking(linkToFlowchartInitialVal);
  }, []);

  useEffect(() => {
    const timer =
      counter > 0 && setInterval(() => setCounter(counter - 1), 1000);

    if (counter === 0) {
      resetLinkingToFlowchartLocalStorage();
    }

    return () => clearInterval(timer);
  }, [counter, resetLinkingToFlowchartLocalStorage]);

  const onGoBackToExperimentTrackingHandler = () => {
    const url = goBackToExperimentTracking.fromURL;

    history.push(url);

    resetLinkingToFlowchartLocalStorage();
  };

  if (isInvalidUrl) {
    return (
      <div className="kedro-pipeline">
        <Sidebar />
        <MetaData />
        <PipelineWarning
          errorMessage={errorMessage}
          invalidUrl={isInvalidUrl}
          onResetClick={() => setIsInvalidUrl(false)}
        />
      </div>
    );
  } else {
    return (
      <div className="kedro-pipeline">
        <Sidebar />
        <MetaData />
        <div className="pipeline-wrapper">
          <PipelineWarning />
          <FlowChart />
          <div
            className={classnames('pipeline-wrapper__go-back-btn', {
              'pipeline-wrapper__go-back-btn--show':
                goBackToExperimentTracking?.showGoBackBtn,
              'pipeline-wrapper__go-back-btn--show-sidebar-visible':
                sidebarVisible,
              'pipeline-wrapper__go-back-btn--show-metadata-visible':
                metadataVisible,
            })}
          >
            <Button onClick={onGoBackToExperimentTrackingHandler}>
              <CircleProgressBar>{counter}</CircleProgressBar>
              Return to Experiment Tracking
            </Button>
          </div>
          <div
            className={classnames('pipeline-wrapper__loading', {
              'pipeline-wrapper__loading--sidebar-visible': sidebarVisible,
            })}
          >
            <LoadingIcon visible={loading} />
          </div>
        </div>
        <ExportModal />
        <MetadataModal />
      </div>
    );
  }
};

export const mapStateToProps = (state) => ({
  fullNodeNames: getNodeFullName(state),
  graph: state.graph,
  loading: isLoading(state),
  metadataVisible: getVisibleMetaSidebar(state),
  modularPipelinesTree: getModularPipelinesTree(state),
  nodes: state.node.modularPipelines,
  pipelines: state.pipeline.ids,
  sidebarVisible: state.visible.sidebar,
});

export const mapDispatchToProps = (dispatch) => ({
  onToggleFocusMode: (modularPipeline) => {
    dispatch(toggleFocusMode(modularPipeline));
  },
  onToggleNodeSelected: (nodeID) => {
    dispatch(loadNodeData(nodeID));
  },
  onToggleModularPipelineActive: (modularPipelineIDs, active) => {
    dispatch(toggleModularPipelineActive(modularPipelineIDs, active));
  },
  onToggleModularPipelineExpanded: (expanded) => {
    dispatch(toggleModularPipelinesExpanded(expanded));
  },
  onUpdateActivePipeline: (pipelineId) => {
    dispatch(loadPipelineData(pipelineId));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(FlowChartWrapper);

import nodeParameters from '../utils/data/node_parameters.mock.json';
import nodeTask from '../utils/data/node_task.mock.json';
import nodeData from '../utils/data/node_data.mock.json';
import { mockState } from '../utils/state.mock';
import reducer from './index';
import {
  CHANGE_FLAG,
  RESET_DATA,
  TOGGLE_EXPORT_MODAL,
  TOGGLE_SETTINGS_MODAL,
  TOGGLE_LAYERS,
  TOGGLE_MINIMAP,
  TOGGLE_CODE,
  TOGGLE_PARAMETERS_HOVERED,
  TOGGLE_SIDEBAR,
  TOGGLE_IS_PRETTY_NAME,
  TOGGLE_TEXT_LABELS,
  TOGGLE_THEME,
  UPDATE_CHART_SIZE,
  TOGGLE_HOVERED_FOCUS_MODE,
} from '../actions';
import {
  TOGGLE_NODE_CLICKED,
  TOGGLE_NODES_DISABLED,
  TOGGLE_NODE_HOVERED,
  ADD_NODE_METADATA,
} from '../actions/nodes';
import { TOGGLE_TAG_ACTIVE, TOGGLE_TAG_FILTER } from '../actions/tags';
import {
  TOGGLE_TYPE_DISABLED,
  NODE_TYPE_DISABLED_UNSET,
} from '../actions/node-type';
import { UPDATE_ACTIVE_PIPELINE } from '../actions/pipelines';
import { TOGGLE_MODULAR_PIPELINE_ACTIVE } from '../actions/modular-pipelines';
import { TOGGLE_GRAPH_LOADING } from '../actions/graph';

describe('Reducer', () => {
  it('should return an Object', () => {
    expect(reducer(undefined, {})).toEqual(expect.any(Object));
  });

  describe('RESET_DATA', () => {
    it('should return the same data when given the same input', () => {
      expect(
        reducer(mockState.spaceflights, {
          type: RESET_DATA,
          data: mockState.spaceflights,
        })
      ).toEqual(mockState.spaceflights);
    });

    it('should reset the state with new data', () => {
      // Exclude graph prop
      const removeGraph = (state) => {
        const stateCopy = Object.assign({}, state);
        delete stateCopy.graph;
        return stateCopy;
      };
      const newState = reducer(mockState.demo, {
        type: RESET_DATA,
        data: mockState.spaceflights,
      });
      expect(removeGraph(newState)).toEqual(
        removeGraph(mockState.spaceflights)
      );
    });
  });

  describe('TOGGLE_NODE_CLICKED', () => {
    it('should toggle the given node active', () => {
      const nodeClicked = 'abc123';
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_NODE_CLICKED,
        nodeClicked,
      });
      expect(newState.node.clicked).toEqual(nodeClicked);
    });
  });

  describe('TOGGLE_NODE_HOVERED', () => {
    it('should toggle the given node active', () => {
      const nodeHovered = 'abc123';
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_NODE_HOVERED,
        nodeHovered,
      });
      expect(newState.node.hovered).toEqual(nodeHovered);
    });
  });

  describe('TOGGLE_NODES_DISABLED', () => {
    it('should toggle the given nodes disabled', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_NODES_DISABLED,
        nodeIDs: ['123', 'abc'],
        isDisabled: true,
      });
      expect(newState.node.disabled).toEqual({ 123: true, abc: true });
    });

    it('should set nodeClicked to null if the selected node is being disabled', () => {
      const nodeID = 'abc123';
      const clickNodeAction = {
        type: TOGGLE_NODE_CLICKED,
        nodeClicked: nodeID,
      };
      const clickedState = reducer(mockState.spaceflights, clickNodeAction);
      expect(clickedState.node.clicked).toEqual(nodeID);
      const disableNodeAction = {
        type: TOGGLE_NODES_DISABLED,
        nodeIDs: [nodeID],
        isDisabled: true,
      };
      const disabledState = reducer(clickedState, disableNodeAction);
      expect(disabledState.node.clicked).toEqual(null);
    });
  });

  describe('TOGGLE_IS_PRETTY_NAME', () => {
    it('should toggle the value of isPrettyName', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_IS_PRETTY_NAME,
        isPrettyName: true,
      });
      expect(mockState.spaceflights.isPrettyName).toBe(true);
      expect(newState.isPrettyName).toBe(true);
    });
  });

  describe('TOGGLE_TEXT_LABELS', () => {
    it('should toggle the value of textLabels', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_TEXT_LABELS,
        textLabels: true,
      });
      expect(mockState.spaceflights.textLabels).toBe(true);
      expect(newState.textLabels).toBe(true);
    });
  });

  describe('TOGGLE_TAG_ACTIVE', () => {
    it('should toggle the given tag active', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_TAG_ACTIVE,
        tagIDs: ['huge'],
        active: true,
      });
      expect(newState.tag.active).toEqual({ huge: true });
    });
  });

  describe('TOGGLE_TAG_FILTER', () => {
    it('should disable a given tag', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_TAG_FILTER,
        tagIDs: ['small'],
        enabled: true,
      });
      expect(newState.tag.enabled).toEqual({ small: true });
    });
  });

  describe('TOGGLE_THEME', () => {
    it('should toggle the theme to light', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_THEME,
        theme: 'light',
      });
      expect(newState.theme).toBe('light');
    });
  });

  describe('TOGGLE_TYPE_DISABLED', () => {
    it('should set provided types as enabled or disabled if explicitly set', () => {
      const mockDisabledState = {
        data: false,
        parameters: true,
        task: true,
      };
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_TYPE_DISABLED,
        typeIDs: mockDisabledState,
      });
      expect(newState.nodeType.disabled).toEqual(mockDisabledState);
    });

    it('should set any unset types to disabled when at least one type is explicitly enabled', () => {
      const mockDisabledState = {
        data: NODE_TYPE_DISABLED_UNSET,
        parameters: false,
        task: true,
      };
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_TYPE_DISABLED,
        typeIDs: mockDisabledState,
      });
      expect(newState.nodeType.disabled).toEqual({
        data: true,
        parameters: false,
        task: true,
      });
    });

    it('should reset all types to unset when all types are explicitly disabled', () => {
      const mockDisabledState = {
        data: true,
        parameters: true,
        task: true,
      };
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_TYPE_DISABLED,
        typeIDs: mockDisabledState,
      });
      expect(newState.nodeType.disabled).toEqual({
        data: NODE_TYPE_DISABLED_UNSET,
        parameters: NODE_TYPE_DISABLED_UNSET,
        task: NODE_TYPE_DISABLED_UNSET,
      });
    });
  });

  describe('TOGGLE_LAYERS', () => {
    it('should toggle whether layers are shown', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_LAYERS,
        visible: false,
      });
      expect(newState.layer.visible).toEqual(false);
    });
  });

  describe('TOGGLE_SIDEBAR', () => {
    it('should toggle whether the sidebar is open', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_SIDEBAR,
        visible: false,
      });
      expect(newState.visible.sidebar).toEqual(false);
    });
  });

  describe('TOGGLE_EXPORT_MODAL', () => {
    it('should toggle whether the export modal is visible', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_EXPORT_MODAL,
        visible: false,
      });
      expect(newState.visible.exportModal).toEqual(false);
    });
  });

  describe('TOGGLE_SETTINGS_MODAL', () => {
    it('should toggle whether the export modal is visible', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_SETTINGS_MODAL,
        visible: false,
      });
      expect(newState.visible.settingsModal).toEqual(false);
    });
  });

  describe('TOGGLE_MINIMAP', () => {
    it('should toggle whether the minimap is open', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_MINIMAP,
        visible: false,
      });
      expect(newState.visible.miniMap).toEqual(false);
    });
  });

  describe('UPDATE_ACTIVE_PIPELINE', () => {
    const pipeline = 'abc123';
    const nodeClicked = '123';
    const nodeHovered = '456';
    const pipelineAction = { type: UPDATE_ACTIVE_PIPELINE, pipeline };
    const clickAction = { type: TOGGLE_NODE_CLICKED, nodeClicked };
    const hoverAction = { type: TOGGLE_NODE_HOVERED, nodeHovered };
    const oldState = [clickAction, hoverAction].reduce(
      reducer,
      mockState.spaceflights
    );
    const newState = reducer(oldState, pipelineAction);

    it('should update the active pipeline', () => {
      expect(newState.pipeline.active).toEqual(pipeline);
    });

    it('should reset node.clicked and node.hovered', () => {
      expect(oldState.node.clicked).not.toBe(null);
      expect(oldState.node.hovered).not.toBe(null);
      expect(newState.node.clicked).toBe(null);
      expect(newState.node.hovered).toBe(null);
    });
  });

  describe('ADD_NODE_METADATA', () => {
    const nodeId = '123';

    it('should update the right fields in state under node of task type', () => {
      const data = { id: nodeId, data: nodeTask };
      const loadDataAction = { type: ADD_NODE_METADATA, data };
      const oldState = mockState.json;
      const newState = reducer(oldState, loadDataAction);
      expect(newState.node.code[nodeId]).toEqual(nodeTask.code);
      expect(newState.node.filepath[nodeId]).toEqual(nodeTask.filepath);
    });

    it('should update the right fields in state under node of parameter type', () => {
      const data = { id: nodeId, data: nodeParameters };
      const loadDataAction = { type: ADD_NODE_METADATA, data };
      const oldState = mockState.json;
      const newState = reducer(oldState, loadDataAction);
      expect(newState.node.parameters[nodeId]).toEqual(
        nodeParameters.parameters
      );
    });

    it('should update the right fields in state under node of data type', () => {
      const data = { id: nodeId, data: nodeData };
      const loadDataAction = { type: ADD_NODE_METADATA, data };
      const oldState = mockState.json;
      const newState = reducer(oldState, loadDataAction);
      expect(newState.node.filepath[nodeId]).toEqual(nodeData.filepath);
    });
  });

  describe('UPDATE_CHART_SIZE', () => {
    it("should update the chart's dimensions", () => {
      const newState = reducer(mockState.spaceflights, {
        type: UPDATE_CHART_SIZE,
        chartSize: document.body.getBoundingClientRect(),
      });
      expect(newState.chartSize).toEqual({
        bottom: expect.any(Number),
        height: expect.any(Number),
        left: expect.any(Number),
        right: expect.any(Number),
        top: expect.any(Number),
        width: expect.any(Number),
        x: expect.any(Number),
        y: expect.any(Number),
      });
    });
  });

  describe('TOGGLE_CODE', () => {
    it('should toggle whether the code panel is open', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_CODE,
        visible: true,
      });
      expect(newState.visible.code).toBe(true);
    });
  });

  describe('CHANGE_FLAG', () => {
    it('should update the state when a flag is changed', () => {
      const newState = reducer(mockState.spaceflights, {
        type: CHANGE_FLAG,
        name: 'testFlag',
        value: true,
      });
      expect(newState.flags.testFlag).toBe(true);
    });
  });

  describe('TOGGLE_PARAMETERS_HOVERED', () => {
    it('should toggle the value of hoveredParameters', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_PARAMETERS_HOVERED,
        hoveredParameters: true,
      });
      expect(mockState.spaceflights.hoveredParameters).toBe(false);
      expect(newState.hoveredParameters).toBe(true);
    });
  });

  describe('TOGGLE_MODULAR_PIPELINE_ACTIVE', () => {
    it('should toggle whether a modular pipeline is active', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_MODULAR_PIPELINE_ACTIVE,
        modularPipelineIDs: ['nested'],
        active: true,
      });
      expect(newState.modularPipeline.active).toEqual({ nested: true });
    });
  });

  describe('TOGGLE_GRAPH_LOADING', () => {
    it('should toggle the loading state of the graph', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_GRAPH_LOADING,
        loading: true,
      });
      expect(newState.loading.graph).toBe(true);
    });
  });

  describe('TOGGLE_HOVERED_FOCUS_MODE', () => {
    it('should toggle the value of hoveredFocusMode', () => {
      const newState = reducer(mockState.spaceflights, {
        type: TOGGLE_HOVERED_FOCUS_MODE,
        hoveredFocusMode: true,
      });
      expect(mockState.spaceflights.hoveredFocusMode).toBe(false);
      expect(newState.hoveredFocusMode).toBe(true);
    });
  });
});

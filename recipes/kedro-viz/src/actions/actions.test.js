import spaceflights from '../utils/data/spaceflights.mock.json';
import {
  CHANGE_FLAG,
  RESET_DATA,
  TOGGLE_SETTINGS_MODAL,
  TOGGLE_EXPORT_MODAL,
  TOGGLE_IGNORE_LARGE_WARNING,
  TOGGLE_LAYERS,
  TOGGLE_MINIMAP,
  TOGGLE_PARAMETERS_HOVERED,
  TOGGLE_SIDEBAR,
  TOGGLE_IS_PRETTY_NAME,
  TOGGLE_TEXT_LABELS,
  TOGGLE_THEME,
  UPDATE_CHART_SIZE,
  TOGGLE_CODE,
  TOGGLE_MODULAR_PIPELINE_FOCUS_MODE,
  TOGGLE_HOVERED_FOCUS_MODE,
  changeFlag,
  resetData,
  toggleIgnoreLargeWarning,
  toggleExportModal,
  toggleSettingsModal,
  toggleLayers,
  toggleMiniMap,
  toggleParametersHovered,
  toggleCode,
  toggleSidebar,
  toggleIsPrettyName,
  toggleTextLabels,
  toggleTheme,
  updateChartSize,
  toggleFocusMode,
  toggleHoveredFocusMode,
} from '../actions';
import {
  TOGGLE_NODE_CLICKED,
  TOGGLE_NODES_DISABLED,
  TOGGLE_NODE_HOVERED,
  toggleNodeClicked,
  toggleNodesDisabled,
  toggleNodeHovered,
} from '../actions/nodes';
import {
  TOGGLE_TAG_ACTIVE,
  TOGGLE_TAG_FILTER,
  toggleTagActive,
  toggleTagFilter,
} from '../actions/tags';
import {
  TOGGLE_MODULAR_PIPELINE_ACTIVE,
  TOGGLE_MODULAR_PIPELINES_EXPANDED,
  TOGGLE_SINGLE_MODULAR_PIPELINE_EXPANDED,
  toggleModularPipelineActive,
  toggleModularPipelinesExpanded,
  toggleSingleModularPipelineExpanded,
} from '../actions/modular-pipelines';
import { TOGGLE_TYPE_DISABLED, toggleTypeDisabled } from '../actions/node-type';

describe('actions', () => {
  it('should create an action to reset pipeline data', () => {
    const expectedAction = {
      type: RESET_DATA,
      data: spaceflights,
    };
    expect(resetData(spaceflights)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether to show layers', () => {
    const visible = false;
    const expectedAction = {
      type: TOGGLE_LAYERS,
      visible,
    };
    expect(toggleLayers(visible)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether to show layers', () => {
    const visible = false;
    const expectedAction = {
      type: TOGGLE_MINIMAP,
      visible,
    };
    expect(toggleMiniMap(visible)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether to show the export modal', () => {
    const visible = false;
    const expectedAction = {
      type: TOGGLE_EXPORT_MODAL,
      visible,
    };
    expect(toggleExportModal(visible)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether to show the settings modal', () => {
    const visible = false;
    const expectedAction = {
      type: TOGGLE_SETTINGS_MODAL,
      visible,
    };
    expect(toggleSettingsModal(visible)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether the sidebar is open', () => {
    const visible = false;
    const expectedAction = {
      type: TOGGLE_SIDEBAR,
      visible,
    };
    expect(toggleSidebar(visible)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether a node has been clicked', () => {
    const nodeClicked = '12367890';
    const expectedAction = {
      type: TOGGLE_NODE_CLICKED,
      nodeClicked,
    };
    expect(toggleNodeClicked(nodeClicked)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether a node has been hovered', () => {
    const nodeHovered = '12367890';
    const expectedAction = {
      type: TOGGLE_NODE_HOVERED,
      nodeHovered,
    };
    expect(toggleNodeHovered(nodeHovered)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether parameters heading in the sidebar has been hovered', () => {
    const hoveredParameters = true;
    const expectedAction = {
      type: TOGGLE_PARAMETERS_HOVERED,
      hoveredParameters,
    };
    expect(toggleParametersHovered(hoveredParameters)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether focud mode icon in the sidebar has been hovered', () => {
    const hoveredFocusMode = true;
    const expectedAction = {
      type: TOGGLE_HOVERED_FOCUS_MODE,
      hoveredFocusMode,
    };
    expect(toggleHoveredFocusMode(hoveredFocusMode)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether somes nodes are disabled', () => {
    const nodeIDs = ['12367890', '0987654321', 'qwertyuiop'];
    const isDisabled = false;
    const expectedAction = {
      type: TOGGLE_NODES_DISABLED,
      nodeIDs,
      isDisabled,
    };
    expect(toggleNodesDisabled(nodeIDs, isDisabled)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether to show pretty names on/off', () => {
    const isPrettyName = false;
    const expectedAction = {
      type: TOGGLE_IS_PRETTY_NAME,
      isPrettyName,
    };
    expect(toggleIsPrettyName(isPrettyName)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether to show text labels on/off', () => {
    const textLabels = false;
    const expectedAction = {
      type: TOGGLE_TEXT_LABELS,
      textLabels,
    };
    expect(toggleTextLabels(textLabels)).toEqual(expectedAction);
  });

  it("should create an action to toggle a tag's active state on/off", () => {
    const tagID = '1234567890';
    const active = false;
    const expectedAction = {
      type: TOGGLE_TAG_ACTIVE,
      tagIDs: [tagID],
      active,
    };
    expect(toggleTagActive(tagID, active)).toEqual(expectedAction);
  });

  it('should create an action to toggle an array of tags active state on/off', () => {
    const tagIDs = ['12345', '67890'];
    const active = false;
    const expectedAction = {
      type: TOGGLE_TAG_ACTIVE,
      tagIDs,
      active,
    };
    expect(toggleTagActive(tagIDs, active)).toEqual(expectedAction);
  });

  it('should create an action to toggle a tag on/off', () => {
    const tagID = '1234567890';
    const enabled = false;
    const expectedAction = {
      type: TOGGLE_TAG_FILTER,
      tagIDs: [tagID],
      enabled,
    };
    expect(toggleTagFilter(tagID, enabled)).toEqual(expectedAction);
  });

  it('should create an action to toggle an array of tags on/off', () => {
    const tagIDs = ['12345', '67890'];
    const enabled = false;
    const expectedAction = {
      type: TOGGLE_TAG_FILTER,
      tagIDs,
      enabled,
    };
    expect(toggleTagFilter(tagIDs, enabled)).toEqual(expectedAction);
  });

  /**
   * Tests for modular pipelines related actions
   */

  it('should create an action to toggle an array of modular pipelines active state on/off', () => {
    const modularPipelineIDs = ['12345', '67890'];
    const active = false;
    const expectedAction = {
      type: TOGGLE_MODULAR_PIPELINE_ACTIVE,
      modularPipelineIDs,
      active,
    };
    expect(toggleModularPipelineActive(modularPipelineIDs, active)).toEqual(
      expectedAction
    );
  });

  it('should create an action to expand an array of modular pipelines', () => {
    const modularPipelineIDs = ['12345', '67890'];
    const expectedAction = {
      type: TOGGLE_MODULAR_PIPELINES_EXPANDED,
      expandedIDs: modularPipelineIDs,
    };
    expect(toggleModularPipelinesExpanded(modularPipelineIDs)).toEqual(
      expectedAction
    );
  });

  it('should create an action to expand a single modular pipeline', () => {
    const modularPipelineID = '12345';
    const expectedAction = {
      type: TOGGLE_SINGLE_MODULAR_PIPELINE_EXPANDED,
      modularPipelineID,
    };
    expect(toggleSingleModularPipelineExpanded(modularPipelineID)).toEqual(
      expectedAction
    );
  });

  it('should create an action to toggle the theme', () => {
    const theme = 'light';
    const expectedAction = {
      type: TOGGLE_THEME,
      theme,
    };
    expect(toggleTheme(theme)).toEqual(expectedAction);
  });

  it('should create an action to toggle whether a type is disabled', () => {
    const typeID = '123';
    const expectedAction = {
      type: TOGGLE_TYPE_DISABLED,
      typeIDs: {
        [typeID]: true,
      },
    };
    expect(toggleTypeDisabled(typeID, true)).toEqual(expectedAction);
  });

  it('should create an action to update the chart size', () => {
    const chartSize = {
      x: 10,
      y: 20,
      outerWidth: 30,
      outerHeight: 40,
      width: 50,
      height: 60,
      navOffset: 70,
    };
    const expectedAction = {
      type: UPDATE_CHART_SIZE,
      chartSize,
    };
    expect(updateChartSize(chartSize)).toEqual(expectedAction);
  });

  it('should create an action to change a flag', () => {
    const expectedAction = {
      type: CHANGE_FLAG,
      name: 'testFlag',
      value: true,
    };
    expect(changeFlag('testFlag', true)).toEqual(expectedAction);
  });

  it('should create an action to toggle display large graph', () => {
    const expectedAction = {
      type: TOGGLE_IGNORE_LARGE_WARNING,
      ignoreLargeWarning: true,
    };
    expect(toggleIgnoreLargeWarning(true)).toEqual(expectedAction);
  });

  it('should create an action to toggle the code display', () => {
    const expectedAction = {
      type: TOGGLE_CODE,
      visible: true,
    };
    expect(toggleCode(true)).toEqual(expectedAction);
  });

  it('should create an action to toggle focus mode for modular pipelines', () => {
    const expectedAction = {
      type: TOGGLE_MODULAR_PIPELINE_FOCUS_MODE,
      modularPipeline: { id: '1234' },
    };
    expect(toggleFocusMode({ id: '1234' })).toEqual(expectedAction);
  });
});

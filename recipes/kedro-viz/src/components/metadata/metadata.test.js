import React from 'react';
import MetaData, { mapDispatchToProps } from './metadata';
import { toggleIsPrettyName } from '../../actions';
import { toggleTypeDisabled } from '../../actions/node-type';
import { toggleNodeClicked, addNodeMetadata } from '../../actions/nodes';
import { toggleModularPipelinesExpanded } from '../../actions/modular-pipelines';
import { setup } from '../../utils/state.mock';
import nodePlot from '../../utils/data/node_plot.mock.json';
import nodeParameters from '../../utils/data/node_parameters.mock.json';
import nodeTask from '../../utils/data/node_task.mock.json';
import nodeData from '../../utils/data/node_data.mock.json';
import nodeTranscodedData from '../../utils/data/node_transcoded_data.mock.json';
import nodeMetricsData from '../../utils/data/node_metrics_data.mock.json';
import nodeJSONData from '../../utils/data/node_json_data.mock.json';

const modelInputDataSetNodeId = '23c94afb';
const splitDataTaskNodeId = '65d0d789';
const parametersNodeId = 'f1f1425b';
const dataScienceNodeId = 'data_science';
const dataProcessingNodeId = 'data_processing';

describe('MetaData', () => {
  const mount = (props) => {
    return setup.mount(<MetaData visible={true} />, {
      //parameters are enabled here to test all metadata panel functionality
      beforeLayoutActions: [
        () => toggleTypeDisabled('parameters', false),
        // expand a modular pipeline
        () =>
          toggleModularPipelinesExpanded([
            dataScienceNodeId,
            dataProcessingNodeId,
          ]),
      ],
      afterLayoutActions: [
        // Click the expected node
        () => toggleNodeClicked(props.nodeId),
        //simulating loadNodeData in node.js
        () => addNodeMetadata({ id: props.nodeId, data: props.mockMetadata }),
      ],
    });
  };

  const textOf = (elements) => elements.map((element) => element.text());
  const title = (wrapper) => wrapper.find('.pipeline-metadata__title');
  const rowIcon = (row) => row.find('svg.pipeline-metadata__icon');
  const rowValue = (row) => row.find('.pipeline-metadata__value');
  const rowObject = (row) => row.find('.pipeline-json__object');
  const rowByLabel = (wrapper, label) =>
    // Using attribute since traversal by sibling not supported
    wrapper.find(`.pipeline-metadata__row[data-label="${label}"]`);

  describe('All nodes', () => {
    it('when parameters are returned an array and displayed as a list - it limits parameters to 10 values and expands when button clicked', () => {
      // Get metadata for a sample
      const metadata = {};
      metadata.parameters = Array.from({ length: 20 }, (_, i) => `Test: ${i}`);

      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: metadata,
      });
      const parametersRow = () => rowByLabel(wrapper, 'Parameters:');
      const expandButton = parametersRow().find(
        '.pipeline-metadata__value-list-expand'
      );

      // Expand button should show remainder
      expect(expandButton.text()).toBe('+ 10 more');

      // Should show 10 values
      expect(parametersRow().find('.pipeline-metadata__value').length).toBe(10);

      // User clicks to expand
      expandButton.simulate('click');

      // Should show all 20 values
      expect(parametersRow().find('.pipeline-metadata__value').length).toBe(20);
    });

    it('when pretty name is turned off the metadata title displays the full node name and the row below shows the pretty name', () => {
      const props = {
        nodeId: parametersNodeId,
        mockMetadata: nodeParameters,
      };
      const wrapper = setup.mount(<MetaData visible={true} />, {
        beforeLayoutActions: [
          () => toggleIsPrettyName(false),
          () => toggleTypeDisabled('parameters', false),
        ],
        afterLayoutActions: [
          // Click the expected node
          () => toggleNodeClicked(props.nodeId),
          //simulating loadNodeData in node.js
          () => addNodeMetadata({ id: props.nodeId, data: props.mockMetadata }),
        ],
      });
      expect(textOf(title(wrapper))).toEqual(['parameters']);

      const row = rowByLabel(wrapper, 'Pretty node name:');
      expect(textOf(rowValue(row))).toEqual(['Parameters']);
    });

    it('when pretty name is turned on the metadata title displays the formatted name and the row below shows the original name', () => {
      const props = {
        nodeId: parametersNodeId,
        mockMetadata: nodeParameters,
      };
      const wrapper = setup.mount(<MetaData visible={true} />, {
        beforeLayoutActions: [
          () => toggleIsPrettyName(true),
          () => toggleTypeDisabled('parameters', false),
        ],
        afterLayoutActions: [
          // Click the expected node
          () => toggleNodeClicked(props.nodeId),
          //simulating loadNodeData in node.js
          () => addNodeMetadata({ id: props.nodeId, data: props.mockMetadata }),
        ],
      });
      expect(textOf(title(wrapper))).toEqual(['Parameters']);

      const row = rowByLabel(wrapper, 'Original node name:');
      expect(textOf(rowValue(row))).toEqual(['parameters']);
    });
  });

  describe('Task nodes', () => {
    it('shows the code toggle for task nodes with code', () => {
      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: nodeTask,
      });
      expect(wrapper.find('.pipeline-toggle').length).toBe(1);
    });

    it('shows the node type as an icon', () => {
      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: nodeTask,
      });
      expect(rowIcon(wrapper).hasClass('pipeline-node-icon--icon-task')).toBe(
        true
      );
    });

    it('shows the node name as the title', () => {
      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: nodeTask,
      });
      expect(textOf(title(wrapper))).toEqual(['Split Data Node']);
    });

    it('shows the node type as text', () => {
      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: nodeTask,
      });
      const row = rowByLabel(wrapper, 'Type:');
      expect(textOf(rowValue(row))).toEqual(['node']);
    });

    it('does not display the node parameter row when there are no parameters', () => {
      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: { ...nodeTask, parameters: {} },
      });
      const row = rowByLabel(wrapper, 'Parameters:');
      //this is the metadata output when there is no data
      expect(textOf(rowObject(row))).toEqual(['-']);
    });

    it('shows the node parameters when there are parameters', () => {
      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: nodeTask,
      });
      const row = rowByLabel(wrapper, 'Parameters:');
      //this is output of react-json-view with 3 parameters
      expect(textOf(rowObject(row))[0]).toEqual(
        expect.stringContaining('3 items')
      );
    });

    it('shows the node inputs', () => {
      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: nodeTask,
      });
      const row = rowByLabel(wrapper, 'Inputs:');
      expect(textOf(rowValue(row))).toEqual([
        'Model Input Table',
        'Parameters',
      ]);
    });

    it('shows the node outputs', () => {
      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: nodeTask,
      });
      const row = rowByLabel(wrapper, 'Outputs:');
      expect(textOf(rowValue(row))).toEqual([
        'X Train',
        'X Test',
        'Y Train',
        'Y Test',
      ]);
    });

    it('shows the node tags', () => {
      const wrapper = mount({
        nodeId: splitDataTaskNodeId,
        mockMetadata: nodeTask,
      });
      const row = rowByLabel(wrapper, 'Tags:');
      expect(textOf(rowValue(row))).toEqual(['Split']);
    });

    describe('when there is no runCommand returned by the backend', () => {
      it('should show a help message asking user to provide a name property', () => {
        const mockMetadata = { ...nodeTask };
        mockMetadata['run_command'] = null;
        const wrapper = mount({
          nodeId: splitDataTaskNodeId,
          mockMetadata,
        });
        const row = rowByLabel(wrapper, 'Run Command:');
        expect(textOf(rowValue(row))).toEqual([
          'Please provide a name argument for this node in order to see a run command.',
        ]);
      });
    });

    describe('when there is a runCommand returned by the backend', () => {
      it('shows the node run command', () => {
        const wrapper = mount({
          nodeId: splitDataTaskNodeId,
          mockMetadata: nodeTask,
        });

        const row = rowByLabel(wrapper, 'Run Command:');
        expect(textOf(rowValue(row))).toEqual([
          'kedro run --to-nodes=split_data_node',
        ]);
      });

      it('copies run command when button clicked', () => {
        window.navigator.clipboard = {
          writeText: jest.fn(),
        };

        const wrapper = mount({
          nodeId: splitDataTaskNodeId,
          mockMetadata: nodeTask,
        });

        const copyButton = wrapper.find('button.copy-button');

        copyButton.simulate('click');

        expect(window.navigator.clipboard.writeText).toHaveBeenCalledWith(
          'kedro run --to-nodes=split_data_node'
        );
      });
    });
  });

  describe('Dataset nodes', () => {
    it('shows the node type as an icon', () => {
      const wrapper = mount({
        nodeId: modelInputDataSetNodeId,
        mockMetadata: nodeData,
      });
      expect(rowIcon(wrapper).hasClass('pipeline-node-icon--icon-data')).toBe(
        true
      );
    });

    it('shows the node name as the title', () => {
      const wrapper = mount({
        nodeId: modelInputDataSetNodeId,
        mockMetadata: nodeData,
      });
      expect(textOf(title(wrapper))).toEqual(['Model Input Table']);
    });

    it('shows the node type as text', () => {
      const wrapper = mount({
        nodeId: modelInputDataSetNodeId,
        mockMetadata: nodeData,
      });
      const row = rowByLabel(wrapper, 'Type:');
      expect(textOf(rowValue(row))).toEqual(['dataset']);
    });

    it('shows the node dataset type', () => {
      const wrapper = mount({
        nodeId: modelInputDataSetNodeId,
        mockMetadata: nodeData,
      });
      const row = rowByLabel(wrapper, 'Dataset Type:');
      expect(textOf(rowValue(row))).toEqual(['CSVDataSet']);
    });

    it('shows the node filepath', () => {
      const wrapper = mount({
        nodeId: modelInputDataSetNodeId,
        mockMetadata: nodeData,
      });
      const row = rowByLabel(wrapper, 'File Path:');
      expect(textOf(rowValue(row))).toEqual([
        'tmp/project/data/03_primary/model_input_table.csv',
      ]);
    });

    it('wont show any tags as they should only appear if the type is nodeTask', () => {
      const wrapper = mount({
        nodeId: modelInputDataSetNodeId,
        mockMetadata: nodeData,
      });
      const row = rowByLabel(wrapper, 'Tags:');
      expect(row.length).toBe(0);
    });

    describe('when there is a runCommand returned by the backend', () => {
      it('shows the node run command', () => {
        const wrapper = mount({
          nodeId: modelInputDataSetNodeId,
          mockMetadata: nodeData,
        });

        const row = rowByLabel(wrapper, 'Run Command:');
        expect(textOf(rowValue(row))).toEqual([
          'kedro run --to-outputs=model_input_table',
        ]);
      });

      it('copies run command when button clicked', () => {
        window.navigator.clipboard = {
          writeText: jest.fn(),
        };

        const wrapper = mount({
          nodeId: modelInputDataSetNodeId,
          mockMetadata: nodeData,
        });

        const copyButton = wrapper.find('button.copy-button');

        copyButton.simulate('click');

        expect(window.navigator.clipboard.writeText).toHaveBeenCalledWith(
          'kedro run --to-outputs=model_input_table'
        );
      });
    });
    describe('Transcoded dataset nodes', () => {
      it('shows the node original type', () => {
        const wrapper = mount({
          nodeId: modelInputDataSetNodeId,
          mockMetadata: nodeTranscodedData,
        });
        const row = rowByLabel(wrapper, 'Original Type:');
        expect(textOf(rowValue(row))).toEqual(['SparkDataSet']);
      });

      it('shows the node transcoded type', () => {
        const wrapper = mount({
          nodeId: modelInputDataSetNodeId,
          mockMetadata: nodeTranscodedData,
        });
        const row = rowByLabel(wrapper, 'Transcoded Types:');
        expect(textOf(rowValue(row))).toEqual(['ParquetDataSet']);
      });
    });
    describe('Metrics dataset nodes', () => {
      it('shows the node metrics', () => {
        const wrapper = mount({
          nodeId: modelInputDataSetNodeId,
          mockMetadata: nodeMetricsData,
        });
        const row = rowByLabel(wrapper, 'Tracking data from last run:');
        expect(textOf(rowObject(row))[0]).toEqual(
          expect.stringContaining('3 items')
        );
      });
      it('shows the experiment link', () => {
        const wrapper = mount({
          nodeId: modelInputDataSetNodeId,
          mockMetadata: nodeMetricsData,
        });
        expect(wrapper.find('.pipeline-metadata__link').length).toBe(1);
      });
    });

    describe('JSON dataset nodes', () => {
      it('shows the json data', () => {
        const wrapper = mount({
          nodeId: modelInputDataSetNodeId,
          mockMetadata: nodeJSONData,
        });
        const row = rowByLabel(wrapper, 'Tracking data from last run:');
        expect(textOf(rowObject(row))[0]).toEqual(
          expect.stringContaining('3 items')
        );
      });
      it('shows the experiment link', () => {
        const wrapper = mount({
          nodeId: modelInputDataSetNodeId,
          mockMetadata: nodeJSONData,
        });
        expect(wrapper.find('.pipeline-metadata__link').length).toBe(1);
      });
    });

    describe('Plot nodes', () => {
      describe('shows the plot info', () => {
        const wrapper = mount({
          nodeId: modelInputDataSetNodeId,
          mockMetadata: nodePlot,
        });
        it('shows the plotly chart', () => {
          expect(wrapper.find('.pipeline-metadata__plot').length).toBe(1);
        });
        it('shows the plotly expand button', () => {
          expect(wrapper.find('.pipeline-metadata__link').length).toBe(1);
        });
      });
    });
  });

  describe('Parameter nodes', () => {
    it('shows the node type as an icon', () => {
      const wrapper = mount({
        nodeId: parametersNodeId,
        mockMetadata: nodeParameters,
      });
      expect(
        rowIcon(wrapper).hasClass('pipeline-node-icon--icon-parameters')
      ).toBe(true);
    });

    it('shows the node name as the title', () => {
      const wrapper = mount({
        nodeId: parametersNodeId,
        mockMetadata: nodeParameters,
      });
      expect(textOf(title(wrapper))).toEqual(['Parameters']);
    });

    it('shows the node type as text', () => {
      const wrapper = mount({
        nodeId: parametersNodeId,
        mockMetadata: nodeParameters,
      });
      const row = rowByLabel(wrapper, 'Type:');
      expect(textOf(rowValue(row))).toEqual(['parameters']);
    });

    it('shows the node filepath', () => {
      const wrapper = mount({
        nodeId: parametersNodeId,
        mockMetadata: nodeParameters,
      });
      const row = rowByLabel(wrapper, 'File Path:');
      expect(textOf(rowValue(row))).toEqual(['-']);
    });

    it('shows the first line (number of parameters) displayed in json viewer for parameter object', () => {
      const wrapper = mount({
        nodeId: parametersNodeId,
        mockMetadata: nodeParameters,
      });
      const row = rowByLabel(wrapper, 'Parameters:');
      expect(textOf(rowObject(row))[0]).toEqual(
        expect.stringContaining('3 items')
      );
    });

    it('wont show any tags as they should only appear if the type is nodeTask', () => {
      const wrapper = mount({
        nodeId: parametersNodeId,
        mockMetadata: nodeParameters,
      });
      const row = rowByLabel(wrapper, 'Tags:');
      expect(row.length).toBe(0);
    });
  });

  describe('mapDispatchToProps', () => {
    it('onToggleNodeSelected', () => {
      const dispatch = jest.fn();
      mapDispatchToProps(dispatch).onToggleNodeSelected(true);
      expect(dispatch.mock.calls[0][0]).toEqual({
        nodeClicked: true,
        type: 'TOGGLE_NODE_CLICKED',
      });
    });

    it('onToggleCode', () => {
      const dispatch = jest.fn();
      mapDispatchToProps(dispatch).onToggleCode(true);
      expect(dispatch.mock.calls[0][0]).toEqual({
        visible: true,
        type: 'TOGGLE_CODE',
      });
    });

    it('onToggleMetadataModal', () => {
      const dispatch = jest.fn();
      mapDispatchToProps(dispatch).onToggleMetadataModal(true);
      expect(dispatch.mock.calls[0][0]).toEqual({
        visible: true,
        type: 'TOGGLE_METADATA_MODAL',
      });
    });
  });
});

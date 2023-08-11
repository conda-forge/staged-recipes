import {
  arrayToObject,
  prettifyName,
  stripNamespace,
  prettifyModularPipelineNames,
} from '../utils';

/**
 * Create new default pipeline state instance
 * @return {Object} state
 */
export const createInitialPipelineState = () => ({
  pipeline: {
    ids: [],
    name: {},
  },
  modularPipeline: {
    ids: [],
    tree: {},
    visible: {},
    expanded: [],
    active: {},
    disabled: {},
  },
  node: {
    ids: [],
    name: {},
    fullName: {},
    type: {},
    tags: {},
    layer: {},
    disabled: {},
    pipelines: {},
    clicked: null,
    hovered: null,
    fetched: {},
    code: {},
    parameters: {},
    filepath: {},
    inputs: {},
    outputs: {},
    plot: {},
    image: {},
    trackingData: {},
    datasetType: {},
    originalType: {},
    transcodedTypes: {},
    runCommand: {},
    modularPipelines: {},
  },
  nodeType: {
    ids: ['task', 'data', 'parameters', 'modularPipeline'],
    name: {
      data: 'Datasets',
      task: 'Nodes',
      parameters: 'Parameters',
      modularPipeline: 'Modular Pipelines',
    },
    disabled: {
      parameters: true,
      task: false,
      data: false,
    },
  },
  edge: {
    ids: [],
    sources: {},
    targets: {},
  },
  layer: {
    ids: [],
    name: {},
    visible: true,
  },
  tag: {
    ids: [],
    name: {},
    active: {},
    enabled: {},
  },
  hoveredParameters: false,
  hoveredFocusMode: false,
});

/**
 * Check whether data is in expected format
 * @param {Object} data - The parsed data input
 * @return {Boolean} True if valid for formatting
 */
const validateInput = (data) => {
  if (!data) {
    throw new Error('No data provided to Kedro-Viz');
  }
  if (data === 'json') {
    // Data is still loading
    return false;
  }
  if (!Array.isArray(data.edges) || !Array.isArray(data.nodes)) {
    if (typeof jest === 'undefined') {
      console.error('Invalid Kedro-Viz data:', data);
    }
    throw new Error(
      'Invalid Kedro-Viz data input. Please ensure that your pipeline data includes arrays of nodes and edges'
    );
  }
  return true;
};

/**
 * Get unique, reproducible ID for each edge, based on its nodes
 * @param {Object} source - Name and type of the source node
 * @param {Object} target - Name and type of the target node
 */
const createEdgeID = (source, target) => [source, target].join('|');

/**
 * Add a new pipeline
 * @param {String} pipeline.id - Unique ID
 * @param {String} pipeline.name - Pipeline name
 */
const addPipeline = (state) => (pipeline) => {
  const { id } = pipeline;
  if (state.pipeline.name[id]) {
    return;
  }
  state.pipeline.ids.push(id);
  state.pipeline.name[id] = prettifyName(pipeline.name || '');
};

/**
 * Add a new node if it doesn't already exist
 * @param {String} name - Default node name
 * @param {String} type - 'data' or 'task'
 * @param {Array} tags - List of associated tags
 */
const addNode = (state) => (node) => {
  const { id } = node;
  if (state.node.name[id]) {
    return;
  }
  state.node.ids.push(id);
  state.node.name[id] = prettifyName(stripNamespace(node.name || ''));
  state.node.fullName[id] = node.name;
  state.node.type[id] = node.type;
  state.node.layer[id] = node.layer;
  state.node.pipelines[id] = node.pipelines
    ? arrayToObject(node.pipelines, () => true)
    : {};
  state.node.tags[id] = node.tags || [];
  // supports for metadata in case it exists on initial load
  state.node.code[id] = node.code;
  state.node.parameters[id] = node.parameters;
  state.node.filepath[id] = node.filepath;
  state.node.plot[id] = node.plot;
  state.node.image[id] = node.image;
  state.node.datasetType[id] = node.dataset_type;
  state.node.originalType[id] = node.original_type;
  state.node.transcodedTypes[id] = node.transcoded_types;
  state.node.runCommand[id] = node.runCommand;
  state.node.modularPipelines[id] = node.modular_pipelines || [];
};

/**
 * Create a new link between two nodes and add it to the edges array
 * @param {Object} source - Parent node
 * @param {Object} target - Child node
 */
const addEdge =
  (state) =>
  ({ source, target }) => {
    const id = createEdgeID(source, target);
    if (state.edge.ids.includes(id)) {
      return;
    }
    state.edge.ids.push(id);
    state.edge.sources[id] = source;
    state.edge.targets[id] = target;
  };

/**
 * Add a new Tag if it doesn't already exist
 * @param {Object} tag - Tag object
 */
const addTag = (state) => (tag) => {
  const { id } = tag;
  state.tag.ids.push(id);
  state.tag.name[id] = prettifyName(tag.name || '');
};

/**
 * Add a new Layer if it doesn't already exist
 * @param {Object} layer - Layer object
 */
const addLayer = (state) => (layer) => {
  // using layer name as both layerId and name.
  // It futureproofs it if we need a separate layer ID in the future.
  state.layer.ids.push(layer);
  state.layer.name[layer] = layer;
};

/**
 * Convert the pipeline data into a normalized state object
 * @param {Object} data Raw unformatted data input
 * @return {Object} Formatted, normalized state
 */
const normalizeData = (data, expandAllPipelines) => {
  const state = createInitialPipelineState();

  if (data === 'json') {
    state.dataSource = 'json';
  } else if (data.source) {
    state.dataSource = data.source;
  }

  if (!validateInput(data)) {
    return state;
  }

  data.nodes.forEach(addNode(state));
  data.edges.forEach(addEdge(state));
  if (data.pipelines) {
    data.pipelines.forEach(addPipeline(state));
    if (state.pipeline.ids.length) {
      state.pipeline.main = data.selected_pipeline || state.pipeline.ids[0];
      state.pipeline.active = state.pipeline.main;
    }
  }
  if (data.modular_pipelines) {
    state.modularPipeline.ids = Object.keys(data.modular_pipelines);
    state.modularPipeline.tree = prettifyModularPipelineNames(
      data.modular_pipelines
    );

    // Case for expandAllPipelines in component props or within flag
    if (expandAllPipelines) {
      // assign all modular pipelines into expanded state
      state.modularPipeline.expanded = state.modularPipeline.ids;
      // assign all nodes as visible nodes in modular pipelines
      const nodeIds = state.node.ids;
      nodeIds.forEach((nodeId) => {
        if (!state.modularPipeline.ids.includes(nodeId)) {
          state.modularPipeline.visible[nodeId] = true;
        }
      });
    } else {
      if (data.modular_pipelines && data.modular_pipelines['__root__']) {
        for (const child of data.modular_pipelines['__root__'].children || []) {
          state.modularPipeline.visible[child.id] = true;
        }
      }
    }
  }

  if (data.tags) {
    data.tags.forEach(addTag(state));
  }
  if (data.layers) {
    data.layers.forEach(addLayer(state));
  }

  return state;
};

export default normalizeData;

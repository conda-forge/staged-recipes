import { getUrl } from '../../utils';
import spaceflights from '../../utils/data/spaceflights.mock.json';
import demo from '../../utils/data/demo.mock.json';
import nodeTask from '../../utils/data/node_task.mock.json';
import nodePlot from '../../utils/data/node_plot.mock.json';
import nodeParameters from '../../utils/data/node_parameters.mock.json';

/**
 * Mimic old deprecated API formats which didn't include newer fields
 * such as pipelines, layers, tags, etc
 * @param {Object} data A dataset file
 */
export const mockAPIFeatureSupport = (data) => {
  let dataCopy = Object.assign({}, data);
  if (window.deletePipelines) {
    delete dataCopy.selected_pipeline;
    delete dataCopy.pipelines;
  }
  return dataCopy;
};

/**
 * Create a promise that resolves after a timeout
 * @param {Number} milliseconds Timeout in milliseconds
 */
const timeout = (milliseconds) =>
  new Promise((resolve) => setTimeout(resolve, milliseconds));

/**
 * Mock asynchronously loading/parsing data
 * @param {String} path JSON file location. Defaults to main data url from config.js
 * @return {Function} A promise that will return when the file is loaded and parsed
 */
const loadJsonData = async (path = getUrl('main')) => {
  // Add a short timeout to simulate real world use,
  // which should help catch race conditions
  await timeout(50);

  // Use spaceflights dataset in place of 'main' endpoint
  if (path.includes('main')) {
    return mockAPIFeatureSupport(spaceflights);
  }

  // Use nodeParameters dataset for node data
  if (path.includes('nodes/f1f1425b')) {
    return nodeParameters;
  }

  // Use nodePlot dataset for node data
  if (path.includes('nodes/c3p345ed')) {
    return nodePlot;
  }

  // Use nodeTask dataset in place of 'main' endpoint
  if (path.includes('nodes')) {
    return nodeTask;
  }

  // Use demo dataset for 'pipelines' endpoints
  if (path.includes('pipelines')) {
    return mockAPIFeatureSupport(demo);
  }

  const fullPath = `/public${path.substr(1)}`;
  throw new Error(
    `Unable to load pipeline data from ${path}. If you're running Kedro-Viz as a standalone (e.g. for JavaScript development), please check that you have placed a data file at ${fullPath}.`
  );
};

export default loadJsonData;

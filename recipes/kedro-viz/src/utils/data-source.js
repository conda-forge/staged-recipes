import getRandomPipeline from './random-data';
import spaceflights from './data/spaceflights.mock.json';
import demo from './data/demo.mock.json';
import selectors from './data/selectors.mock.json';

/**
 * Determine the data source ID from the URL query string, or an environment
 * variable from the CLI, or from the URL host, else return undefined.
 * You can supply one of the following strings:
   - 'random': Use randomly-generated data
   - 'spaceflights': Use data from the 'spaceflights' test dataset ( this is the same dataset as used by the Core team for their tests )
   - 'demo': Use data from the 'demo' test dataset
   - 'json': Load data from a local json file (in /public/api/main)
 * @return {String} Data source identifier
 */
export const getSourceID = () => {
  const urlParams = new URL(document.location.href).searchParams;
  const dataSource = urlParams.get('data');
  const { REACT_APP_DATA_SOURCE } = process.env;
  const isDemo = document.location.host === 'kedro-org.github.io';

  if (dataSource) {
    return encodeURIComponent(dataSource);
  }
  if (REACT_APP_DATA_SOURCE) {
    return REACT_APP_DATA_SOURCE;
  }
  if (isDemo) {
    return 'demo';
  }
  return 'json';
};

/**
 * Either load synchronous pipeline data, or else indicate with a string
 * that json data should be loaded asynchronously later on.
 * @param {String} source Data source identifier
 * @return {Object|String} Either raw data itself, or 'json'
 */
export const getDataValue = (source) => {
  // Add data source string to data object
  const nameSource = (data) => Object.assign(data, { source });

  switch (source) {
    case 'spaceflights':
      // Use data from the 'spaceflights' test dataset
      return nameSource(spaceflights);
    case 'demo':
      // Use data from the 'demo' test dataset
      return nameSource(demo);
    case 'selectors':
      // Use data from the 'selectors' test dataset
      return nameSource(selectors);
    case 'random':
      // Use procedurally-generated data
      return nameSource(getRandomPipeline());
    case 'json':
      // Load data asynchronously later
      return source;
    default:
      throw new Error(
        `Unexpected data source value '${source}'. Your input should be one of the following values: 'spaceflights', 'demo', 'json', 'selectors', or 'random'`
      );
  }
};

/**
 * Determine which data source to use, and return it
 * @return {Object|String} Pipeline data, or 'json'
 */
const getPipelineData = () => getDataValue(getSourceID());

export default getPipelineData;

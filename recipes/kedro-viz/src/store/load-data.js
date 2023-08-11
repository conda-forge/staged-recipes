import { json } from 'd3-fetch';
import { getUrl } from '../utils';

/**
 * Asynchronously load and parse data from json file using d3-fetch.
 * Throws an error if the request for `main` fails.
 * For requests other than `main`, returns the given or default fallback response.
 * @param {String} path JSON file location. Defaults to main data url from config.js
 * @param {Object} fallback The fallback response object on request failure. Default `{}`.
 * @return {Function} A promise that will return when the file is loaded and parsed
 */
const loadJsonData = (path = getUrl('main'), fallback = {}) =>
  json(path).catch(() => {
    const fullPath = `/public${path.substr(1)}`;

    // For main route throw a user error
    if (path === getUrl('main')) {
      throw new Error(
        `Unable to load data from ${path}. If you're running Kedro-Viz as a standalone (e.g. for JavaScript development), please check that you have placed a data file at ${fullPath}.`
      );
    }

    return new Promise((resolve) => resolve(fallback));
  });

export default loadJsonData;

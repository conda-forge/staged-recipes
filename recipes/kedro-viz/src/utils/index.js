//--- Useful JS utility functions ---//
import { pathRoot } from '../config';

/**
 * Loop through an array and output to an object
 * @param {Array} array
 * @param {Function} callback
 */
export const arrayToObject = (array, callback) => {
  const newObject = {};
  array.forEach((key) => {
    newObject[key] = callback(key);
  });
  return newObject;
};

/**
 * Determine the endpoint URL for loading different data types
 * @param {String} type Data type
 * @param {String=} id Endpoint identifier e.g. pipeline ID
 */
export const getUrl = (type, id) => {
  switch (type) {
    case 'main':
      return [pathRoot, 'main'].join('/');
    case 'pipeline':
      if (!id) {
        throw new Error('No pipeline ID provided');
      }
      return [pathRoot, 'pipelines', id].join('/');
    case 'nodes':
      if (!id) {
        throw new Error('No node ID provided');
      }
      return [pathRoot, 'nodes', id].join('/');
    default:
      throw new Error('Unknown URL type');
  }
};

/**
 * Filter duplicate values from an array
 * @param {any} d Datum
 * @param {Number} i Index
 * @param {Array} arr The array to remove duplicate values from
 */
export const unique = (d, i, arr) => arr.indexOf(d) === i;

/**
 * Returns true if any of the given props are different between given objects.
 * Only shallow changes are detected.
 * @param {Array} props The prop names to check
 * @param {Object} objectA The first object
 * @param {Object} objectB The second object
 * @returns {Boolean} True if any prop changed else false
 */
export const changed = (props, objectA, objectB) => {
  return (
    objectA && objectB && props.some((prop) => objectA[prop] !== objectB[prop])
  );
};

/**
 * Replace any parts of a string that match the keys in the toReplace object
 * @param {String} str The string to check
 * @param {Object} toReplace The object of strings to replace and their replacements
 * @returns {String} The string with or without replaced values
 */
export const replaceMatches = (str, toReplace) => {
  if (str?.length > 0) {
    const regex = new RegExp(Object.keys(toReplace).join('|'), 'gi');

    return str.replace(regex, (matched) => {
      return toReplace[matched];
    });
  } else {
    return str;
  }
};

/**
 * Removes any parts of a string that match the regular expression
 * @param {String} str The string to check
 * @returns {String} The string with or without removed values
 */
export const stripNamespace = (str) => {
  const pattern = new RegExp('[A-Za-z0-9-_]+\\.', 'g');
  return str.replace(pattern, '');
};

/**
 * Replaces any parts of a string that match the pattern with the target pattern and capitalizes each word in the string separated by a space
 * @param {String} str The string to check
 * @returns {String} The string with or without replaced values
 */
export const prettifyName = (str) => {
  const replacedString = str
    .replace(/-/g, ' ')
    .replace(/_/g, ' ')
    .replace(/:/g, ': ')
    .trim();
  return replacedString.replace(/(^|\s)\S/g, (match) => match.toUpperCase());
};

/**
 * Prettifies name property of the nested object in a modularPipeline
 * @param {Object} modularPipelines The object whose nested object property needs to be prettified
 * @returns {Object} The object with or without prettified name inside the nested object
 */
export const prettifyModularPipelineNames = (modularPipelines) => {
  for (const key in modularPipelines) {
    if (modularPipelines.hasOwnProperty(key)) {
      const modularPipeline = modularPipelines[key];

      if (modularPipeline.hasOwnProperty('name')) {
        modularPipelines[key] = {
          ...modularPipeline,
          name: prettifyName(modularPipeline['name']),
        };
      }
    }
  }
  return modularPipelines;
};

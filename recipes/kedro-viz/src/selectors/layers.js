import { createSelector } from 'reselect';
import { getVisibleLayerIDs } from './disabled';

const getGraph = (state) => state.graph;
const getLayerName = (state) => state.layer.name;

/**
 * Get layer positions
 */
export const getLayers = createSelector(
  [getGraph, getVisibleLayerIDs, getLayerName],
  ({ nodes, size }, layerIDs, layerName) => {
    if (!nodes || !size || !nodes.length || !layerIDs.length) {
      return [];
    }
    const { width, height } = size;

    const bounds = {};

    for (const node of nodes) {
      const layer = node.nearestLayer || node.layer;

      if (layer) {
        const bound = bounds[layer] || (bounds[layer] = [Infinity, -Infinity]);

        if (node.y - node.height < bound[0]) {
          bound[0] = node.y - node.height;
        }

        if (node.y + node.height > bound[1]) {
          bound[1] = node.y + node.height;
        }
      }
    }

    return layerIDs.map((id, i) => {
      const currentBound = bounds[id] || [0, 0];
      const prevBound = bounds[layerIDs[i - 1]] || [
        currentBound[0],
        currentBound[0],
      ];
      const nextBound = bounds[layerIDs[i + 1]] || [
        currentBound[1],
        currentBound[1],
      ];
      const start = (prevBound[1] + currentBound[0]) / 2;
      const end = (currentBound[1] + nextBound[0]) / 2;
      const rectWidth = Math.max(width, height) * 5;

      return {
        id,
        name: layerName[id],
        x: (rectWidth - width) / -2,
        y: start,
        width: rectWidth,
        height: Math.max(end - start, 0),
      };
    });
  }
);

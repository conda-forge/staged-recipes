import {
  compare,
  distance1d,
  angle,
  nearestOnLine,
  groupByRow,
  nodeLeft,
  nodeRight,
  nodeTop,
  nodeBottom,
} from './common';

/**
 * Finds positions for the given edges relative to their nodes.
 * Input nodes and edges are updated in-place.
 * Results are stored in the `points` property on edges.
 * @param {Object} params The layout parameters
 * @param {Array} params.nodes The input nodes
 * @param {Array} params.edges The input edges
 * @param {Number} params.spaceX The minimum gap between a node and passing edges in X
 * @param {Number} params.spaceY The minimum gap between a node and passing edges in Y
 * @param {Number} params.minPassageGap The minimum gap between two nodes in which an edge can pass in X
 * @param {Number} params.stemUnit The unit length for edge stems at anchors
 * @param {Number} params.stemMax The maximum length of edge stems at anchors
 * @param {Number} params.stemMinSource The minimum length for edge stems at source anchors
 * @param {Number} params.stemMinTarget The minimum length for edge stems at target anchors
 * @param {Number} params.stemSpaceSource The ideal spacing between edge stems at source anchors
 * @param {Number} params.stemSpaceTarget The ideal spacing between edge stems at target anchors
 * @returns {void}
 */
export const routing = ({
  nodes,
  edges,
  spaceX,
  spaceY,
  minPassageGap,
  stemUnit,
  stemMinSource,
  stemMinTarget,
  stemMax,
  stemSpaceSource,
  stemSpaceTarget,
}) => {
  // Find the rows formed by nodes
  const rows = groupByRow(nodes);

  // For each node
  for (const node of nodes) {
    // Sort the node's target edges by the angle between source and target nodes
    node.targets.sort((a, b) =>
      compare(
        angle(b.sourceNode, b.targetNode),
        angle(a.sourceNode, a.targetNode)
      )
    );
  }

  // For each edge
  for (const edge of edges) {
    const source = edge.sourceNode;
    const target = edge.targetNode;

    // Initialise result container
    edge.points = [];

    // Find the ideal gap between edge source anchors
    const sourceSeparation = Math.min(
      (source.width - stemSpaceSource) / source.targets.length,
      stemSpaceSource
    );

    const sourceEdgeDistance =
      source.targets.indexOf(edge) - (source.targets.length - 1) * 0.5;

    const sourceOffsetX = sourceSeparation * sourceEdgeDistance;

    // Start at source node offset
    const startPoint = { x: source.x + sourceOffsetX, y: source.y };
    let currentPoint = startPoint;

    // For each row between the source and target rows exclusive
    for (let i = source.row + 1; i < target.row; i += 1) {
      const firstNode = rows[i][0];

      // Initialise search for next point
      let nearestPoint = { x: nodeLeft(firstNode) - spaceX, y: firstNode.y };
      let nearestDistance = Infinity;

      // Extend the row 'to infinity' on each side in X
      const rowExtended = [
        { ...firstNode, x: Number.MIN_SAFE_INTEGER },
        ...rows[i],
        { ...firstNode, x: Number.MAX_SAFE_INTEGER },
      ];

      // For each gap between each nodes on the row
      for (let i = 0; i < rowExtended.length - 1; i += 1) {
        const node = rowExtended[i];
        const nextNode = rowExtended[i + 1];
        const nodeGap = nodeLeft(nextNode) - nodeRight(node);

        // Avoid routing through small gaps, increase bundling
        if (nodeGap < minPassageGap) {
          continue;
        }

        const offsetX = Math.min(spaceX, nodeGap * 0.5);

        // Find the next potential point. Include offset to reduce overlapping edges
        const candidatePoint = nearestOnLine(
          currentPoint.x,
          currentPoint.y,
          nodeRight(node) + offsetX,
          nodeTop(node) - spaceY,
          nodeLeft(nextNode) - offsetX,
          nodeTop(nextNode) - spaceY
        );

        const distance = distance1d(currentPoint.x, candidatePoint.x);

        // Early out if diverging
        if (distance > nearestDistance) {
          break;
        }

        // Keep the nearest point
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestPoint = candidatePoint;
        }
      }

      // Pass the node at nearest point
      const offsetY = firstNode.height + spaceY;
      edge.points.push({
        x: nearestPoint.x + sourceOffsetX,
        y: nearestPoint.y,
      });
      edge.points.push({
        x: nearestPoint.x + sourceOffsetX,
        y: nearestPoint.y + offsetY,
      });

      currentPoint = {
        x: nearestPoint.x,
        y: nearestPoint.y + offsetY,
      };
    }
  }

  // For each node
  for (const node of nodes) {
    // Sort the node's outgoing edges by the starting angle of the edge path
    node.targets.sort((a, b) =>
      compare(
        angle(b.sourceNode, b.points[0] || b.targetNode),
        angle(a.sourceNode, a.points[0] || a.targetNode)
      )
    );
    // Sort the node's incoming edges by the ending angle of the edge path
    node.sources.sort((a, b) =>
      compare(
        angle(a.points[a.points.length - 1] || a.sourceNode, a.targetNode),
        angle(b.points[b.points.length - 1] || b.sourceNode, b.targetNode)
      )
    );
  }

  // For each edge
  for (const edge of edges) {
    const source = edge.sourceNode;
    const target = edge.targetNode;

    // Find the ideal gap between edge source and target anchors
    const sourceSeparation = Math.min(
      (source.width - stemSpaceSource) / source.targets.length,
      stemSpaceSource
    );

    const targetSeparation = Math.min(
      (target.width - stemSpaceTarget) / target.sources.length,
      stemSpaceTarget
    );

    const sourceEdgeDistance =
      source.targets.indexOf(edge) - (source.targets.length - 1) * 0.5;
    const targetEdgeDistance =
      target.sources.indexOf(edge) - (target.sources.length - 1) * 0.5;

    const sourceOffsetX = sourceSeparation * sourceEdgeDistance;
    const targetOffsetX = targetSeparation * targetEdgeDistance;

    // Decrease stem length outwards from the middle stem
    const sourceOffsetY =
      stemUnit *
      source.targets.length *
      (1 - Math.abs(sourceEdgeDistance) / source.targets.length);

    const targetOffsetY =
      stemUnit *
      target.sources.length *
      (1 - Math.abs(targetEdgeDistance) / target.sources.length);

    // Build the source stem for the edge
    const sourceStem = [
      {
        x: source.x + sourceOffsetX,
        y: nodeBottom(source),
      },
      {
        x: source.x + sourceOffsetX,
        y: nodeBottom(source) + stemMinSource,
      },
      {
        x: source.x + sourceOffsetX,
        y:
          nodeBottom(source) + stemMinSource + Math.min(sourceOffsetY, stemMax),
      },
    ];

    // Build the target stem for the edge
    const targetStem = [
      {
        x: target.x + targetOffsetX,
        y: nodeTop(target) - stemMinTarget - Math.min(targetOffsetY, stemMax),
      },
      {
        x: target.x + targetOffsetX,
        y: nodeTop(target) - stemMinTarget,
      },
      {
        x: target.x + targetOffsetX,
        y: nodeTop(target),
      },
    ];

    // Combine all points
    const points = [...sourceStem, ...edge.points, ...targetStem];

    // Fix any invalid points caused by invalid layouts
    let pointYMax = points[0].y;

    for (const point of points) {
      // Ensure increasing Y values for each point
      if (point.y < pointYMax) {
        point.y = pointYMax;
      } else {
        pointYMax = point.y;
      }
    }

    // Assign finished points to edge
    edge.points = points;
  }
};

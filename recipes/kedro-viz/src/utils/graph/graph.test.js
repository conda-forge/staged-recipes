/*
 * Graph layout engine tests.
 *
 * Refer to LAYOUT_ENGINE.md for description of the approach.
 */

import { mockState } from '../state.mock';
import { getVisibleNodes } from '../../selectors/nodes';
import { getVisibleEdges } from '../../selectors/edges';
import { getVisibleLayerIDs } from '../../selectors/disabled';
import { Constraint, Operator, Strength } from 'kiwi.js';
import { graph } from './graph';
import { solveLoose, solveStrict } from './solver';
import {
  rowConstraint,
  layerConstraint,
  parallelConstraint,
  crossingConstraint,
  separationConstraint,
} from './constraints';

import {
  clamp,
  snap,
  distance1d,
  angle,
  groupByRow,
  nodeLeft,
  nodeRight,
  nodeTop,
  nodeBottom,
  compare,
  offsetEdge,
  offsetNode,
  nearestOnLine,
} from './common';

describe('graph', () => {
  const mockNodes = getVisibleNodes(mockState.spaceflights);
  const mockEdges = getVisibleEdges(mockState.spaceflights);
  const mockLayers = getVisibleLayerIDs(mockState.spaceflights);

  const result = graph(mockNodes, mockEdges, mockLayers);

  it('returns a result object with size and input nodes, edges, layers properties', () => {
    expect(result).toEqual(
      expect.objectContaining({
        size: expect.any(Object),
        nodes: mockNodes,
        edges: mockEdges,
        layers: mockLayers,
      })
    );
  });

  it('returns a size object with valid required properties', () => {
    expect(result.size.width).toBeGreaterThan(0);
    expect(result.size.height).toBeGreaterThan(0);
  });

  it('sets valid x and y properties on all input nodes', () => {
    result.nodes.forEach((node) => {
      expect(node.x).toEqual(expect.any(Number));
      expect(node.y).toEqual(expect.any(Number));
    });
  });

  it('sets valid points property on all input edges', () => {
    result.edges.forEach((edge) => {
      expect(edge.points.length).toBeGreaterThanOrEqual(2);

      edge.points.forEach((point) => {
        expect(point.x).toEqual(expect.any(Number));
        expect(point.y).toEqual(expect.any(Number));
      });
    });
  });
});

describe('commmon', () => {
  it('clamp returns the value limited between min and max', () => {
    // Covers positive, negative and decimal numbers
    expect(clamp(-1, 0, 1)).toEqual(0);
    expect(clamp(0.5, 0, 1)).toEqual(0.5);
    expect(clamp(2, 0, 1)).toEqual(1);

    expect(clamp(-1.5, -2, -1)).toEqual(-1.5);
    expect(clamp(-5, -2, -1)).toEqual(-2);
    expect(clamp(5, -2, -1)).toEqual(-1);
  });

  it('snap returns a value rounded to the nearest unit value', () => {
    // Covers positive, negative and decimal numbers
    expect(snap(1.25, 1)).toEqual(1);
    expect(snap(1.5, 1)).toEqual(2);
    expect(snap(1.75, 1)).toEqual(2);

    expect(snap(100.1, 1)).toEqual(100);
    expect(snap(100.4, 0.5)).toEqual(100.5);

    expect(snap(11, 10)).toEqual(10);
    expect(snap(9, 10)).toEqual(10);
    expect(snap(0, 10)).toEqual(0);

    expect(snap(-1.25, 1)).toEqual(-1);
    expect(snap(-1.5, 1)).toEqual(-1);
    expect(snap(-1.75, 1)).toEqual(-2);

    expect(snap(-100.1, 1)).toEqual(-100);
    expect(snap(-100.4, 0.5)).toEqual(-100.5);

    expect(snap(-11, 10)).toEqual(-10);
    expect(snap(-9, 10)).toEqual(-10);
    expect(snap(-1, 10)).toEqual(-0);
  });

  it('distance1d returns the absolute distance between values', () => {
    // Covers positive, negative and decimal numbers
    expect(distance1d(0, 0)).toEqual(0);
    expect(distance1d(0, 1)).toEqual(1);
    expect(distance1d(1, 2)).toEqual(1);
    expect(distance1d(0, -1)).toEqual(1);
    expect(distance1d(-1, -2)).toEqual(1);
    expect(distance1d(-0.75, 1.5)).toEqual(2.25);
  });

  it('angle returns the angle between two points relative to x-axis', () => {
    // Degenerate case (coincident)
    expect(angle({ x: 0, y: 0 }, { x: 0, y: 0 })).toEqual(0);

    // Same quadrants
    for (let a = -Math.PI; a <= Math.PI; a += Math.PI / 3) {
      const pointA = { x: 2 * Math.cos(a), y: 2 * Math.sin(a) };
      expect(
        angle(pointA, { x: 0.5 * pointA.x, y: 0.5 * pointA.y })
      ).toBeCloseTo(a);
    }

    // Different quadrants
    for (let a = -Math.PI; a <= Math.PI; a += Math.PI / 2) {
      const pointA = { x: Math.cos(a), y: Math.sin(a) };
      expect(angle(pointA, { x: -pointA.x, y: -pointA.y })).toBeCloseTo(a);
    }
  });

  it('groupByRow finds the rows formed by nodes given the their positions in Y sorted in X and Y.', () => {
    const nodes = [
      { x: 1, y: 0 },
      { x: 0, y: 1 },
      { x: 0, y: 0 },
      { x: 2, y: 2 },
      { x: 0, y: 3 },
      { x: 1, y: 2 },
      { x: 0, y: 4 },
      { x: 3, y: 2 },
    ];

    expect(groupByRow(nodes)).toEqual([
      [
        { x: 0, y: 0, row: 0 },
        { x: 1, y: 0, row: 0 },
      ],
      [{ x: 0, y: 1, row: 1 }],
      [
        { x: 1, y: 2, row: 2 },
        { x: 2, y: 2, row: 2 },
        { x: 3, y: 2, row: 2 },
      ],
      [{ x: 0, y: 3, row: 3 }],
      [{ x: 0, y: 4, row: 4 }],
    ]);
  });

  it('nodeLeft returns the left edge x-position of the node', () => {
    expect(nodeLeft({ x: 8.5, y: 10, width: 10.5, height: 20.5 })).toEqual(
      3.25
    );
  });

  it('nodeRight returns the right edge x-position of the node', () => {
    expect(nodeRight({ x: 8.5, y: 10, width: 10.5, height: 20.5 })).toEqual(
      13.75
    );
  });

  it('nodeTop returns the top edge y-position of the node', () => {
    expect(nodeTop({ x: 8.5, y: 10, width: 10.5, height: 20.5 })).toEqual(
      -0.25
    );
  });

  it('nodeBottom returns the bottom edge y-position of the node', () => {
    expect(nodeBottom({ x: 8.5, y: 10, width: 10.5, height: 20.5 })).toEqual(
      20.25
    );
  });

  it('compare returns a value < 0 if a < b for numbers', () => {
    expect(compare(-1, 1)).toBeLessThan(0);
  });

  it('compare returns 0 if a === b for numbers', () => {
    expect(compare(1, 1)).toBe(0);
  });

  it('compare returns a value > 0 if a > b for numbers', () => {
    expect(compare(2, 1)).toBeGreaterThan(0);
  });

  it('compare returns a value < 0 if a < b for strings', () => {
    expect(compare('bat', 'cat')).toBeLessThan(0);
  });

  it('compare returns 0 if a === b for strings', () => {
    expect(compare('cat', 'cat')).toBe(0);
  });

  it('compare returns a value > 0 if a > b for strings', () => {
    expect(compare('hat', 'cat')).toBeGreaterThan(0);
  });

  it('compare breaks ties using subsequent arguments', () => {
    // Covers mixed types between pairs
    expect(compare(1, 1, 'hat', 'cat')).toBeGreaterThan(0);
    expect(compare('cat', 'cat', 1, 2)).toBeLessThan(0);
    expect(compare('cat', 'cat', 1, 1, 0, 0)).toBe(0);
    expect(compare(1, 1, 'cat', 'cat', 5, 3)).toBeGreaterThan(0);
    expect(compare('cat', 'cat', 2, 2, -1, 4)).toBeLessThan(0);
  });

  it('offsetNode returns the node with the position translated in-place', () => {
    const node = { x: 5, y: -10 };
    const result = offsetNode(node, { x: 1, y: 2 });
    expect(result).toEqual({ x: 4, y: -12, order: expect.any(Number) });
    expect(result).toBe(node);
  });

  it('offsetEdge returns the edge with each point translated in-place', () => {
    const edge = {
      points: [
        { x: 5, y: -10 },
        { x: -8, y: 2 },
      ],
    };
    const result = offsetEdge(edge, { x: 1, y: 2 });
    expect(result).toEqual({
      points: [
        { x: 4, y: -12 },
        { x: -9, y: 0 },
      ],
    });
    expect(result).toBe(edge);
  });

  it('nearestOnLine returns the point on the line segment `ax, ay, bx, by` closest to point `x, y`', () => {
    // Degenerate case (coincident)
    expect(nearestOnLine(0, 0, 0, 0, 0, 0)).toEqual(
      expect.objectContaining({
        x: 0,
        y: 0,
      })
    );

    // Lower limit of segment
    expect(nearestOnLine(-1, -1, 0, 0, 1, 1)).toEqual(
      expect.objectContaining({
        x: 0,
        y: 0,
      })
    );

    // Upper limit of segment
    expect(nearestOnLine(2, 2, 0, 0, 1, 1)).toEqual(
      expect.objectContaining({
        x: 1,
        y: 1,
      })
    );

    // Mid-point (coincident)
    expect(nearestOnLine(0.5, 0.5, 0, 0, 1, 1)).toEqual(
      expect.objectContaining({
        x: 0.5,
        y: 0.5,
      })
    );

    // Below the segment
    expect(nearestOnLine(0.5, 0, 0, 0, 1, 1)).toEqual(
      expect.objectContaining({
        x: 0.25,
        y: 0.25,
      })
    );

    // Above the segment
    expect(nearestOnLine(0.5, 1, 0, 0, 1, 1)).toEqual(
      expect.objectContaining({
        x: 0.75,
        y: 0.75,
      })
    );
  });
});

describe('constraints', () => {
  it('rowConstraint separates nodes in `y` in order with at least the given spaceY with strict solve', () => {
    const spaceY = 10;

    // Set up test nodes
    const testA = { id: 0, x: 1, y: 0 };
    const testB = { id: 1, x: 2, y: 0 };
    const testC = { id: 2, x: 3, y: 0 };

    // Set up test constraints
    const rowConstraintAB = {
      base: rowConstraint,
      a: testB,
      b: testA,
    };

    const rowConstraintBC = {
      base: rowConstraint,
      a: testC,
      b: testB,
    };

    // Expect initial y values with no separation
    expect(testB.y - testA.y).toBe(0);
    expect(testC.y - testB.y).toBe(0);

    // Solve test constraints
    solveStrict([rowConstraintAB, rowConstraintBC], { spaceY });

    // Expect order in y is A -> B -> C
    expect(testA.y).toBeLessThan(testB.y);
    expect(testB.y).toBeLessThan(testC.y);

    // Expect y values have been separated by at least the expected amount and direction
    expect(testB.y - testA.y).toBeGreaterThanOrEqual(spaceY);
    expect(testC.y - testB.y).toBeGreaterThanOrEqual(spaceY);
  });

  it('layerConstraint separates nodes in `y` in order with at least the given layerSpace with strict solve', () => {
    const layerSpace = 10;

    // Set up test nodes
    const testA = { id: 0, x: 1, y: 0 };
    const testB = { id: 1, x: 2, y: 0 };
    const testC = { id: 2, x: 3, y: 0 };

    // Set up test constraints
    const layerConstraintAB = {
      base: layerConstraint,
      a: testB,
      b: testA,
    };

    const layerConstraintBC = {
      base: layerConstraint,
      a: testC,
      b: testB,
    };

    // Expect initial y values have no separation
    expect(testB.y - testA.y).toBe(0);
    expect(testC.y - testB.y).toBe(0);

    // Solve test constraints
    solveStrict([layerConstraintAB, layerConstraintBC], { layerSpace });

    // Expect order in y is A -> B -> C
    expect(testA.y).toBeLessThan(testB.y);
    expect(testB.y).toBeLessThan(testC.y);

    // Expect y values have been separated by at least the expected amount and direction
    expect(testB.y - testA.y).toBeGreaterThanOrEqual(layerSpace);
    expect(testC.y - testB.y).toBeGreaterThanOrEqual(layerSpace);
  });

  it('parallelConstraint minimises nodes `x` separation to exactly 0 with strict solve', () => {
    const initialSepration = 10;

    // Set up test nodes
    const testA = { id: 0, x: initialSepration, y: 1 };
    const testB = { id: 1, x: initialSepration * 2, y: 2 };
    const testC = { id: 2, x: initialSepration * 3, y: 3 };

    // Set up test constraints
    const parallelConstraintAB = {
      base: parallelConstraint,
      strength: 0.5,
      a: testA,
      b: testB,
    };

    const parallelConstraintBC = {
      base: parallelConstraint,
      strength: 0.5,
      a: testB,
      b: testC,
    };

    // Expect initial x values have some separation
    expect(testB.x - testA.x).toBeGreaterThan(0);
    expect(testC.x - testB.x).toBeGreaterThan(0);

    // Solve test constraints
    solveStrict([parallelConstraintAB, parallelConstraintBC]);

    // Expect x value separation has been minimised to exactly 0
    expect(Math.abs(testA.x - testB.x)).toEqual(0);
    expect(Math.abs(testB.x - testC.x)).toEqual(0);
  });

  it('parallelConstraint minimises nodes `x` separation to near 0 with loose solve', () => {
    const initialSepration = 10;

    // Set up test nodes
    const testA = { id: 0, x: initialSepration, y: 1 };
    const testB = { id: 1, x: initialSepration * 2, y: 2 };
    const testC = { id: 2, x: initialSepration * 3, y: 3 };

    // Set up test constraints
    const parallelConstraintAB = {
      base: parallelConstraint,
      strength: 0.5,
      a: testA,
      b: testB,
    };

    const parallelConstraintBC = {
      base: parallelConstraint,
      strength: 0.5,
      a: testB,
      b: testC,
    };

    // Expect initial x values have some separation
    expect(testB.x - testA.x).toBeGreaterThan(0);
    expect(testC.x - testB.x).toBeGreaterThan(0);

    // Solve test constraints
    solveLoose([parallelConstraintAB, parallelConstraintBC], 10);

    // Expect x value separation has been minimised near to 0
    expect(Math.abs(testA.x - testB.x)).toBeCloseTo(0);
    expect(Math.abs(testB.x - testC.x)).toBeCloseTo(0);
  });

  it('separationConstraint separates nodes in `x` in order with at least the given separation with strict solve', () => {
    const separation = 10;

    // Set up test nodes
    const testA = { id: 0, x: 0, y: 0 };
    const testB = { id: 1, x: 0, y: 0 };
    const testC = { id: 2, x: 0, y: 0 };

    // Set up test constraints
    const separationConstraintAB = {
      base: separationConstraint,
      a: testA,
      b: testB,
      separation,
    };

    const separationConstraintBC = {
      base: separationConstraint,
      a: testB,
      b: testC,
      separation,
    };

    // Expect initial x values have no separation
    expect(testB.x - testA.x).toBe(0);
    expect(testC.x - testB.x).toBe(0);

    // Solve test constraints
    solveStrict([separationConstraintAB, separationConstraintBC]);

    // Expect order in x is A -> B -> C
    expect(testA.x).toBeLessThan(testB.x);
    expect(testB.x).toBeLessThan(testC.x);

    // Expect x values have been separated by at least the expected amount and direction
    expect(testB.x - testA.x).toBeGreaterThanOrEqual(separation);
    expect(testC.x - testB.x).toBeGreaterThanOrEqual(separation);
  });

  it('crossingConstraint resolves crossing to given separation in `x` between two edges with loose solve', () => {
    const separation = 10;

    // Set up test edges such that they are crossing
    const testEdgeA = {
      sourceNode: { id: 0, x: -5, y: 0 },
      targetNode: { id: 1, x: 5, y: 0 },
    };

    const testEdgeB = {
      sourceNode: { id: 2, x: 10, y: 0 },
      targetNode: { id: 3, x: -10, y: 0 },
    };

    // Set up test constraints
    const crossingConstraintA = {
      base: crossingConstraint,
      edgeA: testEdgeA,
      edgeB: testEdgeB,
      strength: 0.9,
      separationA: separation,
      separationB: separation,
    };

    // Use the dot product to determine if edges cross in X
    const isCrossing = (edgeA, edgeB) =>
      (edgeA.sourceNode.x - edgeB.sourceNode.x) *
        (edgeA.targetNode.x - edgeB.targetNode.x) <
      0;

    // Expect edges to be initially crossing
    expect(isCrossing(testEdgeA, testEdgeB)).toBe(true);

    // Solve test constraints
    solveLoose([crossingConstraintA], 50);

    // Expect edges to no longer be crossing
    expect(isCrossing(testEdgeA, testEdgeB)).toBe(false);

    // Expect source nodes to be separated by close to the expected separation
    expect(
      Math.abs(testEdgeA.sourceNode.x - testEdgeB.sourceNode.x)
    ).toBeGreaterThanOrEqual(separation * 0.99);

    // Expect target nodes to be separated by close to the expected separation
    expect(
      Math.abs(testEdgeA.targetNode.x - testEdgeB.targetNode.x)
    ).toBeGreaterThanOrEqual(separation * 0.99);
  });
});

describe('solver', () => {
  it('solve finds a valid solution to given constraints (loose)', () => {
    const testA = { id: 0, x: 0, y: 0 };
    const testB = { id: 1, x: 0, y: 0 };
    const testC = { id: 2, x: 0, y: 0 };

    const solveEqConstraint = (constraint) => {
      const {
        a,
        b,
        target,
        base: { property },
      } = constraint;
      const difference = a[property] - b[property];

      if (difference === target) {
        return;
      }

      const resolve = difference - target;
      a[property] -= 0.5 * resolve;
      b[property] += 0.5 * resolve;
    };

    const solveGeConstraint = (constraint) => {
      const {
        a,
        b,
        target,
        base: { property },
      } = constraint;
      const difference = a[property] - b[property];

      if (difference >= target) {
        return;
      }

      const resolve = difference - target;
      a[property] -= 0.5 * resolve;
      b[property] += 0.5 * resolve;
    };

    const constraintXA = {
      a: testA,
      b: testB,
      target: 5,
      base: {
        solve: solveEqConstraint,
        property: 'x',
      },
    };

    const constraintXB = {
      a: testB,
      b: testC,
      target: 8,
      base: {
        solve: solveGeConstraint,
        property: 'x',
      },
    };

    const constraintXC = {
      a: testA,
      b: testC,
      target: 20,
      base: {
        solve: solveGeConstraint,
        property: 'x',
      },
    };

    const constraintYA = {
      a: testA,
      b: testC,
      target: 5,
      base: {
        solve: solveEqConstraint,
        property: 'y',
      },
    };

    const constraintYB = {
      a: testB,
      b: testC,
      target: 1,
      base: {
        solve: solveGeConstraint,
        property: 'y',
      },
    };

    const constraintYC = {
      a: testB,
      b: testA,
      target: 100,
      base: {
        solve: solveEqConstraint,
        property: 'y',
      },
    };

    solveLoose(
      [
        constraintXA,
        constraintXB,
        constraintXC,
        constraintYA,
        constraintYB,
        constraintYC,
      ],
      8
    );

    expect(Math.abs(testA.x - testB.x)).toBeCloseTo(5);
    expect(Math.abs(testB.x - testC.x)).toBeGreaterThanOrEqual(8);
    expect(Math.abs(testA.x - testC.x)).toBeGreaterThanOrEqual(20);

    expect(Math.abs(testA.y - testC.y)).toBeCloseTo(5);
    expect(Math.abs(testB.y - testC.y)).toBeGreaterThanOrEqual(1);
    expect(Math.abs(testA.y - testB.y)).toBeCloseTo(100);
  });

  it('solve finds a valid solution to given constraints (strict)', () => {
    const testA = { id: 0, x: 0, y: 0 };
    const testB = { id: 1, x: 0, y: 0 };
    const testC = { id: 2, x: 0, y: 0 };

    const strictEqConstraint = (
      constraint,
      constants,
      variableA,
      variableB
    ) => {
      return new Constraint(
        variableA.minus(variableB),
        Operator.Eq,
        constraint.target,
        Strength.required
      );
    };

    const strictGeConstraint = (
      constraint,
      constants,
      variableA,
      variableB
    ) => {
      return new Constraint(
        variableA.minus(variableB),
        Operator.Ge,
        constraint.target,
        Strength.required
      );
    };

    const constraintXA = {
      a: testA,
      b: testB,
      target: 5,
      base: {
        strict: strictEqConstraint,
        property: 'x',
      },
    };

    const constraintXB = {
      a: testB,
      b: testC,
      target: 8,
      base: {
        strict: strictGeConstraint,
        property: 'x',
      },
    };

    const constraintXC = {
      a: testA,
      b: testC,
      target: 20,
      base: {
        strict: strictGeConstraint,
        property: 'x',
      },
    };

    const constraintYA = {
      a: testA,
      b: testC,
      target: 5,
      base: {
        strict: strictEqConstraint,
        property: 'y',
      },
    };

    const constraintYB = {
      a: testB,
      b: testC,
      target: 1,
      base: {
        strict: strictGeConstraint,
        property: 'y',
      },
    };

    const constraintYC = {
      a: testB,
      b: testA,
      target: 100,
      base: {
        strict: strictEqConstraint,
        property: 'y',
      },
    };

    solveStrict([
      constraintXA,
      constraintXB,
      constraintXC,
      constraintYA,
      constraintYB,
      constraintYC,
    ]);

    expect(Math.abs(testA.x - testB.x)).toEqual(5);
    expect(Math.abs(testB.x - testC.x)).toBeGreaterThanOrEqual(8);
    expect(Math.abs(testA.x - testC.x)).toBeGreaterThanOrEqual(20);

    expect(Math.abs(testA.y - testC.y)).toEqual(5);
    expect(Math.abs(testB.y - testC.y)).toBeGreaterThanOrEqual(1);
    expect(Math.abs(testA.y - testB.y)).toEqual(100);
  });
});

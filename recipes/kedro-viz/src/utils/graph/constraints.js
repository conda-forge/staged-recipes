/**
 * Constraint base definitions.
 *
 * Refer to LAYOUT_ENGINE.md for descriptions of each constraint.
 *
 * See `solve` function of `solver.js` for constraint specification.
 */

import { Constraint, Operator, Strength } from 'kiwi.js';

/**
 * Layout constraint in Y for separating rows
 */
export const rowConstraint = {
  property: 'y',

  strict: (constraint, constants, variableA, variableB) =>
    new Constraint(
      variableA.minus(variableB),
      Operator.Ge,
      constants.spaceY,
      Strength.required
    ),
};

/**
 * Layout constraint in Y for separating layers
 */
export const layerConstraint = {
  property: 'y',

  strict: (constraint, constants, variableA, variableB) =>
    new Constraint(
      variableA.minus(variableB),
      Operator.Ge,
      constants.layerSpace,
      Strength.required
    ),
};

/**
 * Layout constraint in X for minimising distance from source to target for straight edges
 */
export const parallelConstraint = {
  property: 'x',

  solve: (constraint) => {
    const { a, b, strength } = constraint;
    const resolve = strength * (a.x - b.x);
    a.x -= resolve;
    b.x += resolve;
  },

  strict: (constraint, constants, variableA, variableB) =>
    new Constraint(
      variableA.minus(variableB),
      Operator.Eq,
      0,
      Strength.create(1, 0, 0, constraint.strength)
    ),
};

/**
 * Crossing constraint in X for minimising edge crossings
 */
export const crossingConstraint = {
  property: 'x',

  solve: (constraint) => {
    const { edgeA, edgeB, separationA, separationB, strength } = constraint;

    // Amount to move each node towards required separation
    const resolveSource =
      strength *
      ((edgeA.sourceNode.x - edgeB.sourceNode.x - separationA) / separationA);

    const resolveTarget =
      strength *
      ((edgeA.targetNode.x - edgeB.targetNode.x - separationB) / separationB);

    // Apply the resolve each node
    edgeA.sourceNode.x -= resolveSource;
    edgeB.sourceNode.x += resolveSource;
    edgeA.targetNode.x -= resolveTarget;
    edgeB.targetNode.x += resolveTarget;
  },
};

/**
 * Layout constraint in X for minimum node separation
 */
export const separationConstraint = {
  property: 'x',

  strict: (constraint, constants, variableA, variableB) =>
    new Constraint(
      variableB.minus(variableA),
      Operator.Ge,
      constraint.separation,
      Strength.required
    ),
};

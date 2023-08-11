/** @license kiwi.js v1.1.2
 * #------------------------------------------------------------------------------
 * # Copyright (c) 2013, Nucleic Development Team & H. Rutjes.
 * #
 * # Distributed under the terms of the Modified BSD License.
 * #
 * # The full license is in the file COPYING.txt, distributed with this software.
 * #------------------------------------------------------------------------------
 **/
import { Solver, Variable } from 'kiwi.js';

/**
 * Applies the given constraints to the objects in-place.
 * A solution is approximated iteratively.
 * Refer to LAYOUT_ENGINE.md for further details.
 * @param {Array} constraints The constraints
 * @param {Function} constraint.base.solve A function that solves the constraint in-place
 * @param {Number} iterations The number of iterations
 * @param {?Object} constants The constants used by constraints
 */
export const solveLoose = (constraints, iterations, constants) => {
  for (let i = 0; i < iterations; i += 1) {
    for (const constraint of constraints) {
      constraint.base.solve(constraint, constants);
    }
  }
};

/**
 * Applies the given constraints to the objects in-place.
 * A solution is found exactly for the constraints that are solvable.
 * Any unsolvable constraints will be skipped and a warning logged in the console.
 * Refer to LAYOUT_ENGINE.md for further details.
 * @param {Array} constraints The constraints
 * @param {String} constraint.base.property The property name on `a` and `b` to constrain
 * @param {Function} constraint.base.strict A function returns the constraint in strict form
 * @param {Object} constraint.a The first object to constrain
 * @param {Object} constraint.b The second object to constrain
 * @param {Object} constraint.a.id A unique id for the first object
 * @param {Object} constraint.b.id A unique id for the second object
 * @param {?Object} constants The constants used by constraints
 */
export const solveStrict = (constraints, constants) => {
  const solver = new Solver();
  const variables = {};

  const variableId = (obj, property) => `${obj.id}_${property}`;

  const addVariable = (obj, property) => {
    const id = variableId(obj, property);

    if (!variables[id]) {
      const variable = (variables[id] = new Variable());
      variable.property = property;
      variable.obj = obj;
    }
  };

  for (const constraint of constraints) {
    addVariable(constraint.a, constraint.base.property);
    addVariable(constraint.b, constraint.base.property);
  }

  let unsolvableCount = 0;

  for (const constraint of constraints) {
    try {
      solver.addConstraint(
        constraint.base.strict(
          constraint,
          constants,
          variables[variableId(constraint.a, constraint.base.property)],
          variables[variableId(constraint.b, constraint.base.property)]
        )
      );
    } catch (err) {
      unsolvableCount += 1;
    }
  }

  if (unsolvableCount > 0) {
    console.warn(`Skipped ${unsolvableCount} unsolvable constraints`);
  }

  solver.updateVariables();

  const variablesList = Object.values(variables);

  for (const variable of variablesList) {
    variable.obj[variable.property] = variable.value();
  }
};

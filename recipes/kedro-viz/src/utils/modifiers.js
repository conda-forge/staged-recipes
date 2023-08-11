/**
 * Returns a className string with the given modifiers in BEM style
 * @param {String} name The main class name
 * @param {?Object} modifiers Map of modifier names to boolean or string values
 * @param {?String} others Optional class name string to concatenate after
 * @return {String} The compiled class name(s)
 */
const modifiers = (name, modifiers, others = '') =>
  Object.keys(modifiers || {}).reduce((classes, modifier) => {
    const value = modifiers[modifier];

    if (typeof value !== 'string' && typeof value !== 'number') {
      return `${classes} ${name}--${value ? '' : 'no-'}${modifier}`;
    }

    return `${classes} ${name}--${modifier}-${(value + '').replace(
      /\s/g,
      '-'
    )}`;
  }, name) + (others ? ' ' + others : '');

export default modifiers;

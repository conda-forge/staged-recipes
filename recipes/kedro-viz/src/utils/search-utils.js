/**
 * Create a regular expression to match certain keywords
 * @param  {String} value - The search keyword to highlight
 * @return {Object|Boolean} Regular expression or false
 */
export const getValueRegex = (value) => {
  if (!value) {
    return false;
  }
  return new RegExp(`(${escapeRegExp(value)})`, 'gi');
};

/**
 * Wrap a string with a <b> tag
 * @param  {String} str - The text to wrap
 * @return {String} The emboldened text
 */
const getWrappedMatch = (str) => `<b>${str}</b>`;

/**
 * Highlight relevant keywords within a block of text
 * @param  {String} text - The text to parse
 * @param  {String} value - The search keyword to highlight
 * @return {String} The original text but with <b> tags wrapped around matches
 */
export const getHighlightedText = (text, value) => {
  const valueRegex = getValueRegex(value);
  const matches = text.match(valueRegex);

  return value && matches
    ? text.replace(valueRegex, getWrappedMatch('$1'))
    : text;
};

/**
 * Escape string for use in a regular expression, and to prevent XSS attacks
 * All of these should be escaped: \ ^ $ * + ? . ( ) | { } [ ] < >
 * @param {String} str Search keyword string
 */
export const escapeRegExp = (str) => {
  return str.replace(/[.*+?^${}<>()|[\]\\]/g, '\\$&');
};

/**
 * Check whether a piece of text matches the search value
 * @param {Object} text
 * @param {String} searchValue
 * @return {Boolean} True if node matches or no search value given
 */
export const textMatchesSearch = (text, searchValue) => {
  if (searchValue) {
    return new RegExp(escapeRegExp(searchValue), 'gi').test(text);
  }

  return true;
};

export const TOGGLE_TAG_ACTIVE = 'TOGGLE_TAG_ACTIVE';

/**
 * Toggle a tag's highlighting on/off (or array of tags)
 * @param {String|Array} tagIDs Tag id(s)
 * @param {Boolean} active True if tag(s) active
 */
export function toggleTagActive(tagIDs, active) {
  return {
    type: TOGGLE_TAG_ACTIVE,
    tagIDs: Array.isArray(tagIDs) ? tagIDs : [tagIDs],
    active,
  };
}

export const TOGGLE_TAG_FILTER = 'TOGGLE_TAG_FILTER';

/**
 * Toggle a tag's filtering on/off (or array of tags)
 * @param {String|Array} tagIDs Tag id(s)
 * @param {Boolean} enabled True if tag(s) enabled
 */
export function toggleTagFilter(tagIDs, enabled) {
  return {
    type: TOGGLE_TAG_FILTER,
    tagIDs: Array.isArray(tagIDs) ? tagIDs : [tagIDs],
    enabled,
  };
}

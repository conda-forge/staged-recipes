export const TOGGLE_TYPE_DISABLED = 'TOGGLE_TYPE_DISABLED';

/**
 * The default enabled / disabled value for all types is 'unset', meaning not explicitly set by user.
 * The value `0` is chosen to be falsy, JSON serializable but distinct from `false`.
 * In this state the type is effectively enabled by default, see reducers/node-type.js for usage.
 */
export const NODE_TYPE_DISABLED_UNSET = 0;

/**
 * Toggle one or more node-type's visibility on/off
 * @param {String|Object} typeIDs A single type id string, or an object map of type id to disabled booleans
 * @param {?Boolean} disabled True if type is disabled (when passing a single type id string)
 */
export function toggleTypeDisabled(typeIDs, disabled) {
  return {
    type: TOGGLE_TYPE_DISABLED,
    typeIDs: typeof typeIDs === 'string' ? { [typeIDs]: disabled } : typeIDs,
  };
}

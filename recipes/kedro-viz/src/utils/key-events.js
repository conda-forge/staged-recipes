// Keyboard character codes
const KEYS = {
  13: 'enter',
  27: 'escape',
  38: 'up',
  40: 'down',
};

/**
 * Convenience function for handling keyCodes and creating actions
 * @param  {Number} keyCode - A keyboard character
 * @param  {Object} [keyActions] - An optional object-literal list of key names and actions
 * @return {Function|Object} Either a function for a given key char, or nothing
 */
const handleKeyEvent = (keyCode, keyActions) => {
  /**
   * Execute a callback if a given key name matches the key code received
   * @param {String}   keyName  - A key name string (e.g. 'left')
   * @param {Function} callback - A function to execute if the key name matches the key code
   */
  const handleSingleKey = (keyName, callback) => {
    if (keyCode in KEYS && KEYS[keyCode] === keyName.toLowerCase()) {
      return callback();
    }

    return undefined;
  };

  if (keyActions) {
    return Object.keys(keyActions).map((key) =>
      handleSingleKey(key, keyActions[key])
    );
  }

  // Handle a single key, or a comma-separated list of keys
  return (key, callback) => {
    if (key.includes(',')) {
      return key.split(/\s*,\s*/).map((k) => handleSingleKey(k, callback));
    }

    return handleSingleKey(key, callback);
  };
};

export default handleKeyEvent;

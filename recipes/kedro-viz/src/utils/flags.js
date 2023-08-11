import { flags as flagsConfig } from '../config';

/**
 * Flag definitions
 */
export const Flags = {
  /**
   * Returns `true` if the flag is defined otherwise `false`
   * @param {String} name The flag name to test
   * @returns {Boolean} The result
   */
  isDefined: (name) => Flags.names().includes(name),

  /**
   * Returns an array of defined flag names
   * @returns {Array} The defined flag names
   */
  names: () => Object.keys(flagsConfig),

  /**
   * Returns an object mapping flag names to their default values
   * @returns {Object} The defined flag defaults
   */
  defaults: () =>
    Flags.names().reduce(
      (result, flag) =>
        Object.assign(result, { [flag]: flagsConfig[flag].default }),
      {}
    ),
};

/**
 * Returns an object with flags as set in given or current URL
 * @param {String=} url The URL (optional, default current location)
 * @returns {Object} An object with flags and their values
 */
export const getFlagsFromUrl = (url) => {
  const flags = {};

  let urlParams;
  try {
    urlParams = new URL(url || document.location.href).searchParams;
  } catch (e) {
    console.warn('Feature flags are not supported in this browser');
    return flags;
  }

  [...urlParams].forEach(([name, value]) =>
    Flags.isDefined(name)
      ? (flags[name] = value === 'true' || value === '1' || value === '')
      : null
  );

  return flags;
};

/**
 * Returns a user info message describing the status of all defined flags
 * @param {Object} flagsEnabled An object mapping of flag status
 * @returns {String} The info message
 */
export const getFlagsMessage = (flagsEnabled) => {
  const allNames = Flags.names();

  if (allNames.length > 0) {
    let info = 'Experimental features 🏄‍♂️\n';

    allNames.forEach((name) => {
      if (flagsConfig[name].private) {
        return;
      }
      const isEnabled = flagsEnabled[name];
      const status = isEnabled ? 'Enabled' : 'Disabled';
      const statusIcon = isEnabled ? '🟢' : '⚪️';
      const icon = flagsConfig[name].icon;
      const description = flagsConfig[name].description;
      info += `\n${statusIcon} ${icon} "${name}" · ${description} · ${status}`;
    });

    info += `\n\nSee docs on flags for more info 📖`;
    info += `\nhttps://github.com/kedro-org/kedro-viz#flags`;

    return info;
  }
};

export const getFlagsState = () => {
  const allNames = Flags.names();
  return allNames.map((flag) => {
    return {
      name: flagsConfig[flag].name,
      value: flag,
      description: flagsConfig[flag].description,
    };
  });
};

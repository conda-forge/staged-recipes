import seedrandom from 'seedrandom';

/**
 * Generate a pseudo-random UUID
 * via https://stackoverflow.com/a/1349426/1651713
 * @param {Number} length Hash/ID length
 * @return string
 */
export const generateHash = (length) => {
  const result = [];
  const characters =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  for (let i = 0; i < length; i++) {
    result.push(
      characters.charAt(Math.floor(Math.random() * characters.length))
    );
  }
  return result.join('');
};

/**
 * Seed data with a random hash, allowing it to be reproduced.
 * If the URL searchParams contain a 'seed' key then use its value,
 * else create a new one, and make it available via the console.
 */
export const getSeedFromURL = () => {
  let url;
  let seed;
  try {
    url = new URL(document.location.href);
    seed = url.searchParams.get('seed');
  } catch (e) {
    console.warn('Random data seeding is not supported in this browser');
    return;
  }
  if (!seed) {
    seed = generateHash(30);
    url.searchParams.set('seed', seed);
  }
  if (typeof jest === 'undefined') {
    console.info(
      `%cRandom data seed: ${seed}\nTo reuse this layout, visit ${url.toString()}`,
      'font-weight: bold'
    );
  }
  return seed;
};

/**
 * Get an array of numbers
 * @param {Number} length Length of the array
 */
export const getNumberArray = (length) => Array.from(Array(length).keys());

export const LOREM_IPSUM =
  'lorem ipsum dolor sit amet consectetur adipiscing elit vestibulum id turpis nunc nulla vitae diam dignissim fermentum elit sit amet viverra libero quisque condimentum pellentesque convallis sed consequat neque ac rhoncus finibus'.split(
    ' '
  );

/**
 * Utils that depend on a seeded RNG
 */
const randomUtils = () => {
  // Set up seeded random number generator:
  const seed = getSeedFromURL();
  const random = seedrandom(seed);

  /**
   * Get a random number between 0 to n-1, inclusive
   * @param {Number} max Max number
   */
  const randomIndex = (max) => Math.floor(random() * max);

  /**
   * Get a random number between 1 to n, inclusive
   * @param {Number} max Max number
   */
  const randomNumber = (max) => Math.ceil(random() * max);

  /**
   * Get a random number between min and max, inclusive
   * @param {Number} (min) Min number
   * @param {Number} (max) Max number
   */
  const randomNumberBetween = (min, max) => randomNumber(max - min) + min;

  /**
   * Get a random datum from an array
   * @param {Array} range The array to select a random item from
   */
  const getRandom = (range) => range[randomIndex(range.length)];

  /**
   * Generate a random latin name
   * @param {Number} numWords Number of words in the name
   * @param {String} join The character(s) used to join each word
   */
  const getRandomName = (numWords, join = '_') =>
    getNumberArray(numWords)
      .map(() => getRandom(LOREM_IPSUM))
      .join(join);

  /**
   * Randomly select a certain number (n) of items from an array (arr).
   * via https://stackoverflow.com/a/19270021/1651713
   * @param {Array} arr List from which to choose
   * @param {Number} numItems Number of items to select
   */
  const getRandomSelection = (arr, numItems) => {
    const result = new Array(numItems);
    let len = arr.length;
    const taken = new Array(len);
    if (numItems > len) {
      return arr;
    }
    while (numItems--) {
      const x = Math.floor(random() * len);
      result[numItems] = arr[x in taken ? taken[x] : x];
      taken[x] = --len in taken ? taken[len] : len;
    }
    return result;
  };

  return {
    random,
    randomIndex,
    randomNumber,
    randomNumberBetween,
    getRandom,
    getRandomName,
    getRandomSelection,
  };
};

export default randomUtils;

import { unique } from './index';
import randomUtils, { getNumberArray, generateHash } from './random-utils';
const {
  randomIndex,
  randomNumber,
  randomNumberBetween,
  getRandom,
  getRandomName,
  getRandomSelection,
} = randomUtils();

describe('utils', () => {
  describe('getNumberArray', () => {
    it('returns an array of numbers with length equal to the input value', () => {
      expect(getNumberArray(10)).toEqual([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });
  });

  describe('randomIndex', () => {
    it('returns a number', () => {
      expect(typeof randomIndex(5)).toEqual('number');
    });

    it('returns an integer', () => {
      const num = randomIndex(500);
      expect(Math.round(num)).toEqual(num);
    });

    it('returns a number less than the number passed', () => {
      const num = 10;
      expect(randomIndex(num)).toBeLessThan(num);
    });
  });

  describe('randomNumber', () => {
    it('returns a number', () => {
      expect(typeof randomNumber(5)).toEqual('number');
    });

    it('returns an integer', () => {
      const num = randomNumber(500);
      expect(Math.round(num)).toEqual(num);
    });

    it('returns a number less or equal to the number passed', () => {
      const num = 10;
      expect(randomNumber(num)).toBeLessThan(num + 1);
    });

    it('returns a number greater than zero', () => {
      expect(randomNumber(2)).toBeGreaterThan(0);
    });
  });

  describe('randomNumberBetween', () => {
    const min = 5;
    const max = 10;
    it('returns a number', () => {
      expect(typeof randomNumberBetween(min, max)).toEqual('number');
    });

    it('returns an integer', () => {
      const num = randomNumberBetween(min, max);
      expect(Math.round(num)).toEqual(num);
    });

    it('returns a number less or equal to the max number passed', () => {
      expect(randomNumberBetween(min, max)).toBeLessThan(max + 1);
    });

    it('returns a number greater or equal to the min number passed', () => {
      expect(randomNumberBetween(min, max)).toBeGreaterThan(min - 1);
    });
  });

  describe('getRandom', () => {
    it('gets a random number from an array', () => {
      const arr = getNumberArray(10);
      expect(arr).toContain(getRandom(arr));
    });

    it('gets a random string from an array', () => {
      const arr = getNumberArray(20).map(String);
      expect(arr).toContain(getRandom(arr));
    });
  });

  describe('getRandomName', () => {
    it('returns a string', () => {
      expect(typeof getRandomName(10)).toEqual('string');
    });

    it('returns the right number of underscore-separated words', () => {
      expect(getRandomName(10).split('_')).toHaveLength(10);
    });

    it('returns the right number of space-separated words', () => {
      expect(getRandomName(50, ' ').split(' ')).toHaveLength(50);
    });
  });

  describe('getRandomSelection', () => {
    const arr = [1, 2, 3, 4, 5];

    it('returns an array', () => {
      expect(getRandomSelection(arr, 1)).toEqual(
        expect.arrayContaining([expect.any(Number)])
      );
    });

    it('returns an array of length n', () => {
      expect(getRandomSelection(arr, 2)).toHaveLength(2);
    });

    it('returns the original array if n is greater than the array length', () => {
      expect(getRandomSelection(arr, 10)).toEqual(arr);
    });

    it('returns an array of items that were all contained in the original dataset', () => {
      expect(getRandomSelection(arr, 4).every((d) => arr.includes(d))).toBe(
        true
      );
    });

    it('does not return duplicates', () => {
      const result = getRandomSelection(arr, 4);
      expect(result).toEqual(result.filter(unique));
    });
  });

  describe('generateHash', () => {
    it('returns a string', () => {
      expect(generateHash(10)).toEqual(expect.any(String));
    });

    it('returns a string of length n', () => {
      const length = 100;
      expect(generateHash(length)).toHaveLength(length);
    });
  });
});

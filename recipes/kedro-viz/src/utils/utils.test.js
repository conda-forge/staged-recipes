import { arrayToObject, getUrl, unique, replaceMatches } from './index';

describe('utils', () => {
  describe('arrayToObject', () => {
    it('returns an empty object when given an empty array', () => {
      expect(arrayToObject([], () => {})).toEqual({});
    });

    it('returns an object with properties', () => {
      const callback = (foo) => foo.split('').reverse().join('');
      expect(arrayToObject(['foo'], callback)).toEqual({ foo: 'oof' });
    });
  });

  describe('getUrl', () => {
    it('should throw an error when passed an invalid argument', () => {
      expect(() => getUrl()).toThrow();
      expect(() => getUrl('unknown')).toThrow();
      expect(() => getUrl(null)).toThrow();
    });

    it('should return the "main" json file', () => {
      expect(getUrl('main')).toEqual('./api/main');
    });

    it('should return a "pipeline" json file', () => {
      const id = '123456';
      expect(getUrl('pipeline', id)).toEqual(`./api/pipelines/${id}`);
    });

    it('should include the node ID in the url', () => {
      const id = '123456';
      expect(getUrl('nodes', id)).toEqual(`./api/nodes/${id}`);
    });

    // This test exists because some of our users requested a relative path
    // so that that could run Kedro-Viz on a non-root URL
    it('should always return a relative path', () => {
      expect(getUrl('main').substr(0, 2)).toEqual('./');
      expect(getUrl('pipeline', 123).substr(0, 2)).toEqual('./');
    });
  });

  describe('unique', () => {
    it('removes duplicates from an array', () => {
      expect([1, 1, 2, 2, 3, 3, 1].filter(unique)).toEqual([1, 2, 3]);
    });
  });

  describe('replaceMatches', () => {
    const entitiesToReplace = {
      '&lt;': '<',
      '&gt;': '>',
    };

    it('replaces matched characters from a string', () => {
      expect(replaceMatches('&lt;lambda&gt;', entitiesToReplace)).toEqual(
        '<lambda>'
      );
    });
  });
});

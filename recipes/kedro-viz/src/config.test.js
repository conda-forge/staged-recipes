import { localStorageName, flags } from './config';

describe('config', () => {
  describe('localStorageName', () => {
    it('should contain KedroViz', () => {
      expect(localStorageName).toEqual(expect.stringContaining('KedroViz'));
    });
  });

  describe('flags', () => {
    test.each(Object.keys(flags))(
      'flags.%s should be an object with description, default and icon keys',
      (key) => {
        expect(flags[key]).toEqual(
          expect.objectContaining({
            description: expect.any(String),
            default: expect.any(Boolean),
            icon: expect.any(String),
          })
        );
      }
    );
  });
});

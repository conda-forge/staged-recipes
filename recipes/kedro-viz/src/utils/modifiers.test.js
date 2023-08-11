import modifiers from './modifiers';

describe('modifiers classname utility', () => {
  it('returns just the classname when no modifiers passed', () => {
    // pass `undefined`, null, empty modifiers object
    expect(modifiers('test-name')).toEqual('test-name');
    expect(modifiers('test-name', null)).toEqual('test-name');
    expect(modifiers('test-name', {})).toEqual('test-name');
  });

  it('returns the classname and modifier for `true`', () => {
    expect(modifiers('test-name', { id: true })).toEqual(
      'test-name test-name--id'
    );
  });

  it('returns the classname and negated modifier for `false`, `undefined` and `null`', () => {
    expect(modifiers('test-name', { id: false })).toEqual(
      'test-name test-name--no-id'
    );
    expect(modifiers('test-name', { id: undefined })).toEqual(
      'test-name test-name--no-id'
    );
    expect(modifiers('test-name', { id: null })).toEqual(
      'test-name test-name--no-id'
    );
  });

  it('returns the classname and `modifier`-`value` for strings', () => {
    expect(modifiers('test-name', { id: 'abcd' })).toEqual(
      'test-name test-name--id-abcd'
    );
  });

  it('returns the classname and `modifier`-`value` for numbers', () => {
    expect(modifiers('test-name', { id: 7 })).toEqual(
      'test-name test-name--id-7'
    );
  });

  it('handles `0` as a number (not falsy)', () => {
    expect(modifiers('test-name', { id: 0 })).toEqual(
      'test-name test-name--id-0'
    );
  });

  it('replaces whitespace with `-` for string values', () => {
    expect(modifiers('test-name', { id: 'ab c d' })).toEqual(
      'test-name test-name--id-ab-c-d'
    );
  });

  it('returns the classname and modifiers for multiple mixed types', () => {
    expect(
      modifiers('test-name', {
        id: 0,
        type: 'mixed',
        big: true,
        small: false,
        'very-big': true,
      })
    ).toEqual(
      'test-name test-name--id-0 test-name--type-mixed test-name--big test-name--no-small test-name--very-big'
    );
  });

  it('returns the classname, modifiers and additional class name string if passed', () => {
    expect(
      modifiers('test-name', { big: true }, 'test-name-2 test-name-3')
    ).toEqual('test-name test-name--big test-name-2 test-name-3');
  });
});

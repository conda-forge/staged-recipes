import {
  Flags,
  getFlagsFromUrl,
  getFlagsMessage,
  getFlagsState,
} from './flags';

const testFlagName = 'testflag';
const privateFlagName = 'privateflag';
const testFlagDescription = 'testflag description';
const privateFlagDescription = 'private flag description';
const flagsEnabled = {
  [testFlagName]: true,
  [privateFlagName]: true,
};

jest.mock('../config', () => ({
  ...jest.requireActual('../config'),
  flags: {
    testflag: {
      name: 'test flag',
      description: 'testflag description',
      default: false,
      private: false,
      icon: '🤖',
    },
    privateflag: {
      name: 'private flag',
      description: 'private flag description',
      default: true,
      private: true,
      icon: '🙊',
    },
  },
}));

describe('flags', () => {
  it('getFlagsFromUrl enables flags', () => {
    expect(
      getFlagsFromUrl(`https://localhost:4141/?${testFlagName}=true`)
    ).toEqual({
      [testFlagName]: true,
    });

    expect(
      getFlagsFromUrl(`https://localhost:4141/?${testFlagName}=1`)
    ).toEqual({
      [testFlagName]: true,
    });

    expect(getFlagsFromUrl(`https://localhost:4141/?${testFlagName}`)).toEqual({
      [testFlagName]: true,
    });
  });

  it('getFlagsFromUrl disables flags', () => {
    expect(
      getFlagsFromUrl(`https://localhost:4141/?${testFlagName}=false`)
    ).toEqual({
      [testFlagName]: false,
    });

    expect(
      getFlagsFromUrl(`https://localhost:4141/?${testFlagName}=0`)
    ).toEqual({
      [testFlagName]: false,
    });
  });

  it('getFlagsMessage outputs a message describing flags', () => {
    expect(getFlagsMessage(flagsEnabled)).toContain(testFlagDescription);
  });

  it('getFlagsMessage does not include private flags', () => {
    expect(getFlagsMessage(flagsEnabled)).not.toContain(privateFlagDescription);
  });

  it('Flags.isDefined returns true if flag defined else false', () => {
    expect(Flags.isDefined(testFlagName)).toBe(true);
    expect(Flags.isDefined('definitelynotdefined')).toBe(false);
  });

  it('Flags.names returns list of defined flags names', () => {
    expect(Flags.names()).toEqual([testFlagName, privateFlagName]);
  });

  it('Flags.defaults returns an object mapping flag defaults', () => {
    expect(Flags.defaults()).toEqual({
      [testFlagName]: false,
      [privateFlagName]: true,
    });
  });

  it('get Flags data returns an object with flag names and description', () => {
    expect(getFlagsState()).toEqual([
      {
        name: 'test flag',
        description: 'testflag description',
        value: 'testflag',
      },
      {
        name: 'private flag',
        description: 'private flag description',
        value: 'privateflag',
      },
    ]);
  });
});

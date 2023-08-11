import getPipelineData, { getSourceID, getDataValue } from './data-source';
import spaceflights from './data/spaceflights.mock.json';
import demo from './data/demo.mock.json';

describe('getSourceID', () => {
  const OLD_ENV = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...OLD_ENV };
    delete process.env.REACT_APP_DATA_SOURCE;
  });

  afterEach(() => {
    process.env = OLD_ENV;
  });

  it("should return 'json' by default if no source is supplied", () => {
    expect(getSourceID()).toBe('json');
  });

  it('should return the given datasource if set via environment variable', () => {
    process.env.REACT_APP_DATA_SOURCE = 'spaceflights';
    expect(getSourceID()).toEqual('spaceflights');
    process.env.REACT_APP_DATA_SOURCE = 'demo';
    expect(getSourceID()).toEqual('demo');
  });
});

describe('getDataValue', () => {
  it('should return the correct dataset when passed a dataset string', () => {
    expect(getDataValue('spaceflights')).toEqual(spaceflights);
    expect(getDataValue('demo')).toEqual(demo);
  });

  it("should return the string 'json' when passed 'json'", () => {
    expect(getDataValue('json')).toEqual('json');
  });

  it("should return a dataset object when passed 'random'", () => {
    expect(getDataValue('random')).toEqual(
      expect.objectContaining({
        edges: expect.any(Array),
        nodes: expect.any(Array),
        tags: expect.any(Array),
        layers: expect.any(Array),
      })
    );
  });

  it('should throw an error if the given source is unknown', () => {
    expect(() => getDataValue('qwertyuiop')).toThrow();
    expect(() => getDataValue(null)).toThrow();
    expect(() => getDataValue(undefined)).toThrow();
  });
});

describe('getPipelineData', () => {
  const OLD_ENV = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...OLD_ENV };
    delete process.env.REACT_APP_DATA_SOURCE;
  });

  afterEach(() => {
    process.env = OLD_ENV;
  });

  it('should return "json" as the datasource if undefined', () => {
    expect(getPipelineData()).toBe('json');
  });

  it('should throw an error if the given source is unknown', () => {
    process.env.REACT_APP_DATA_SOURCE = 'qwertyuiop';
    expect(() => getPipelineData()).toThrow();
  });

  it('should return the given datasource if set', () => {
    process.env.REACT_APP_DATA_SOURCE = 'spaceflights';
    expect(getPipelineData()).toEqual(spaceflights);
  });

  it('should return random data if requested', () => {
    process.env.REACT_APP_DATA_SOURCE = 'random';
    expect(getPipelineData()).toEqual(expect.objectContaining({}));
  });
});

import loadData from './load-data';

describe('loadData', () => {
  it('returns a Promise', () => {
    expect(typeof loadData().then).toBe('function');
    expect(typeof loadData().catch).toBe('function');
  });
});

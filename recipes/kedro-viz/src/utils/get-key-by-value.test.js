import { getKeyByValue } from './get-key-by-value';

const mockObject = {
  key1: 'value1',
  key2: 'value2',
  key3: 'value3',
  key4: 'value4',
};

const mockValue = 'value3';

describe('getKeyByValue', () => {
  it('return the correct key for the value', () => {
    const expected = 'key3';
    const result = getKeyByValue(mockObject, mockValue);

    expect(result).toEqual(expected);
  });
});

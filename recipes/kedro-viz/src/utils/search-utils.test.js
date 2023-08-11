import { getValueRegex, getHighlightedText } from './search-utils';

test('getValueRegex should return a regular expression', () => {
  expect(getValueRegex()).toBe(false);
  expect(getValueRegex('')).toBe(false);
  expect(getValueRegex('foo').toString()).toBe('/(foo)/gi');
  expect(getValueRegex('<foo>').toString()).toBe('/(\\<foo\\>)/gi');
});

test('getHighlightedText should highlight search terms', () => {
  const text = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
  const match1 = getHighlightedText(text, 'AmEt');
  const match2 = getHighlightedText(text, 'lor');
  const fail = getHighlightedText(text, 'qwertyuiop');

  // Check successful matches
  expect(match1.match(/<b>/g)).toHaveLength(1);
  expect(match2.match(/<b>/g)).toHaveLength(2);
  expect(match1.match(/<b>(\w+)<\/b>/)[1]).toBe('amet');
  // Check failed match
  expect(fail.match(/<b>/g)).toBe(null);
});

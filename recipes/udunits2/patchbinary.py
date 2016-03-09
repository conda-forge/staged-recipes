#!/usr/bin/env python
'''
Perform string replacement operations on a binary file strings that end in
null-terminators.
:author: Dan Blanchard (dblan...@ets.org)
:date: March 2014
'''
from __future__ import print_function, unicode_literals
import argparse
import re
import sys
from io import open
from locale import getpreferredencoding
def replace_with_null(pattern, replacement, search_bytes, exact=False,
                      regex=False):
    '''
    Replaces all instances of ``pattern`` in ``search_bytes`` with
    ``replacement``.
    :param pattern: The string we are trying to find to replace.
    :type pattern: bytes
    :param replacement: The string we are going to replace pattern with.
    :type replacement: bytes
    :param search_bytes: The byte string to perform replacement on.
    :type search_bytes: bytes
    :param exact: If ``exact`` is ``False``, only perform replacement when
                  ``pattern`` is immediately followed by a null-terminator.
    :type exact: bool
    :returns: A copy of ``search_bytes`` with all instances of ``pattern``
              replaced with ``replacement``.
    :rtype: bytes
    '''
    patched_bytes = bytearray(search_bytes)
    # Escape patterns if they're not regular expressions
    if not regex:
        pattern = re.escape(pattern)
    # String must be immediately followed by null-terminator if we're looking
    # for exact match
    if exact:
        pattern += b'(?=\\x00)'
    else:
        pattern += b'(?P<byte_suffix>[^\\x00]*?)(?=\\x00)'
        replacement += b'\\g<byte_suffix>'
    # Find all instances of pattern and replace them in patched_bytes
    for match in re.finditer(pattern, search_bytes):
        expanded_replacement = match.expand(replacement)
        pad_len = len(match.group()) - len(expanded_replacement)
        if pad_len >= 0:
            expanded_replacement += b'\x00' * pad_len
        else:
            print(('WARNING: Cannot replace {0} with longer string' +
                   ' {1}!').format(repr(match.string),
                                   repr(expanded_replacement)),
                  file=sys.stderr)
        # print('Replacing {0} with {1}'.format(repr(match.group()),
        #                                       repr(expanded_replacement)),
        #       file=sys.stderr)
        patched_bytes[match.start():match.end()] = expanded_replacement
    return bytes(patched_bytes)
def main(argv=None):
    '''
    Process the command line arguments and print out a copy of input with
    replacements made.
    :param argv: List of arguments, as if specified on the command-line.
                 If None, ``sys.argv[1:]`` is used instead.
    :type argv: list of str
    '''
    encoding = getpreferredencoding()
    # Get command line arguments
    parser = argparse.ArgumentParser(
        description="Perform string replacement operations on a binary file \
                     with strings that end in null-terminators.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        conflict_handler='resolve')
    parser.add_argument('pattern',
                        help='The string we are trying to find to replace.')
    parser.add_argument('replacement',
                        help='The string we are going to replace pattern with.')
    parser.add_argument('input_file',
                        help='The file to perform in-place replacements on. If \
                              unspecified, will use STDIN.',
                        type=argparse.FileType('rb'), default=sys.stdin,
                        nargs='?')
    parser.add_argument('-e', '--encoding',
                        help='Encoding to use for strings that are being \
                              inserted into file. Use locale-preferred encoding\
                              by default.',
                        default=encoding)
    parser.add_argument('-E', '--exact',
                        help='Pattern must be immediately followed by \
                              null-terminator to count as a match. Otherwise, \
                              it is assumed that there may be any number of \
                              non-null characters following the pattern that \
                              should be maintained after replacement.',
                        action='store_true')
    parser.add_argument('-r', '--regex',
                        help='The pattern and replacement strings are regular\
                              expressions.',
                        action='store_true')
    args = parser.parse_args(argv)
    # Convert strings to bytes
    args.pattern = args.pattern.encode(encoding)
    args.replacement = args.replacement.encode(encoding)
    if args.input_file.isatty():
        print("You are running patchbinary interactively. Press CTRL-D at the" +
              " start of a blank line to signal the end of your input. If you" +
              " want help, run ./patchbinary.py --help\n\n", file=sys.stderr)
    elif args.input_file == sys.stdin:
        output_file_name = '-'
    else:
        output_file_name = args.input_file.name
    # Read in original data, saving a copy so we can overwrite file
    orig_data = args.input_file.read()
    args.input_file.close()
    new_data = replace_with_null(args.pattern, args.replacement, orig_data,
                                 exact=args.exact, regex=args.regex)
    # Perform replacements and write output
    with open(output_file_name, 'wb') as output_file:
        output_file.write(new_data)

if __name__ == '__main__':
    main()


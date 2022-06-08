# this script is from the conda-forge/python-feedstock and is used to massage one
# of the patches here


import sys
import re
import tempfile
import shutil


# Reads from argv[1] line-by-line, writes to same file. The patch
# header lines are given LF line endings and the rest CRLF line endings.
# Does not currently deal with the prelude (up to the -- in git patches).

def main(argv):
    filename = argv[1]
    lines = []
    with open(filename, 'rb') as fi:
        try:
            for line in fi:
                line = line.decode('utf-8').strip('\n').strip('\r\n')
                lines.append(line)
        except:
            pass
        is_git_diff = False
        for line in lines:
            if line.startswith('diff --git'):
                is_git_diff = True
        in_real_patch = False if is_git_diff else True

    text = "\n".join(lines)

    # if ".bat" not in text and ".vcxproj" not in text and ".props" not in text:
    #     return

    with open(filename, 'wb') as fo:
        for i, line in enumerate(lines):
            if not in_real_patch:
                fo.write((line + '\n').encode('utf-8'))
                if line.startswith('diff --git'):
                    in_real_patch = True
            else:
                if line.startswith('diff ') or \
                        line.startswith('diff --git') or \
                        line.startswith('--- ') or \
                        line.startswith('+++ ') or \
                        line.startswith('@@ ') or \
                        line.startswith('index ') or \
                        (i < len(lines) - 1 and lines[i+1].startswith("\ No newline at end of file")):
                    fo.write((line + '\n').encode('utf-8'))
                else:
                    fo.write((line + '\r\n').encode('utf-8'))


if __name__ == '__main__':
    main(sys.argv)

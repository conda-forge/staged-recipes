#!/bin/bash

set -eux -o pipefail

# based on https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/libid3tag.rb

cat >test_libid3tag.c <<EOF
#include <id3tag.h>
int main(int n, char** c) {
   struct id3_file *fp = id3_file_open("test.mp3", ID3_FILE_MODE_READONLY);
   struct id3_tag *tag = id3_file_tag(fp);
   struct id3_frame *frame = id3_tag_findframe(tag, ID3_FRAME_TITLE, 0);
   id3_file_close(fp);
   return 0;
}
EOF


pkg_config_cflags=$(pkg-config --cflags --libs id3tag)
${CC} "test_libid3tag.c" ${pkg_config_cflags} "-o" "test_libid3tag"
"./test_libid3tag"

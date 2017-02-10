#!/bin/bash
set -ex

cat > testprog.rl << EOF
#include <stdio.h>
#include <string.h>

%%{
  machine ragel_test;
  main := ( 'r' @ { printf("ragel"); }
          | 't' @ { printf("test"); }
          )*;
}%%

%% write data;

int main(int argc, char **argv) 
{
  int cs, res = 0;
  if (argc > 1) {
    char *p = argv[1];
    char *pe = p + strlen(p) + 1;
    %% write init;
    %% write exec;
  }
}
EOF

ragel -Cs testprog.rl

gcc testprog.c -o testprog

OUTPUT=$(./testprog rttr)

if [ "$OUTPUT" != "rageltesttestragel" ]; then
  echo "test failed"
  exit 1
fi

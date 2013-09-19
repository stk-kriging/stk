#!/bin/bash

find . -type f                                                      \
\(                                                                  \
  -name "*.m"  -o -name "*.c" -o -name "*.h"   -o -name "*.html" -o \
  -name README -o -name TODO  -o -name LICENSE -o                   \
  -name CODING_GUIDELINES     -o -name ChangeLog                    \
\)                                                                  \
-exec                                                               \
  sed -i -e "s/\r$//" {} \;

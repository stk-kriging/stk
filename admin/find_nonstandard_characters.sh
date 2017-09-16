#!/bin/bash

find . -type f                                                                \
\(                                                                            \
  -name "*.m"      -o -name "*.c"       -o -name "*.h"   -o -name "*.html" -o \
  -name "*README*" -o -name AUTHORS.md  -o -name COPYING -o -name NEWS.md  -o \
  -name CODING_GUIDELINES               -o -name ChangeLog                    \
\)                                                                            \
-exec                                                                         \
  grep -PHn --color -r '[^\x00-\x7F]' {} \;

# Note: \x00-\x7F is the range for plain ASCII characters

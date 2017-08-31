#!/bin/bash

find . -type f                                                          \
\(                                                                      \
  -name "*.m"      -o -name "*.c" -o -name "*.h"   -o -name "*.html" -o \
  -name "*README*" -o -name TODO  -o -name COPYING -o -name NEWS.md  -o \
  -name CODING_GUIDELINES         -o -name ChangeLog                    \
\)                                                                      \
-exec                                                                   \
  grep -PHn --color -r '[^\x00-\x7F]' {} \;

# Notes:
#  * \x00-\x7F is the range for ASCII characters
#  * \xA0-\xFF is the subset of the range \0x80-\0xFF that has the same
#    meaning in both ISO-8859-1 and Windows-1252.

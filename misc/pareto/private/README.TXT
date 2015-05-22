Lyndon While, Lucas Bradstreet, Luigi Barone 

Email lyndon.while@uwa.edu.au for any queries regarding usage/bugs/improvements. 

This code includes a high performance implementation of the WFG algorithm, 
used to calculate the hypervolume indicator for a set of non-dominated points. 


COMPILING: 

make march=processortype, e.g. make march=pentium 


USAGE: 

wfg FRONTFILE 
# calculates the hypervolumes of the fronts in FRONTFILE, using the reference point 0, 0, ..., 0 
wfg FRONTFILE r1 r2 .. rd 
# calculates the hypervolumes of the fronts in FRONTFILE, using the reference point r1, r2, .., rd 

Each objective can be minimised or maximised independently. 
The code detects automatically whether each objective is being maximised or minimised. 


FILE FORMAT: 

A file can contain any number of fronts, laid out as follows: 

#
0.598 0.737 0.131 0.916 6.745
0.263 0.740 0.449 0.753 6.964
0.109 8.483 0.199 0.302 8.872
#
0.598 0.737 0.131 0.916 6.745
0.263 0.740 0.449 0.753 6.964
0.109 8.483 0.199 0.302 8.872
#

Notes: 

- objective values are separated by spaces; 
- one point per line; 
- fronts are separated by #s; 
- all fronts use the same reference point, therefore all points in all fronts must have the same number of objectives. 

No error-checking is performed, specifically: 

- in each front, all points are assumed to be mutually non-dominating; 
- for each objective in each front, all values are assumed to lie on the same side of the reference point (i.e. all >= or all <=). 


COPYRIGHT: 

This software is Copyright (C) 2010 Lyndon While, Lucas Bradstreet. 

This program is free software (software libre). You can redistribute it and/or modify it under 
the terms of the GNU General Public License as published by the Free Software Foundation; 
either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU General Public License for more details. 

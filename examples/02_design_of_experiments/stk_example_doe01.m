% STK_EXAMPLE_DOE01 displays several two-dimensional designs
%
% All designs are constructed on the hyper-rectangle BOX = [0; 2] x [0; 4].
%
% Examples of the following designs are shown:
%  a) Regular grid                         --> stk_sampling_regulargrid,
%  b) "Maximin" latin hypercube sample     --> stk_sampling_maximinlhs,
%  c) RR2-scrambled Halton sequence        --> stk_sampling_halton_rr2,
%  d) Uniformly distributed random sample  --> stk_sampling_randunif.

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

stk_disp_examplewelcome

DIM = 2;           % dimension of the factor space
BOX = [0 0; 2 4];  % factor space
N   = 49;          % size of the space-filling designs

figure;  set (gcf, 'Name', sprintf ('Several designs with N = %d', N));


%% Regular grid

x = stk_sampling_regulargrid (N, DIM, BOX);
subplot (2, 2, 1);  plot (x(:, 1), x(:, 2), '*');
title ('a) Regular grid');


%% "Maximin" Latin Hypercube samples

x = stk_sampling_maximinlhs (N, DIM, BOX);
subplot (2, 2, 2);  plot (x(:, 1), x(:, 2), '*');
title ('b) "Maximin" LHS');


%% Halton sequence with RR2 scrambling

x = stk_sampling_halton_rr2 (N, DIM, BOX);
subplot (2, 2, 3);  plot (x(:, 1), x(:, 2), '*');
title ('c) Halton-RR2');


%% Random (uniform) sampling

x = stk_sampling_randunif (N, DIM, BOX);
subplot (2, 2, 4);  plot (x(:, 1), x(:, 2), '*');
title ('d) Random');

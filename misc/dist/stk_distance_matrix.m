% STK_DISTANCE_MATRIX...
%
% FIXME: missing doc, copyright, ...

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%
%    This file has been adapted from runtests.m in Octave 3.6.2 (which is  
%    distributed under the GNU General Public Licence version 3 (GPLv3). 
%    The original copyright notice was as follows:
%
%        Copyright (C) 2010-2012 John W. Eaton
%
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

%%
% Check that an error is raised in nargin is not either 1 or 2

%!error stk_distance_matrix();
%!error stk_distance_matrix(0, 0, 0);
%!error stk_distance_matrix(0, 0, 0, 0);

%%
% Check that an error is raised when the number of columns differs

%!error stk_distance_matrix(0, ones(1, 2));
%!error stk_distance_matrix(eye(3), ones(1, 2));
%!error stk_distance_matrix(ones(2, 1), zeros(2));

%%
% Test with some simple matrices

%!shared x, y, z
%! x = zeros(11, 5);
%! y = zeros(13, 5);
%! z = ones(7, 5);

%!test
%! Dx = stk_distance_matrix(x);
%! assert(isequal(Dx, zeros(11)));

%!test
%! Dxx = stk_distance_matrix(x, x);
%! assert(isequal(Dxx, zeros(11)));

%!test
%! Dxy = stk_distance_matrix(x, y);
%! assert(isequal(Dxy, zeros(11, 13)));

%!test
%! Dzz = stk_distance_matrix(z, z);
%! assert(isequal(Dzz, zeros(7)));

%!test
%! Dxz = stk_distance_matrix(x, z);
%! assert(isequal(Dxz, sqrt(5)*ones(11, 7)));

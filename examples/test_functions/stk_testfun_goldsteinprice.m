% STK_TESTFUN_GOLDSTEINPRICE computes the Goldstein-Price function
%
%    The Goldstein-Price function [1] is a classical test function for
%    global optimization algorithms, which belongs to the well-known
%    Dixon-Szego test set [2].
%
%    It is usually minimized over [-2; 2] x [-2; 2]. It has a unique
%    global minimum at x = [0, -1] with f(x) = 3, and several local minima.
%
% REFERENCES
%
%  [1] Goldstein, A.A. and Price, I.F. (1971), On descent from local
%      minima. Mathematics of Computation, 25(115).
%
%  [2] Dixon L.C.W., Szego G.P. (1978), Towards Global Optimization 2,
%      North-Holland, Amsterdam, The Netherlands

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>
%
%    Based on the "Virtual Library for Simulation Experiments"
%       Copyright (C) 2013 Derek Bingham, Simon Fraser University
%       Authors: Sonja Surjanovic & Derek Bingham (dbingham@stat.sfu.ca)
%       Distributed under the GPLv2 licence
%       http://www.sfu.ca/~ssurjano/Code/goldprm.html

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

function y = stk_testfun_goldsteinprice (x)

if nargin == 0,
    visu_goldsteinprice ();
    return;
end

x = double (x);

x1 = x(:, 1);
x2 = x(:, 2);

x1x1 = x1 .^ 2;
x2x2 = x2 .^ 2;
x1x2 = x1 .* x2;

A1 = (x1 + x2 + 1) .^ 2;
A2 = 19 - 14*x1 + 3*x1x1 - 14*x2 + 6*x1x2 + 3*x2x2;
A  = 1 + A1 .* A2;  % 4th degree polynomial

B1 = (2*x1 - 3*x2) .^ 2;
B2 = 18 - 32*x1 + 12*x1x1 + 48*x2 - 36*x1x2 + 27*x2x2;
B  = 30 + B1 .* B2;  % 4th degree polynomial

y = A .* B;  % 8th degree polynomial

end % function


function visu_goldsteinprice ()

s = 'Goldstein-Price function';  stk_figure (s);

xt = stk_sampling_regulargrid (80^2, 2, [[-2; 2], [-2; 2]]);
xt.colnames = {'x_1', 'x_2'};

surf (xt, @stk_testfun_goldsteinprice);
hold on;  plot3 (0, -1, 3, 'r.');
colorbar;  stk_title (s);

end % function


%!test % Use with nargin == 0 for visualisation
%! stk_testfun_goldsteinprice ();  close all;

%!assert (stk_isequal_tolabs ...
%! (stk_testfun_goldsteinprice ([0, -1]), 3.0, 1e-12))

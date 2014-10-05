% STK_PLOT1D is a convenient plot function for 1D kriging predictions
%
% CALL: stk_plot1d (obsi, obst, pred)
%
% -=-=-= doc from default branch -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
%
% CALL: stk_plot1d (XI, ZI, XT, ZT, ZP)
%
%    plots the evaluation points (XI, ZI), the "true function" with values
%    ZT on the grid XT, and a representation of the prediction ZP on the
%    same grid XT: the kriging prediction (posterior mean) surrounded by a
%    shaded area corresponding to 95% pointwise confidence intervals.
%
%    It is possible to omit plotting either the observations (XI, ZI) or
%    the true function ZT by providing empty matrices.
%
% CALL: stk_plot1d (XI, ZI, XT, ZT, ZP, ZSIM)
%
%    also plots a set ZSIM of samplepaths.

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@supelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function stk_plot1d (obsi, obst, pred, zsim)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Shaded area representing pointwise confidence intervals
if (nargin > 2) && (~ isempty (pred)),
    stk_plot_shadedci (pred.x, pred.z);
    hold on;
end
    
% Plot sample paths
if (nargin > 3) && (~ isempty (zsim))
    plot (pred.x, zsim, '-',  'LineWidth', 1, 'Color', [0.39, 0.47, 0.64])
    hold on;
end
    
% Ground truth
if (nargin > 1) && (~ isempty (obst))
    plot (obst.x, obst.z, '--', 'LineWidth', 3, 'Color', [0.39, 0.47, 0.64]);
    hold on;
end
    
% Kriging predictor (posterior mean)
if (nargin > 2) && (~ isempty (pred))
    plot (pred.x, pred.z.mean, 'LineWidth', 4, 'Color', [0.95 0.25 0.3]);
    hold on;
end

% Evaluations
if ~ isempty (obsi)
    plot (obsi.x, obsi.z, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
end

hold off;  set (gca, 'box', 'off');  legend off;

end % function stk_plot1d

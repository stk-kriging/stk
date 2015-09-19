% STK_PLOT_SHADEDCI represents pointwise confidence itervals using a shaded area

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function h = stk_plot_shadedci (x, z)

x = double (x);

delta = 1.96 * sqrt (abs (z.var));
h = area (x, [z.mean - delta, 2 * delta]);

% Remove the first area object (between 0 and z.mean - delta)
delete (h(1));  h = h(2);

c = [0.8 0.8 0.8];  % Light gray
set (h, 'FaceColor', c, 'LineStyle', '-', 'LineWidth', 1, 'EdgeColor', c);

% Raise current axis to the top layer, to prevent it
% from being hidden by the grayed area
set (gca, 'Layer', 'top');

end % function stk_plot_shadedci

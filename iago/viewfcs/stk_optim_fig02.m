% STK_OPTIM_FIG02 ...

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Authors:  Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%              Julien Bect       <julien.bect@supelec.fr>

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

function stk_optim_fig02 (algo, crit_xg)

figure (algo.disp_fignum_base + 2);

% x-axis: actual x-values in 1D, indices otherwise
[~, idx_min] = min(crit_xg);
if algo.dim == 1,
    xx = algo.xg0;
    xnew = algo.xg0(idx_min, :);
    xlab = 'x';
else
    xx = (1:(stk_length (algo.xg0)))';
    xnew = idx_min;
    xlab = 'index';
end

% Plot criterion
plot (xx, crit_xg, 'r', 'LineWidth', 2);  hold on;

% Plot position of next evaluation
plot (xnew * [1 1], ylim, '--', 'Color', 0.2 * [1 1 1]);  hold off;

% Set y-lim
Jmin = min (crit_xg);
Jmax = max (crit_xg);
deltaJ = Jmax - Jmin;
if deltaJ > 0,
    Jmin = Jmin - 0.05 * deltaJ;
    Jmax = Jmax + 0.05 * deltaJ;
    ylim ([Jmin Jmax]);
end

stk_labels (xlab, 'J(x)');
stk_title ('Sampling criterion');

drawnow;

end % function

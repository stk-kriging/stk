% STK_PLOT_PREDVSOBS plots predictions against observations
%
% CALL: H = stk_plot_predvsobs (Z_OBS, Z_PRED, ...)
%
% CALL: H = stk_plot_predvsobs (H_AXES, Z_OBS, Z_PRED, ...)
%
% See also stk_predict_leaveoneout, stk_example_kb10

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function h = stk_plot_predvsobs (varargin)

[h_axes, varargin, n_argin] = stk_plot_getaxesarg (varargin{:});

if n_argin >= 2
    y = varargin{1};
    y_pred = varargin{2};
    opts = varargin(3:end);
else
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

% Extract numerical predictions
try
    y_pred = y_pred.mean;
catch
    y_pred = double (y_pred);
end

% Plot prediction versus truth
h.data = plot (h_axes, y, y_pred, 'kd');  hold on;

% Plot "reference" line y_LOO = y
h.refline = plot (h_axes, xlim, xlim, 'r--');

% Apply options
if ~ isempty (opts)
    set (h.data, opts{:});
end

% Create labels
h_labels = stk_labels (h_axes, 'observations', 'predictions');
h.xlabel = h_labels(1);
h.ylabel = h_labels(2);

end % function

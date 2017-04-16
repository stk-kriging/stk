% STK_PLOT_HISTNORMRES plots an histogram for normalized residuals
%
% CALL: H = stk_plot_histnormres (NORM_RES, ...)
%
% CALL: H = stk_plot_histnormres (H_AXES, NORM_RES, ...)
%
% See also stk_predict_leaveoneout, stk_example_kb10

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
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

function h = stk_plot_histnormres (varargin)

[h_axes, varargin, n_argin] = stk_plot_getaxesarg (varargin{:});

if n_argin >= 1
    norm_res = double (varargin{1});
    opts = varargin(2:end);
else
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

% Ignore infinite normalized residuals, with a warning
b = isinf (norm_res);
if any (b)
    warning (sprintf ('Ignoring %d infinite normalized resiudals.', sum (b)));
    norm_res = norm_res(~ b);
end

% Choose the number of bins using the Freedman-Diaconis rule
n = length (norm_res);
q = quantile (norm_res, [0 0.25 0.75 1]);
binsize = 2 * (q(3) -q(2)) * (n ^ (- 1/3));
nbins = ceil ((q(4) - q(1)) / binsize);

% Compute and plot histogram pdf
[count, rr] = hist (norm_res, nbins);
pdf = count / (n * (rr(2) - rr(1)));
h.hist = bar (rr, pdf, 'hist');  hold on;

% Center view
M = max (3, max (abs (xlim ())));  xlim ([-M, M]);

% Plot reference N(0, 1) pdf
rr = linspace (-M, M, 100);
pdf_ref = 1 / (sqrt (2 * pi)) * (exp (- 0.5 * (rr .^ 2)));
h.ref_pdf = plot (rr, pdf_ref, 'r--');

% Apply options
if ~ isempty (opts)
    set (h.hist, opts{:});
end

% Create labels
h_labels = stk_labels (h_axes, 'normalized residuals', 'probability density');
h.xlabel = h_labels(1);
h.ylabel = h_labels(2);

end % function

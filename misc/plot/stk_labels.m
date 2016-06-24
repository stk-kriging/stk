% STK_LABELS [STK internal]
%
% STK_LABELS is a shortcut for stk_xlabel + stk_ylabel.

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
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

function h_labels = stk_labels (varargin)

% Extract axis handle (if it is present)
[h_axes, varargin, n_argin] = stk_plot_getaxesarg (varargin{:});

if n_argin < 2,
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

xlab = varargin{1};
ylab = varargin{2};
options = varargin(3:end);

h_labels = zeros (2, 1);
h_labels(1) = stk_xlabel (h_axes, xlab, options{:});
h_labels(2) = stk_ylabel (h_axes, ylab, options{:});

end % function

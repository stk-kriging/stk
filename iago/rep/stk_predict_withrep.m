% STK_PREDICT_WITHREP ...

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function varargout = stk_predict_withrep (model, xi, zi, xt)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% NOTE: the fact that we need to write such a function shows that
%   we should have a dedicated class for these three-columnd dataframes
%   for which we could implement stk_predict (and probably other things too)

[model, zi] = stk_fakenorep (model, zi);

varargout = cell (1, max (1, nargout));

[varargout{:}] = stk_predict (model, xi, zi, xt);

end % function stk_predict_withrep

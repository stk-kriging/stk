% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
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

function varargout = stk_get_param(cov, varargin)

switch length(varargin)
    case 0,
        idx = [];
    case 1,
        idx = varargin{1};
    otherwise
        stk_error('Incorrect number of arguments', 'IncorrectNumberOfArgs');
end


F = cov.get_param;

if ~iscell(idx), % single index
    idx = {idx};
end

varargout = cell(size(idx));
for i = 1:numel(idx)
    varargout{i} = get_param_(F, cov.param_, idx{i});
end

end % function stk_get_param


function t = get_param_(F, param, idx)

if isempty(idx), % "full parameter"
    t = param;
elseif isempty(F), % no getter available
    if isa(idx, 'double') % try direct indexing
        t = param(idx);
    else
        stk_error('Invalid parameter idx.', 'InvalidArgument');
    end
else % user user-provided setter
    t = F(param, idx);
end

end % function get_param_
% STK_SETOBS set observations
%
% CALL: MODEL = stk_setobs(MODEL, OBS)
%
%   returns a structure MODEL with observations set to OBS
%
% CALL: MODEL = stk_setobs(MODEL, X, Z)
%
%   returns a structure MODEL with observations set to (X, Z).
%
% See also stk_makedata, stk_model, ...

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function model = stk_setobs(model, varargin)

if nargin == 2,
    xz = varargin{1};
elseif nargin == 3,
    xz = stk_makedata(varargin{1}, varargin{2});
else
    errmsg = 'Incorrect number of input arguments';
    stk_err(errmsg, 'IncorrectNbInputArgs');
end

model.domain.dim   = size(xz.x.a, 2);
model.observations = xz;

end % function stk_setobs

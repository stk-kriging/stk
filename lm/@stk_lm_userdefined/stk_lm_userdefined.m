% STK_LM_USERDEFINED ... [FIXME: missing documentation]

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
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

function lm = stk_lm_userdefined(feval_handler)

if nargin == 0,
    % default constructor
    lm = struct('feval_handler', []);
else
    lm = struct('feval_handler', feval_handler);
end

lm = class(lm, 'stk_lm_userdefined', stk_lm());

end % function stk_lm_userdefined

%!test %%% Default constructor
%!   lm = stk_lm_userdefined(); assert(isa(lm, 'stk_lm_userdefined'));

%!test %%% Handler = @sin
%!   lm = stk_lm_userdefined(@sin); 
%!   assert(isa(lm, 'stk_lm_userdefined'));
%!   assert(isequal(sin(1.2), feval(lm, 1.2)));

%!test %%% Same test with handler = 'sin'
%!   lm = stk_lm_userdefined('sin'); 
%!   assert(isa(lm, 'stk_lm_userdefined'));
%!   assert(isequal(sin(1.2), feval(lm, 1.2)));

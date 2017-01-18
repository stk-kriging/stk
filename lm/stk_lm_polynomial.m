% STK_LM_POLYNOMIAL creates a polynomial linear model object
%
% CALL: LM = STK_LM_POLYNOMIAL (D)
%
%    creates a polynomial linear model object LM of degree D.

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
%    Copyright (C) 2012-2014 SUPELEC
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

function lm = stk_lm_polynomial (order)

% nargin check neded here.  See https://sourceforge.net/p/kriging/tickets/52.
if nargin < 1
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
elseif nargin > 1
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

switch order
    
    case -1, % 'simple' kriging
        lm = stk_lm_null ();
        
    case 0, % 'ordinary' kriging
        lm = stk_lm_constant ();
        
    case 1, % affine trend
        lm = stk_lm_affine ();
        
    case 2, % quadratic trend
        lm = stk_lm_quadratic ();
        
    case 3, % cubic trend
        lm = stk_lm_cubic ();
        
    otherwise, % syntax error
        stk_error ('order should be in {-1, 0, 1, 2, 3}', 'InvalidArgument');
end

end % function


%!error lm = stk_lm_polynomial ();
%!error lm = stk_lm_polynomial (0, 3.33);

%!test
%! lm = stk_lm_polynomial (-1);
%! assert (isa (lm, 'stk_lm_null'));

%!test
%! lm = stk_lm_polynomial (0);
%! assert (isa (lm, 'stk_lm_constant'));

%!test
%! lm = stk_lm_polynomial (1);
%! assert (isa (lm, 'stk_lm_affine'));

%!test
%! lm = stk_lm_polynomial (2);
%! assert (isa (lm, 'stk_lm_quadratic'));

%!test
%! lm = stk_lm_polynomial (3);
%! assert (isa (lm, 'stk_lm_cubic'));

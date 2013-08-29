% STK_LM ... [FIXME: missing documentation]

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

function lm = stk_lm(type, varargin)

if nargin == 0,
    % default constructor
    lm = class(struct(), 'stk_lm');
else
    switch lower(type)
        case {'null', 'zero', 'zeros'}
            lm = stk_lm_null(varargin{:});
        case {'constant', 'one', 'ones'}
            lm = stk_lm_constant(varargin{:});
        case {'poly1full', 'linear', 'full linear', 'affine', 'full affine'}
            lm = stk_lm_poly1full(varargin{:});
        case {'poly2full', 'quadratic', 'full quadratic'}
            lm = stk_lm_poly2full(varargin{:});
        case {'userdefined', 'user defined'}
            lm = stk_lm_userdefined(varargin{:});
        case 'matrix'
            lm = stk_lm_matrix(varargin{:});
        otherwise
            try
                lm = feval(type, varargin{:});
                assert(isa(lm, 'stk_lm'));
            catch %#ok<CTCH>
                stk_error('Unknown lm type.', 'IncorrectArgument');
            end
    end    
end

% sanity check
assert(isa(lm, 'stk_lm'));

end % function stk_lm

%!test %%% Default constructor
%!   lm = stk_lm();
%!   assert(isa(lm, 'stk_lm'));

%!error %%% @stk_lm/feval is virtual
%!   lm = stk_lm();
%!   feval(lm, 0.0);

%!test %%% Constructing an instance of the derived class stk_lm_null
%!   lm = stk_lm('null');
%!   assert(isa(lm, 'stk_lm'));
%!   assert(isa(lm, 'stk_lm_null'));

%!test %%% Constructing an instance of the derived class stk_lm_constant
%!   lm = stk_lm('constant');
%!   assert(isa(lm, 'stk_lm'));
%!   assert(isa(lm, 'stk_lm_constant'));

%!test %%% Constructing an instance of the derived class stk_lm_poly1full
%!   lm = stk_lm('affine');
%!   assert(isa(lm, 'stk_lm'));
%!   assert(isa(lm, 'stk_lm_poly1full'));

%!test %%% Constructing an instance of the derived class stk_lm_poly2full
%!   lm = stk_lm('quadratic');
%!   assert(isa(lm, 'stk_lm'));
%!   assert(isa(lm, 'stk_lm_poly2full'));

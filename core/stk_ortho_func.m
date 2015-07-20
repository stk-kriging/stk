% STK_ORTHO_FUNC  [deprecated]
%
% CALL: P = stk_ortho_func (MODEL, X)
%
%    computes the design matrix for the linear part of model MODEL at the set of
%    evaluation points X. In general (see special case below), X is expected to
%    be a structure, whose field 'a' contains the actual numerical data as an N
%    x DIM matrix, where N is the number of evaluation points and and DIM the
%    dimension of the space of factors. A matrix P of size N x L is returned,
%    where L is the number of regression functions in the linear part of the
%    model; e.g., L = 1 if MODEL.order is zero (ordinary kriging).
%
% DEPRECATED:
%
%    At the present time, stk_ortho_func() only handles polynomial regressions,
%    up to order 3 through the "historical" mechanism based on model.order.
%
%    An experimental mechanisme that uses "linear model" objects is already
%    available (see the code for details on how to activate this feature).
%
%    stk_orth_func is deprecated and will be removed from future versions of
%    STK (http://sourceforge.net/p/kriging/tickets/12).
%
% See also stk_make_matcov

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function P = stk_ortho_func (model, x)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

x = double (x);

if strcmp (model.covariance_type, 'stk_discretecov')
    P = model.param.P(x, :);
else
    if isfield (model, 'lm')
        %--- BEGIN EXPERIMENTAL FEATURE: linear model ------------------------------------
        if ~ isnan (model.order)
            error ('To use the EXPERIMENTAL "lm" feature, please set model.order to NaN');
        end
        P = feval (model.lm, x);
        %--- END EXPERIMENTAL FEATURE: linear model --------------------------------------
    else
        P = stk_ortho_func_ (model.order, x);
    end
end

end % function stk_ortho_func


%%%%%%%%%%%%%%%%%%%%%%%
%%% stk_ortho_func_ %%%
%%%%%%%%%%%%%%%%%%%%%%%

function P = stk_ortho_func_ (order, x)

n = size (x, 1);

switch order
    
    case -1, % 'simple' kriging
        P = zeros (n, 0);
        
    case 0, % 'ordinary' kriging
        P = ones (n, 1);
        
    case 1, % affine trend
        P = [ones(n, 1) x];
        
    case 2, % quadratic trend
        P = feval (stk_lm_quadratic, x);
        
    case 3, % cubic trend
        P = feval (stk_lm_cubic, x);
        
    otherwise, % syntax error
        error ('order should be in {-1, 0, 1, 2, 3}');
        
end

end % function stk_ortho_func_


%!shared model, x, n, d
%! n = 15; d = 4;
%! model = stk_model ('stk_materncov_aniso', d);
%! x = stk_sampling_randunif (n, d);

%!error P = stk_ortho_func ();
%!error P = stk_ortho_func (model);
%!test  P = stk_ortho_func (model, x);
%!error P = stk_ortho_func (model, x, pi);

%!test
%! model.order = -1;  P = stk_ortho_func (model, x);
%! assert (isequal (size (P), [n, 0]));

%!test
%! model.order =  0;  P = stk_ortho_func (model, x);
%! assert (isequal (size (P), [n, 1]));

%!test
%! model.order =  1;  P = stk_ortho_func (model, x);
%! assert (isequal (size (P), [n, d + 1]));

%!test
%! model.order =  2;  P = stk_ortho_func (model, x);
%! assert (isequal (size (P), [n, 1 + d * (d + 3) / 2]));

%!test
%! model.order =  3;  P = stk_ortho_func (model, x);
%! assert (isequal (size (P), [n, 1 + d * (11 + d * (6 + d)) / 6]));

%!error
%! model.order =  4;  P = stk_ortho_func (model, x);
%! % model.order > 3 is not allowed

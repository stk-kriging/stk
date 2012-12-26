% STK_ORTHO_FUNC computes the design matrix for the linear part of a model.
%
% CALL: P = stk_ortho_func(MODEL, X)
%
%    computes the design matrix for the linear part of model MODEL at the set of
%    evaluation points X. In general (see special case below), X is expected to
%    be a structure, whose field 'a' contains the actual numerical data as an N
%    x DIM matrix, where N is the number of evaluation points and and DIM the
%    dimension of the space of factors. A matrix P of size N x L is returned,
%    where L is the number of regression functions in the linear part of the
%    model; e.g., L = 1 for a constant mean (ordinary kriging).
%
% NOTE:
%
%    At the present time, stk_ortho_func() only handles polynomial regressions,
%    up to order 2.
%
% See also stk_make_matcov

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

function P = stk_ortho_func(model, x)
stk_narginchk(2, 2);

if isstruct(x), x = x.a; end

if ~model.private.config.use_cache, % SYNTAX: x(factors), model
    
    P = stk_ortho_func_(model.randomprocess.priormean.param, x);
    
else % SYNTAX: x(indices), model
    
    P = model.private.Px_cache(x, :);
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%
%%% stk_ortho_func_ %%%
%%%%%%%%%%%%%%%%%%%%%%%

function P = stk_ortho_func_(order, x)

[n,d] = size(x);

switch order
    
    case -1, % 'simple' kriging
        P = zeros(n, 0);
        
    case 0, % 'ordinary' kriging
        P = ones(n, 1);
        
    case 1, % linear trend
        P = [ones(n, 1) x];
        
    case 2, % quadratic trend
        P = [ones(n, 1) x zeros(n, d*(d+1)/2)];
        k = d + 2;
        for i = 1:d
            for j = i:d
                P(:,k) = x(:, i) .* x(:, j);
                k = k + 1;
            end
        end
        
    otherwise, % syntax error
        error('order should be in {-1,0,1,2}');
        
end

end

%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared model, x, n, d
%! n = 15; d = 4;
%! model = stk_model('stk_materncov_aniso', d);
%! x = stk_sampling_randunif(n, d);

%!error P = stk_ortho_func();
%!error P = stk_ortho_func(model);
%!test  P = stk_ortho_func(model, x);
%!error P = stk_ortho_func(model, x, pi);

%!test
%! model.randomprocess.priormean.param = -1; 
%! P = stk_ortho_func(model, x);
%! assert(isequal(size(P), [n, 0]));

%!test
%! model.randomprocess.priormean.param =  0;
%! P = stk_ortho_func(model, x);
%! assert(isequal(size(P), [n, 1]));

%!test
%! model.randomprocess.priormean.param =  1;
%! P = stk_ortho_func(model, x);
%! assert(isequal(size(P), [n, d + 1]));

%!test
%! model.randomprocess.priormean.param =  2;
%! P = stk_ortho_func(model, x);
%! assert(isequal(size(P), [n, 1 + d * (d + 3) / 2]));

%!error 
%! model.randomprocess.priormean.param =  3;
%! P = stk_ortho_func(model, x);
%! % polynomials of degree > 2 are not supported yet

% STK_MAKE_MATCOV computes a covariance matrix [DEPRECATED]
%
% This function is deprecated and will be removed in future versions of STK.
%
% Please use stk_covmat instead.
%
% See also: stk_covmat

% Copyright Notice
%
%    Copyright (C) 2015-2017 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function [K, P] = stk_make_matcov (model, x1, x2, pairwise)

switch nargin
    
    case {0, 1}
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
        
    case 2
        [K, P] = stk_covmat (model, 'response', x1);
        
    case 3
        [K, P] = stk_covmat (model, 'latent', x1, x2);
        
    case 4
        [K, P] = stk_covmat (model, 'latent', x1, x2, -1, pairwise);
        
    otherwise
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
        
end % switch

end % function


%!shared model, model2, x1, x2, n0, n1, d, Ka, Kb, Kc, Pa, Pb, Pc
%! n0 = 20;  n1 = 10;  d = 4;
%! model = stk_model ('stk_materncov52_aniso', d);
%! model.lm = stk_lm_affine;
%! model.param = log ([1.0; 2.1; 2.2; 2.3; 2.4]);
%! model2 = model;  model2.lognoisevariance = log(0.01);
%! x1 = stk_sampling_randunif (n0, d);
%! x2 = stk_sampling_randunif (n1, d);

%!error [KK, PP] = stk_make_matcov ();
%!error [KK, PP] = stk_make_matcov (model);
%!test  [Ka, Pa] = stk_make_matcov (model, x1);           % (1)
%!test  [Kb, Pb] = stk_make_matcov (model, x1, x1);       % (2)
%!test  [Kc, Pc] = stk_make_matcov (model, x1, x2);       % (3)
%!error [KK, PP] = stk_make_matcov (model, x1, x2, pi);

%!assert (isequal (size (Ka), [n0 n0]));
%!assert (isequal (size (Kb), [n0 n0]));
%!assert (isequal (size (Kc), [n0 n1]));

%!assert (isequal (size (Pa), [n0 d + 1]));
%!assert (isequal (size (Pb), [n0 d + 1]));
%!assert (isequal (size (Pc), [n0 d + 1]));

% In the noiseless case, (1) and (2) should give the same results
%!assert (isequal (Kb, Ka));

% In the noisy case, however...
%!test  [Ka, Pa] = stk_make_matcov (model2, x1);           % (1')
%!test  [Kb, Pb] = stk_make_matcov (model2, x1, x1);       % (2')
%!error assert (isequal (Kb, Ka));

% The second output depends on x1 only => should be the same for (1)--(3)
%!assert (isequal (Pa, Pb));
%!assert (isequal (Pa, Pc));

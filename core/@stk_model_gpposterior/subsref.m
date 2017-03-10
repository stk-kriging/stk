% SUBSREF [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
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

function value = subsref (M_post, idx)

if strcmp (idx(1).type, '.')
    
    value = get (M_post, idx(1).subs);
    
    if length (idx) > 1,
        value = subsref (value, idx(2:end));
    end
    
else
    
    stk_error ('Illegal indexing.', 'IllegalIndexing');
    
end

end % function


%!shared M_post, n
%! n = 15;
%! x_obs = (linspace (0, pi, n))';
%! z_obs = sin (x_obs);
%!
%! M_prior = stk_model ('stk_materncov32_iso');
%! M_prior.param = log ([1.0; 2.1]);
%!
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);

%!assert (isstruct (M_post.prior_model));
%!assert (isequal (size (M_post.input_data), [n 1]));
%!assert (isequal (size (M_post.output_data), [n 1]));
%!assert (isa (M_post.kreq, 'stk_kreq_qr'));

%!error M_post(1);
%!error M_post{1};

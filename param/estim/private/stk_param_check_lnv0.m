% STK_PARAM_CHECK_LNV0 [internal]

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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

function stk_param_check_lnv0 (model, lnv0)

% Remark: it is assumed in this function that model.lognoisevariance exists

% Check that there are no NaNs or Infs
lnv0_ = stk_get_optimizable_parameters (lnv0);
if any (isnan (lnv0_)) || any (isinf (lnv0_))
    stk_error (['Incorrect value for input argument lnv0.  The components of ' ...
        'the starting point must be neither infinite nor NaN.'], 'InvalidArgument');
end

% Check that lnv0 it is compatible with the given model
if isnumeric (lnv0)
    
    lnv1_ = stk_get_optimizable_noise_parameters (model);
    if length (lnv0) ~= length (lnv1_)
        s1 = sprintf ('model has %d optimizable noise parameters, ', length (lnv1_));
        s2 = sprintf ('but lnv0 has length %d', length (lnv0));
        s3 = '=> Incorrect length for input argument lnv0.';
        stk_error (sprintf ('%s%s\n%s', s1, s2, s3), 'InvalidArgument');
    end
    
else
    
    if ~ isequal (class (lnv0), class (model.lognoisevariance))
        stk_error ('Incorrect class for input argument lnv0.', 'InvalidArgument');
        % FIXME: Try to cast lnv0 to the class of model.lognoisevariance ?
    end
    
end

end % function


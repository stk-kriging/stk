% STK_DOMINATEHV computes the hypervolume dominated by a set of points
%
% CALL: HV = stk_dominatedhv (Y, Y_REF)
%
%    computes the hypervolume dominated by the rows of Y, with respect to the
%    reference point Y_REF (a row vector with the same number of columns as Y).
%    It is expected that all the rows of Y_DATA are smaller than Y
%    (multi-objective minimization framework).
%
% CALL: HV = stk_dominatedhv (Y)
%
%    uses [0 0 ... 0] as a reference point.
%
% NOTE:
%
%    This function relies internally of the WFG algorithm, release 1.10, by
%    Lyndon While, Lucas Bradstreet and Luigi Barone [1, 2].
%
% REFERENCES:
%
%   [1] Lyndon While, Lucas Bradstreet and Luigi Barone, "A Fast Way of
%       Calculating Exact Hypervolumes", IEEE Transactions on Evolutionary
%       Computation, 16(1):86-95, 2012
%       http://dx.doi.org/10.1109/TEVC.2010.2077298
%
%   [2] WFG 1.10, release under the GPLv2 licence, available online from:
%       http://www.wfg.csse.uwa.edu.au/hypervolume/
%
% See also: sortrows, stk_isdominated, stk_paretofind

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function hv = stk_dominatedhv (y, y_ref)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Ensure that y is a cell array
if ~ iscell (y),
    if (~ ismatrix (y))
        stk_error ('y should be a matrix or a cell array', 'IncorrectArgument');
    end
    y = {y};
end

% Missing or empty: will use [0 0 ... 0] as a reference point
if nargin < 2,
    y_ref = [];
elseif ~ isrow (y_ref)
    stk_error ('y_ref should be a row vector.', 'IncorrectSize');
end

% Pre-processing
y = cellfun (@(z) wfg_prepocessing (z, y_ref), y, 'UniformOutput', false);

hv = stk_dominatedhv_mex (y);

end % function stk_dominatedhv


function y = wfg_prepocessing (y, y_ref)

y = double (y);

p_ref = size (y_ref, 2);

if isempty (y_ref)  % Use [0 0 ... 0] as a reference point
    
    % WFG convention: maximization problem
    y = - y;
    
else  % Reference point provided
    
    p = size (y, 2);
    
    % Check the size of y
    if (p > p_ref)
        stk_error (['The number of columns the data matrix should not be ' ...
            'larger than the number of columns of y_ref'], 'IncorrectArgument');
    end
    
    % WFG convention: maximization problem
    y = bsxfun (@minus, y_ref(1:p), y);
    
end

if ~ all (y >= 0);
    stk_error ('All data points must be below the reference point', ...
        'IncorrectArgument');
end

end


%!shared y, hv0 % Example from README.TXT in WFg 1.10
%!
%! y = [ ...
%!     0.598 0.737 0.131 0.916 6.745; ...
%!     0.263 0.740 0.449 0.753 6.964; ...
%!     0.109 8.483 0.199 0.302 8.872 ];
%!
%! hv0 = 1.1452351120;

%!error hv = stk_dominatedhv ();
%!error hv = stk_dominatedhv (-y, [0 0 0 0 0], 'too many input args');

%!test
%! hv = stk_dominatedhv (-y);
%! assert (stk_isequal_tolrel (hv, hv0, 1e-10));

%!test
%! hv = stk_dominatedhv (-y, [0 0 0 0 0]);
%! assert (stk_isequal_tolrel (hv, hv0, 1e-10));

%!test
%! hv = stk_dominatedhv (1 - y, [1 1 1 1 1]);
%! assert (stk_isequal_tolrel (hv, hv0, 1e-10));

%!test
%! for d = 1:10,
%!    y = - 0.5 * ones (1, d);
%!    assert (isequal (stk_dominatedhv (y), 0.5 ^ d));
%! end

%!test
%! y1 = [0.25 0.75];
%! y2 = [0.50 0.50];
%! y3 = [0.75 0.25];
%!
%! y_ref = [1 1];
%!
%! y = {[], y1, y2, y3; [y1; y2], [y1; y3], [y2; y3], [y1; y2; y3]};
%!
%! dv = 0.25 ^ 2;
%!
%! hv0 = [0 3 4 3; 5 5 5 6] * dv
%! hv1 = stk_dominatedhv (y, y_ref)
%!
%! assert (isequal (hv0, hv1))

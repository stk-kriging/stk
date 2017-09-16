% STK_DOMINATEHV computes the hypervolume dominated by a set of points
%
% CALL: HV = stk_dominatedhv (Y, Y_REF)
% CALL: HV = stk_dominatedhv (Y, Y_REF, 0)
%
%    computes the hypervolume dominated by the rows of Y, with respect to the
%    reference point Y_REF (a row vector with the same number of columns as Y).
%    It is expected that all the rows of Y are smaller than Y_REF
%    (multi-objective minimization framework).
%
% CALL: HV = stk_dominatedhv (Y)
% CALL: HV = stk_dominatedhv (Y, [], 0)
%
%    uses [0 0 ... 0] as a reference point.
%
% CALL: DECOMP = stk_dominatedhv (Y, Y_REF, 1)
%
%    computes a signed decomposition of the dominated hyper-region delimited by
%    the reference point Y_REF into overlapping rectangles. Assuming that Y is
%    of size N x D, the result DECOMP is a structure with field .sign (N x 1),
%    .xmin (N x D) and .xmax (N x D). The hypervolume can be recovered from this
%    decomposition using
%
%      HV = sum (DECOMP.sign .* prod (DECOMP.xmax - DECOMP.xmin, 2))
%
%    provided that the resulting decomposition is not empty.
%
% CALL: HV = stk_dominatedhv (Y, [], 1)
%
%    computed a signed decomposition using [0 0 ... 0] as a reference point.
%
% NOTE:
%
%    This function relies internally on the WFG algorithm [1, 2].
%
% REFERENCES:
%
%   [1] Lyndon While, Lucas Bradstreet and Luigi Barone, "A Fast Way of
%       Calculating Exact Hypervolumes", IEEE Transactions on Evolutionary
%       Computation, 16(1):86-95, 2012
%       http://dx.doi.org/10.1109/TEVC.2010.2077298
%
%   [2] WFG 1.10, released under the GPLv2 licence, available online from:
%       http://www.wfg.csse.uwa.edu.au/hypervolume/
%
% See also: sortrows, stk_isdominated, stk_paretofind

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

function result = stk_dominatedhv (y, y_ref, do_decomposition)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Missing or empty y_ref: will use [0 0 ... 0] as a reference point
if nargin < 2,
    y_ref = [];
elseif ~ ((isnumeric (y_ref)) && ((isempty (y_ref)) || (isrow (y_ref))))
    stk_error ('y_ref should be a numeric row vector.', 'IncorrectSize');
end

% Return the decomposition or just the value of the volume ?
if nargin < 3
    do_decomposition = false;
else
    do_decomposition = logical (do_decomposition);
end

% Pre-processing
if iscell (y),
    y = cellfun (@(z) wfg_preprocessing (z, y_ref), y, 'UniformOutput', false);
else % y is a matrix
    try
        y = double (y);
        assert (ndims (y) == 2);  %#ok<ISMAT> see CODING_GUDELINES
    catch
        stk_error (['y should either be a cell array or be (convertible ' ...
            'to) a numeric matrix'], 'InvalidArgument');
    end
    y = wfg_preprocessing (y, y_ref);
end

% COMPUTE
if ~ do_decomposition,
    
    % Compute the hypervolume only
    result = stk_dominatedhv_mex (y, false);
    
else
    
    % Compute the decomposition into hyper-rectangles
    result = stk_dominatedhv_mex (y, true);
    
    % Post-processing
    if iscell (y)
        result = arrayfun (@(hv) wfg_postprocessing (hv, y_ref), ...
            result, 'UniformOutput', true);
    else
        result = wfg_postprocessing (result, y_ref);
    end
end

end % function


function y = wfg_preprocessing (y, y_ref)

y = double (y);

% Keep only non-dominated points, and remove duplicates
y = unique (y(stk_paretofind (y), :), 'rows');

if isempty (y_ref)  % Use [0 0 ... 0] as a reference point
    
    % WFG convention: maximization problem
    y = - y;
    
else  % Reference point provided
    
    p = size (y, 2);
    p_ref = size (y_ref, 2);
    
    % Check the size of y
    if (p > p_ref)
        stk_error (['The number of columns the data matrix should not be ' ...
            'larger than the number of columns of y_ref'], 'InvalidArgument');
    end
    
    % WFG convention: maximization problem
    y = bsxfun (@minus, y_ref(1:p), y);
    
end

% Remove points that do not dominate the reference
b = any (y < 0, 2);
y(b, :) = [];

end % function


function hv = wfg_postprocessing (hv, y_ref)

p = size (hv.xmin, 2);
xmin = hv.xmin;

if isempty (y_ref)
    hv.xmin = - hv.xmax;
    hv.xmax = - xmin;
else
    hv.xmin = bsxfun (@minus, y_ref(1:p), hv.xmax);
    hv.xmax = bsxfun (@minus, y_ref(1:p), xmin);
end

end % function


%!error hv = stk_dominatedhv ();
%!error hv = stk_dominatedhv (-y, 'incorrect ref type');
%!error hv = stk_dominatedhv (-y, [0 0]);
%!error hv = stk_dominatedhv (-y, [0 0 0 0 0], 0, 'too many input args');

%-------------------------------------------------------------------------------

%!shared y, hv0 % Example from README.TXT in WFG 1.10
%!
%! y = [ ...
%!     0.598 0.737 0.131 0.916 6.745; ...
%!     0.263 0.740 0.449 0.753 6.964; ...
%!     0.109 8.483 0.199 0.302 8.872 ];
%!
%! hv0 = 1.1452351120;

%!test
%! hv = stk_dominatedhv (-y);
%! assert (stk_isequal_tolrel (hv, hv0, 1e-10));

%!test
%! yy = stk_dataframe (- y);  % Check that @stk_dataframe inputs are accepted
%! hv = stk_dominatedhv (yy);
%! assert (stk_isequal_tolrel (hv, hv0, 1e-10));

%!test
%! hv = stk_dominatedhv (-y, [], 0);
%! assert (stk_isequal_tolrel (hv, hv0, 1e-10));

%!test
%! hv = stk_dominatedhv (-y, [0 0 0 0 0]);
%! assert (stk_isequal_tolrel (hv, hv0, 1e-10));

%!test
%! hv = stk_dominatedhv (1 - y, [1 1 1 1 1]);
%! assert (stk_isequal_tolrel (hv, hv0, 1e-10));

%!test
%! r = stk_dominatedhv (-y, [], 1);
%! hv = sum (r.sign .* prod (r.xmax - r.xmin, 2));
%! assert (stk_isequal_tolrel (hv, hv0, 1e-10));

%-------------------------------------------------------------------------------

%!shared y1, y2, y0, S, S1
%! y0 = [1.00 1.00];  % Reference point
%! y1 = [1.50 1.50];  % Above the reference point
%! y2 = [0.50 0.50];  % Below the reference point

%!assert (isequal (0.00, stk_dominatedhv (y1, y0)));
%!assert (isequal (0.25, stk_dominatedhv (y2, y0)));
%!assert (isequal (0.25, stk_dominatedhv ([y1; y2], y0)));
%!assert (isequal (0.25, stk_dominatedhv ([y2; y1; y2], y0)));

% Check decompositions:

%!test S = stk_dominatedhv (y1, y0, 1);    % empty decomposition
%!assert (isequal (size (S.xmin, 1), 0));

%!test S = stk_dominatedhv (y2, y0, 1);    % trivial decomposition
%!assert (isequal (S.sign, 1));
%!assert (isequal (S.xmin, y2));
%!assert (isequal (S.xmax, y0));

%!test S1 = stk_dominatedhv ([y2; y0], y0, 1);  % shoud be the same as before
%!assert (isequal (S1, S));

%!test S1 = stk_dominatedhv ([y2; y1], y0, 1);  % shoud be the same as before
%!assert (isequal (S1, S));

%!test S1 = stk_dominatedhv ([y2; y2], y0, 1);  % shoud be the same as before
%!assert (isequal (S1, S));

%-------------------------------------------------------------------------------

%!test
%! for d = 1:10,
%!    y = - 0.5 * ones (1, d);
%!    hv = stk_dominatedhv (y);
%!    assert (isequal (stk_dominatedhv (y), 0.5 ^ d));
%! end

%!test
%! for d = 1:10,
%!    y = - 0.5 * ones (1, d);
%!    r = stk_dominatedhv (y, [], 1);
%!    hv = sum (r.sign .* prod (r.xmax - r.xmin, 2));
%!    assert (isequal (stk_dominatedhv (y), 0.5 ^ d));
%! end

%-------------------------------------------------------------------------------

%!shared y, y_ref, dv, hv0
%! y1 = [0.25 0.75];
%! y2 = [0.50 0.50];
%! y3 = [0.75 0.25];
%!
%! y_ref = [1 1];
%!
%! y = {[], y1, y2, y3; [y1; y2], [y1; y3], [y2; y3], [y1; y2; y3]};
%!
%! dv = 0.25 ^ 2;  hv0 = [0 3 4 3; 5 5 5 6] * dv;

%!test
%! hv1 = stk_dominatedhv (y, y_ref);
%! assert (isequal (hv0, hv1));

%!test
%! r = stk_dominatedhv (y, y_ref, 1);
%!
%! % Check the first decomposition, which should be empty
%! assert (isempty (r(1).sign));
%! assert (isempty (r(1).xmin));
%! assert (isempty (r(1).xmax));
%!
%! % Check the other decompositions
%! for i = 2:6,
%!    hv2 = sum (r(i).sign .* prod (r(i).xmax - r(i).xmin, 2));
%!    assert (isequal (hv0(i), hv2));
%! end

%-------------------------------------------------------------------------------

%!test
%! y = (0.3:0.1:0.8)';
%! hv0 = 0.7;
%! hv1 = stk_dominatedhv (y, 1);
%! r = stk_dominatedhv (y, 1, true);
%! hv2 = sum (r.sign .* prod (r.xmax - r.xmin, 2));

%!test % four non-dominated points (hypervolume)
%! zr = [1 1];
%! zi = [0.2 0.8; 0.4 0.6; 0.6 0.4; 0.8 0.2]
%! P = perms (1:4);
%! for i = 1:24
%!     HV = stk_dominatedhv (zi(P(i, :), :), zr, 0);
%!     assert (stk_isequal_tolrel (HV, 0.4, 1e-15));
%! end

%!test % four non-dominated points (decomposition)
%! zr = [1 1];
%! zi = [0.2 0.8; 0.4 0.6; 0.6 0.4; 0.8 0.2]
%! P = perms (1:4);
%! for i = 1:24
%!     S = stk_dominatedhv (zi(P(i, :), :), zr, 1);
%!     HV = sum (S.sign .* prod (S.xmax - S.xmin, 2));
%!     assert (stk_isequal_tolrel (HV, 0.4, 1e-15));
%! end

%!test  % a case with 8 points and 5 objectives
%!      % http://sourceforge.net/p/kriging/tickets/33
%!
%! yr = [1.03 0.91 0.96 1.99 16.2];
%!
%! y = [ ...
%!     0.8180    0.5600    0.1264    1.0755    1.2462; ...
%!     0.8861    0.6928    0.2994    0.7228    0.9848; ...
%!     0.9021    0.8829    0.6060    0.1642    0.4282; ...
%!     0.9116    0.3097    0.8601    0.0468    0.2813; ...
%!     0.9306    0.1429    0.6688    0.1462    1.3661; ...
%!     0.9604    0.3406    0.4046    0.7239    1.8741; ...
%!     0.9648    0.7764    0.5199    0.4098    1.3436; ...
%!     0.9891    0.4518    0.7956    0.1164    1.2025];
%!
%! hv1 = stk_dominatedhv (y, yr, 0);
%!
%! S = stk_dominatedhv (y, yr, 1);
%! hv2 = sum (S.sign .* prod (S.xmax - S.xmin, 2));
%!
%! assert (isequal (size (S.sign), [87 1]));
%! assert (isequal (size (S.xmin), [87 5]));
%! assert (isequal (size (S.xmax), [87 5]));
%! assert (stk_isequal_tolrel (hv1, 1.538677420906463, 2 * eps));
%! assert (stk_isequal_tolrel (hv1, hv2, eps));

%!test % with random data
%! NREP = 5;
%! for p = 1:5
%!     for n = 1:10
%!         for i = 1:NREP
%!             % Draw random data
%!             y = rand (n, p);
%!             y = - y ./ (norm (y));
%!             % Compute hypervolume directly
%!             hv1 = stk_dominatedhv (y, [], 0);
%!             % Compute decomposition, then hypervolume
%!             R = stk_dominatedhv (y, [], 1);
%!             hv2 = sum (R.sign .* prod (R.xmax - R.xmin, 2));
%!             % Compare results
%!             assert (stk_isequal_tolabs (hv1, hv2, eps));
%!         end
%!     end
%! end

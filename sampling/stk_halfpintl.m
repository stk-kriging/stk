% STK_HALFPINTL computes an intersection of lower half-planes
%
% CALL: [A, B, Z] = stk_halfpintl (A, B)
%
%    computes the intersection of the lower half-planes defined by the vector
%    of slopes A and the vector of intercepts B.  The output vectors A and B
%    contain the slopes and intercept of the lines that actually contribute to
%    the boundary of the intersection, sorted in such a way that the k^th
%    element corresponds to the k^th piece of the piecewise affine boundary.
%    The output Z contains the intersection points (shorter by one element).
%
% ALGORITHM
%
%    The algorithm implemented in this function is described in [1, 2].
%
% REFERENCE
%
%   [1] P. I. Frazier, W. B. Powell, and S. Dayanik.  The Knowledge-Gradient
%       Policy for Correlated Normal Beliefs.  INFORMS Journal on Computing
%       21(4):599-613, 2009.
%
%   [2] W. Scott, P. I. Frazier and W. B. Powell.  The correlated knowledge
%       gradient for simulation optimization of continuous parameters using
%       Gaussian process regression.  SIAM J. Optim, 21(3):996-1026, 2011.

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

function [a, b, z] = stk_halfpintl (a, b)

% a: slopes
% b: intercepts

m = length (a);
assert (isequal (size (a), [m 1]));
assert (isequal (size (b), [m 1]));

if m == 1
    z = [];
    return
end


% 1) Sort by decreasing slopes (and increasing intercept in case of equality)

tmp = [a b];
tmp = sortrows (tmp, [-1 2]);
a_in = tmp(:, 1);
b_in = tmp(:, 2);


% 2) Prepare output lists

a_out = nan (m, 1);      % *at most* m lines in the output list
b_out = nan (m, 1);
z_out = nan (m - 1, 1);  % the maximal number of intersections in m - 1, then

a_out(1) = a_in(1);
b_out(1) = b_in(1);

k_in  = 2;  % index of the next input element to be analyzed
k_out = 1;  % index of the last element stored in the output list


% 3) Process input list

while k_in <= m
    
    if a_in(k_in) == a_out(k_out)  % equality of slopes
        
        k_in = k_in + 1;
        
    else % inequality: a_in(k_in) < a_out(k_out)
        
        % Compute intersection
        z = (b_in(k_in) - b_out(k_out)) / (a_out(k_out) - a_in(k_in));
        
        if (k_out == 1) || (z > z_out(k_out-1))
            % Insert the new element at the end of the output list
            z_out(k_out) = z;
            k_out = k_out + 1;
            a_out(k_out) = a_in(k_in);
            b_out(k_out) = b_in(k_in);
            k_in = k_in + 1;
        else
            % Remove the last element of the output list
            k_out = k_out - 1;
        end
        
    end % if
    
end % while

a = a_out(1:k_out);
b = b_out(1:k_out);
z = z_out(1:(k_out - 1));

end % function


%!test  % case #1
%! a = 1;
%! b = 1;
%! [a_out, b_out, z_out] = stk_halfpintl (a, b);
%! assert (a_out == 1)
%! assert (b_out == 1)
%! assert (isempty (z_out))

%!test  % case #2: two lines, slopes not equal, already sorted
%! a = [1; -1];
%! b = [0; 2];
%! [a_out, b_out, z_out] = stk_halfpintl (a, b);
%! assert (isequal (a_out, [1; -1]))
%! assert (isequal (b_out, [0; 2]))
%! assert (z_out == 1)

%!test  % case #3: same as #2, but not sorted
%! a = [-1; 1];
%! b = [ 2; 0];
%! [a_out, b_out, z_out] = stk_halfpintl (a, b);
%! assert (isequal (a_out, [1; -1]))
%! assert (isequal (b_out, [0; 2]))
%! assert (z_out == 1)

%!test  % case #4: two lines, equal slopes, already sorted
%! a = [0; 0];
%! b = [1; 2];
%! [a_out, b_out, z_out] = stk_halfpintl (a, b);
%! assert (a_out == 0)
%! assert (b_out == 1)
%! assert (isempty (z_out))

%!test  % case #5: same as #4, but not sorted
%! a = [0; 0];
%! b = [2; 1];
%! [a_out, b_out, z_out] = stk_halfpintl (a, b);
%! assert (a_out == 0)
%! assert (b_out == 1)
%! assert (isempty (z_out))

%!test  % case #6: add a dominated line to #2 (the result does not change)
%! a = [1; -1; 0];
%! b = [0;  2; 1];
%! [a_out, b_out, z_out] = stk_halfpintl (a, b);
%! assert (isequal (a_out, [1; -1]))
%! assert (isequal (b_out, [0; 2]))
%! assert (z_out == 1)

%!test  % case #7: permutation of #6
%! a = [1; 0; -1];
%! b = [0; 1;  2];
%! [a_out, b_out, z_out] = stk_halfpintl (a, b);
%! assert (isequal (a_out, [1; -1]))
%! assert (isequal (b_out, [0; 2]))
%! assert (z_out == 1)

%!test  % case #8: another permutation of #6
%! a = [0; 1; -1];
%! b = [1; 0;  2];
%! [a_out, b_out, z_out] = stk_halfpintl (a, b);
%! assert (isequal (a_out, [1; -1]))
%! assert (isequal (b_out, [0; 2]))
%! assert (z_out == 1)

%!test  % case #9: same as #8, with some duplicated lines added
%! a = [0; 1; 0; -1; 0; -1; 1];
%! b = [1; 0; 1;  2; 1;  2; 0];
%! [a_out, b_out, z_out] = stk_halfpintl (a, b);
%! assert (isequal (a_out, [1; -1]))
%! assert (isequal (b_out, [0; 2]))
%! assert (z_out == 1)

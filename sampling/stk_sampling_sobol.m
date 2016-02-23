% STK_SAMPLING_SOBOL generates points from a Sobol sequence
%
% CALL: X = stk_sampling_sobol (N, D)
% CALL: X = stk_sampling_sobol (N, D, FALSE)
%
%    computes the first N terms of a D-dimensional Sobol sequence (with
%    N < 2^32 and D <= 1111).  The sequence is generated using the algorithm
%    of Bratley and Fox [1], as modified by Joe and Kuo [3].
%
% CALL: X = stk_sampling_sobol (N, D, TRUE)
%
%    skips an initial segment of the sequence.  More precisely, according to
%    the recommendation of [2] and [3], a number of points equal to the largest
%    power of 2 smaller than n is skipped.
%
% REFERENCE
%
%    [1] Paul Bratley and Bennett L. Fox, "Algorithm 659: Implementing Sobol's
%        quasirandom sequence generator",  ACM Transactions on Mathematical
%        Software, 14(1):88-100, 1988.
%
%    [2] Peter Acworth, Mark Broadie and Paul Glasserman, "A Comparison of Some
%        Monte Carlo and Quasi Monte Carlo Techniques for Option Pricing", in
%        Monte Carlo and Quasi-Monte Carlo Methods 1996, Lecture Notes in
%        Statistics 27:1-18, Springer, 1998.
%
%    [3] Stephen Joe and Frances Y. Kuo, "Remark on Algorithm 659: Implementing
%        Sobol's Quasirandom Sequence Generator', ACM Transactions on
%        Mathematical Software, 29(1):49-57, 2003.
%
% SEE ALSO: stk_sampling_halton_rr2

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function x = stk_sampling_sobol (n, dim, box, do_skip)

if nargin > 4
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Default values
if nargin < 4
    do_skip = false;
    if nargin < 3
        box = [];
        if nargin < 2
            dim = [];
        end
    end
end

% Check that either dim or box is provided
if (isempty (dim)) && (isempty (box))
    stk_error (['The dimension argument can be omitted if, and only if, a ' ...
        'valid box argument is provided instead.'], 'IncorrectArgument');
end

% Process box argument
if isempty (box)
    colnames = {};
else
    box = stk_hrect (box);  % convert input argument to a proper box
    colnames = box.colnames;
    if isempty (dim)
        dim = size (box, 2);
    elseif dim ~= size (box, 2)
        stk_error (['The dimension argument must be compatible with' ...
        'the box argument when both are provided.'], 'IncorrectArgument');
    end
end
    
% Generate a Sobol sequence in [0; 1]^dim
x = transpose (stk_sampling_sobol_mex (n, dim, do_skip));

% Create dataframe output
x = stk_dataframe (x, colnames);
x.info = 'Created by stk_sampling_sobol';

if ~ isempty (box),
    x = stk_rescale (x, [], box);
end

end % function

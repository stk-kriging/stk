% GATHER_REPETITIONS_INSIDE [STK internal]

% Copyright Notice
%
%    Copyright (C) 2015, 2019, 2020 CentraleSupelec
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

function [x, zm, zv, nrep] = gather_repetitions_inside (x, zm, zv, nrep)

sample_size = size (x, 1);

[ignd, idx, pos] = unique (x, 'rows', 'first');  %#ok<ASGLU> CG#07
nb_unique = length (idx);

% Stop here if there are no repetitions
if nb_unique == sample_size
    return
end

% Prepare to gather repetitions
if isempty (nrep)
    nrep = ones (sample_size, 1);
end
if isempty (zv)
    zv = zeros (sample_size, size (zm, 2));
end

% Note: Octave doesn't support the 'stable' option, so we just reorder manually
[idx_stable, k] = sort (idx);

% Keep unique input data only
x_out = x(idx_stable, :);

% Initialize outputs with inputs
% (this way, the output is already correct for the rows that are not repeated)
zm_out = zm(idx_stable, :);
zv_out = zv(idx_stable, :);
nrep_out = nrep(idx_stable);

% Loop over the rows of the output matrix
for r = 1:nb_unique
    %  * r:              index of the row in the output data
    %  * k(r):           index of the row in the "intermediate" data
    %  * idx_stable(r):  index of the row in the input data
    
    % Find which rows in the input are repetitions of x_out(r, :)
    i_rep = find (pos == k(r));
    
    % Count repetitions of x_out(r, :)
    n_rep = length (i_rep);  assert (n_rep > 0);
    
    if n_rep > 1
        
        % Keep relevant data only
        zm_ = zm(i_rep, :);
        zv_ = zv(i_rep, :);
        nrep_ = nrep(i_rep);
        
        % Total number of repetitions
        nrep_out(r) = sum (nrep_);
        
        % Prepare for computing weighted means
        p = nrep_ / nrep_out(r);
        
        % Batch mean (law of total expectation)
        zm_out(r, :) = sum (bsxfun (@times, p, zm_));
        
        % Batch variance (law of total variance)
        dzm = bsxfun (@minus, zm_, zm_out(r, :));
        zv_out(r, :) = ...
            sum (bsxfun (@times, p, zv_)) + ...
            sum (bsxfun (@times, p, dzm .^ 2));
        
        % We can't preserve row names
        if (isa (x_out, 'stk_dataframe')) && (~ isempty (x_out.rownames))
            x_out.rownames{r} = '';
        end
        if (isa (zm_out, 'stk_dataframe')) && (~ isempty (zm_out.rownames))
            zm_out.rownames{r} = '';
        end
        
    end
end

x = x_out;
zm = zm_out;
zv = zv_out;
nrep = nrep_out;

end % function

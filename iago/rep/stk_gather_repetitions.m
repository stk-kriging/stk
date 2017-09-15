% STK_GATHER_REPETITIONS

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function [x, z] = stk_gather_repetitions (x, z, x_new, z_new)

if nargin == 2
    x_new = x;  x = [];
    z_new = z;  z = [];
end

% NOTE: we assume that there are no repetitions in (x, z)

n = stk_length (x);      assert (stk_length (z) == n);
m = stk_length (x_new);  assert (stk_length (z_new) == m);

% Convert z to the three-column representation (mean, var, nb_obs)
if size (z, 2) == 1
    z = horzcat (z, repmat ([0 1], size (z)));    
elseif isempty (z)
    z = zeros (0, 3);
else
    assert (size (z, 2) == 3);
end

% Convert z_new to the three-column representation (mean, var, nb_obs)
if size (z_new, 2) == 1
    z_new = horzcat (z_new, repmat ([0 1], size (z_new)));
else
    assert (size (z_new, 2) == 3);
end

% Set column names
colnames = {'mean', 'var', 'nb_obs'};
z = stk_dataframe (z, colnames);
z_new = stk_dataframe (z_new, colnames);

% First, deal with new evaluations that are repetitions
% of existing evaluation points
if ~ isempty (x)
    [b, pos] = ismember (x_new, x, 'rows');
    all_pos = unique (pos(pos > 0));
    for k = 1:(length (all_pos))
        
        % Concatenate into z_
        i = all_pos(k);  % index of a row in x
        b_rep = (pos == i);  % indicates which rows are repetitions of x(i, :)
        assert (any (b_rep));  % safety net
        z_ = [z(i, :); z_new(b_rep, :)];
        
        % Summarize z_
        nb_obs = z_.nb_obs;
        n_tot = sum (nb_obs);
        p = nb_obs / n_tot;  % weights
        zm = sum (p .* z_.mean);
        zv = (sum (p .* z_.var)) + (sum (p .* ((z_.mean - zm) .^ 2)));
        z(i, :) = [zm zv n_tot];
        
        % We can't preserve row names in this case
        if ~ isempty (z.rownames)
            z.rownames{i} = '';
        end
        if (isa (x, 'stk_dataframe')) && (~ isempty (x.rownames))
            x.rownames{i} = '';
        end
        
    end

    % Remove the points that have been dealt with
    x_new = x_new(~ b, :);
    z_new = z_new(~ b, :);
end
    
% Second, deal with those that are not repetitions of any existing evaluation
% point (but there may still be repetitions *inside* z_new)
[ignd, idx, pos] = unique (double (x_new), 'rows', 'first');  %#ok<ASGLU> CG#07
nb_unique = length (idx);
% Note: Octave doesn't support the 'stable' option, so we just reorder manually
[idx_stable, k] = sort (idx);
x_new = x_new(idx_stable, :);
z_new_ = stk_dataframe (nan (nb_unique, 3), colnames, {});
for r = 1:nb_unique

    % Pick a row & count repetitions
    i = idx_stable(r);  % index of a row in x_new
    b_rep = (pos == k(r)); % indicates which rows are repetitions of x_new(i, :)
    n_rep = sum (b_rep);  assert (n_rep > 0);

    if n_rep == 1  % Special case: no repetitions
        
        z_new_(r, :) = z_new(i, :);
        
        % We can preserve row names in this case
        if ~ isempty (z_new.rownames)
            z_new_.rownames{r} = r_new.rownames{i};
        end
        
    else  % General case: repetitions (any number of them)
        
        % Concatenate into z_
        z_ = z_new(b_rep, :);
    
        % Summarize z_ into z_new_(r, :)
        nb_obs = z_.nb_obs;
        n_tot = sum (nb_obs);
        p = nb_obs / n_tot;  % weights
        zm = sum (p .* z_.mean);
        zv = (sum (p .* z_.var)) + (sum (p .* ((z_.mean - zm) .^ 2)));
        z_new_(r, :) = [zm zv n_tot];

        % We can't preserve row names in this case
        if (isa (x_new, 'stk_dataframe')) && (~ isempty (x_new.rownames))
            x_new.rownames{r} = '';
        end
        
    end
end

% Finally...
x = [x; x_new];
z = [z; z_new_];

end % function

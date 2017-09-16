% STK_FEVAL evaluates a function at given evaluation points
%
% CALL: Z = stk_feval (F, X)
%
%    evaluates the function F on the evaluation points X, where
%
%     * F can be either a function handle or a function name (string),
%       or a cell-array of function handles or names, and
%     * X can be either a numerical array or an stk_dataframe object.
%
%    The output Z contains the evaluation results. The number of rows of Z is
%    the same as the number of rows of X.
%
%     * If F is a single function (name of handle) that returns row vectors with
%       J elements, then Z has J columns and Z(i, :) is equal to F(X(i, :)).
%     * If F is a cell-array of functions (names or handles), where F{k} returns
%       row vectors J_k elements, then Z has J = J_1 + ... + J_K elements, and
%       Z(i, :) is equal to [F{1}(X(i, :)) ... F{K}(X(i, :))].
%
%    This two-argument form assumes that F supports vectorized evaluations.
%
% EXAMPLE:
%
%    f = {@sin, @cos};
%    x = stk_sampling_regulargrid (100, 1, [0; 2*pi]);
%    x.colnames = {'x'};
%    y = stk_feval (f, x);
%    plot (x, y);
%
% CALL: Z = stk_feval (F, X, DISPLAY_PROGRESS)
%
%    displays progress messages if DISPLAY_PROGRESS is true, and does the same
%    as the previous form otherwise. Displaying a progress message is useful if
%    each evaluation of F requires a significant computation time.
%
%    This three-argument form assumes that F supports vectorized evaluations if
%    DISPLAY_PROGRESS is false, and performs evaluations one by one otherwise.
%
% NOTE: output type
%
%   The output of stk_feval is an stk_dataframe object if X is, with the same
%   row names and with column names determined automatically. Otherwise, the
%   type of the output of stk_feval is determined by the type of the output of
%   each function that is evaluated (together with the usual rules for concate-
%   nating arrays of different types, if necessary).
%
% CALL: Z = stk_feval (F, X, DISPLAY_PROGRESS, DF_OUT)
%
%   returns an stk_dataframe output if DF_OUT is true (even if X is not an
%   stk_dataframe object itself), and let the usual concatenation rules
%   determine the output type otherwise (even if X is an stk_dataframe).
%
% CALL: Z = stk_feval (F, X, DISPLAY_PROGRESS, DF_OUT, VECTORIZED)
%
%   controls whether function evaluations are performed in a "vectorized" manner
%   (i.e., all rows at once) or one row after the other. This form can be used
%   to override the default rules explained above. Vectorized evaluations are
%   usually faster but some functions do not support them.
%
% See also feval

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

function z = stk_feval (f, x, progress_msg, df_out, vectorized)

if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Check 'progress_msg' argument
if (nargin < 3) || (isempty (progress_msg)),
    progress_msg = false;
else
    progress_msg = logical (progress_msg);
end

% Check 'df_out' argument
if (nargin  < 4) || (isempty (df_out)),
    % Default: type stability
    df_out = isa (x, 'stk_dataframe');
else
    df_out = logical (df_out);
end

% Check 'vectorized' argument
if (nargin  < 5) || (isempty (vectorized)),
    % Default: use vectorized evaluations, unless progress_msg is true
    vectorized = ~ progress_msg;
else
    vectorized = logical (vectorized);
end

% Turn f into a cell (if it isn't already one)
if ~ iscell (f),  f = {f};  end

% Number of functions
numfcs = numel (f);

% Check f and extract function names
if df_out
    fname = cell (size (f));
    truncated_fname = false (size (f));
    for k = 1:numfcs,
        
        if ischar (f{k}),
            fname{k} = f{k};
        else
            try
                fname{k} = func2str (f{k});
            catch
                fname{k} = sprintf ('F%d', k);
            end
        end
        
        % Truncate long function names
        if (length (fname{k})) > 15
            fname{k} = sprintf ('F%d', k);
            truncated_fname(k) = true;
        end
    end
end

% Extract numeric data
xdata = double (x);

% Zero-dimensional inputs are not allowed
[n, d] = size (xdata);
if d == 0,
    error ('zero-dimensional inputs are not allowed.');
end

% Each function can have several outputs => we will try to recover meaningful
% column names by looking at these outputs and store them in:
if df_out
    fcolnames = cell (1, numfcs);
end

if n == 0, % no input => no output
    
    z = zeros (0, numfcs);
    
else % at least one input point
    
    output_dim = zeros (1, numfcs);
    
    if vectorized %--- Vectorized calls ----------------------------------------
        
        z = cell (1, numfcs);
        for k = 1:numfcs
            
            z{k} = feval (f{k}, xdata);
            
            % Check output size
            if (size (z{k}, 1) ~= size (xdata, 1))
                stk_error (['The size of the output is incorrect. Perhaps ' ...
                    'the function does not support vectorized ' ...
                    'evaluations.'], 'IncorrectSize');
            end
            
            % Guess output dimension
            output_dim(k) = size (z{k}, 2);
            
            % Guess column names
            if df_out && (isa (z{k}, 'stk_dataframe'))
                fcolnames{k} = z{k}.colnames;
            end
            
        end
        
    else  %--- Unvectorized calls: n == 1 --------------------------------------
        
        % First evaluation: figure out the dimension of the output
        
        if progress_msg,
            stk_disp_progress ('feval %d/%d... ', 1, n);
        end
        
        z1 = [];
        
        for k = 1:numfcs
            
            % Get the evaluation result
            %  (at this point, we don't know the size or type of zdata{k})
            z1_k = feval (f{k}, xdata(1, :));
            
            % Guess output dimension
            output_dim(k) = size (z1_k, 2);
            
            % Concatenate
            try
                z1 = [z1 double(z1_k)];  %#ok<AGROW>
            catch
                if ~ isequal (size (z1_k), [1 output_dim(k)])
                    stk_error (['The output of F{j} should be a scalar or ' ...
                        'a row vector'], 'IncorrectSize');
                else
                    rethrow (lasterror);
                end
            end
            
            % Guess column names
            if df_out && (isa (z1_k, 'stk_dataframe'))
                fcolnames{k} = z1_k.colnames;
            end
        end
        
    end % if vectorized
    
    % Begin/end indices for each block of columns
    j_end = cumsum (output_dim);
    j_beg = 1 + [0 j_end(1:end-1)];
    
    if vectorized %--- Vectorized calls ----------------------------------------
        
        % Concatenate function outputs
        z = horzcat (z{:});
        
    else  %--- Unvectorized calls: n > 1 ---------------------------------------
        
        % Prepare for subsequent evaluations
        z = zeros (n, j_end(end));
        z(1, :) = z1;
        
        if n > 1,  % Subsequent evaluations
            
            for i = 2:n,
                if progress_msg,
                    stk_disp_progress ('feval %d/%d... ', i, n);
                end
                for k = 1:numfcs
                    z(i, (j_beg(k):j_end(k))) = feval (f{k}, xdata(i, :));
                end
            end
            
        end % if n > 1
        
    end % if vectorized
    
end % if n == 0

%--- Create column names -------------------------------------------------------

if df_out
    colnames = cell (1, size (z, 2));
    
    for k = 1:numfcs
        
        if ~ isempty (fcolnames{k})  % We have column names, let's use them
            
            % Special case: only one function,
            %   without a nice short displayable name
            if (numfcs == 1) && truncated_fname(1)
                prefix = '';
            else
                prefix = [fname{1} '_'];
            end
            
            colnames(j_beg(k):j_end(k)) = cellfun (...
                @(u)(sprintf ('%s%s', prefix, u)), fcolnames{k}, ...
                'UniformOutput', false);
            
        elseif output_dim(k) == 1  % Only one column and no column names
            
            colnames{j_beg(k)} = fname{k};
            
        else  % General case: several columns but no column names
            
            colnames(j_beg(k):j_end(k)) = arrayfun (...
                @(u)(sprintf ('%s_%d', fname{k}, u)), 1:output_dim(k), ...
                'UniformOutput', false);
        end
    end
end

%--- Create output stk_dataframe object ----------------------------------------

if df_out
    if isa (x, 'stk_dataframe'),
        rownames = x.rownames;
    else
        rownames = {};
    end
    
    z = stk_dataframe (z, colnames, rownames);
end

end % function

%#ok<*CTCH,*LERR>


%!shared f, xt
%! f = @(x)(- (0.7 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
%! xt = stk_sampling_regulargrid (20, 1, [0; 1]);

%!error  yt = stk_feval ();
%!error  yt = stk_feval (f);
%!test   yt = stk_feval (f, xt);
%!test   yt = stk_feval (f, xt, false);
%!test   yt = stk_feval (f, xt, false, false);
%!test   yt = stk_feval (f, xt, false, false, false);
%!error  yt = stk_feval (f, xt, false, false, false, pi^2);

%!test
%! N = 15;
%! xt = stk_sampling_regulargrid (N, 1, [0; 1]);
%! yt = stk_feval (f, xt);
%! assert (isequal (size (yt), [N 1]));

%!test
%! x = stk_dataframe ([1; 2; 3], {'x'}, {'a'; 'b'; 'c'});
%! y = stk_feval (@(u)(2 * u), x);
%! assert (isequal (y.data, [2; 4; 6]));
%! assert (isequal (y.rownames, {'a'; 'b'; 'c'}));

%!shared t, z_ref, n
%! n = 20;
%! t = stk_sampling_regulargrid (n, 1, [0; 2*pi]);
%! z_ref = [sin(t.data) cos(t.data)];

%!test
%! t.colnames = {'time'};
%! z = stk_feval ({@sin, @cos}, t);
%! assert (isa (z, 'stk_dataframe'));
%! assert (isequal (z.data, z_ref));

%!test
%! F = @(x)([sin(x) cos(x)]);
%! z = stk_feval (F, t);
%! assert (isequal (z.data, z_ref));

%!test
%! t = stk_sampling_regulargrid (n, 1, [0; 2*pi]);
%! F = {'sin', 'cos'};
%! z = stk_feval (F, t);
%! assert (isequal (z.data, [sin(t.data) cos(t.data)]));
%! assert (isequal (z.colnames, {'sin' 'cos'}));

%!test  % vectorized
%! F = @(t)([sin(t) cos(t)]);
%! G = @(t)(0.365 * t.^2 + (cos ((t - 1).*(t - 2) + 0.579033)));
%! z = stk_feval ({@sin, @cos, G, F, 'tan'}, t);
%! assert (isequal (z.colnames, {'sin' 'cos' 'F3' 'F4_1' 'F4_2' 'tan'}));

%!test  % not vectorized
%! F = @(t)([sin(t) cos(t)]);
%! G = @(t)(0.365 * t^2 + (cos ((t - 1)*(t - 2) + 0.579033)));
%! z = stk_feval ({@sin, @cos, G, F, 'tan'}, t, [], [], false);
%! assert (isequal (z.colnames, {'sin' 'cos' 'F3' 'F4_1' 'F4_2' 'tan'}));

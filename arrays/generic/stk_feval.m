% STK_FEVAL evaluates a function at given evaluation points
%
% CALL: Z = stk_feval (F, X)
%
%    evaluates the function F on the evaluation points X, where
%
%     * F can be either a function handle or a function name (string),
%       or a cell-array of function handle or names, and
%     * X can be either a numerical array or a dataframe.
%
%    The output Z is a dataframe, with the same number of rows as X,
%    and the function name of F as variable name. The number of column is
%    one when F is a function name or handle, and is equal to numel (F)
%    when F is a cell-array of these. In the latter case, column j of Z
%    contains the result of evaluating function F{j}.
%
% CALL: Z = stk_feval (F, X, DISPLAY_PROGRESS)
%
%    displays progress messages if DISPLAY_PROGRESS is true. This is especially
%    useful if each evaluation of F requires a significant computation time.
%
% EXAMPLE:
%       f = @(x)(- (0.7 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
%       xt = stk_sampling_regulargrid (100, 1, [0; 1]);
%       yt = stk_feval (f, xt);
%       plot (xt, yt);
%
% See also feval

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@supelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function z = stk_feval (f, x, progress_msg)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

xdata = double (x);

% Turn f into a cell (if it isn't already one)
if ~ iscell (f),  f = {f};  end

% Number of functions
numfcs = numel (f);

% Check f and extract function names
fname = cell (size (f));
truncated_fname = false (size (f));
for k = 1:numfcs,
    
    if ischar (f{k}),
        fname{k} = f{k};
    elseif ~ isa (f{k}, 'function_handle')
        stk_error (['Argument ''f'' should be a cell-array of function ' ...
            'names or function handles.'], 'IncorrectType');
    else
        fname{k} = func2str (f{k});
    end
    
    % Truncate long function names
    if (length (fname{k})) > 15
        fname{k} = sprintf ('F%d', k);
        truncated_fname(k) = true;
    end
end

% Check 'progress_msg' argument
if nargin < 3,
    progress_msg = false;
else
    if ~ islogical (progress_msg),
        errmsg = 'Incorrect type for argument ''progress_msg''.';
        stk_error (errmsg, 'IncorrectType');
    end
end

% Zero-dimensional inputs are not allowed
[n, d] = size (x);
if d == 0,
    error ('zero-dimensional inputs are not allowed.');
end

% Each function can have several outputs => we will try to recover meaningful
% column names by looking at these outputs and store them in:
fcolnames = cell (1, numfcs);

if n == 0, % no input => no output
    
    zdata = zeros (0, numfcs);
    
else % at least one input point
    
    %--- First evaluation: figure out the dimension of the output --------------
    
    if progress_msg,
        stk_disp_progress ('feval %d/%d... ', 1, n);
    end
    
    zdata = cell (1, numfcs);
    output_dim = zeros (1, numfcs);
    
    for k = 1:numfcs
        
        % Get the evaluation result
        %  (at this point, we don't know the size or type of zdata{k})
        zdata{k} = feval (f{k}, xdata(1, :));
        
        % Guess output dimension
        output_dim(k) = size (zdata{k}, 2);
        if ~ isequal (size (zdata{k}), [1 output_dim(k)])
            stk_error (['The output of F{j} should be a scalar or a row ' ...
                'vector'], 'IncorrectSize');
        end
        
        % Guess column names
        if isa (zdata{k}, 'stk_dataframe')
            fcolnames{k} = zdata{k}.colnames;
        end
        
        % Make sure that zdata{k} is of class 'double'
        zdata{k} = double (zdata{k});
    end
    
    zdata = cell2mat (zdata);
    
    % Begin/end indices for each block of columns
    j_end = cumsum (output_dim);
    j_beg = 1 + [0 j_end(1:end-1)];

    if n > 1,  %--- Subsequent evaluations -------------------------------------
               
        for i = 2:n,
            for k = 1:numfcs
                zdata(i, (j_beg(k):j_end(k))) = feval (f{k}, xdata(i, :));
            end
        end
    end
    
end

%--- Create column names -------------------------------------------------------

colnames = cell (1, size (zdata, 2));

for k = 1:numfcs
    
    if ~ isempty (fcolnames{k})  % We have column names, let's use them
                
        % Special case: only one function, without a nice short displayable name
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

%--- Create output stk_dataframe object ----------------------------------------

z = stk_dataframe (zdata, colnames);
z.info = 'Created by stk_feval';

if isa (x, 'stk_dataframe'),
    z.rownames = x.rownames;
end
    
end % function stk_feval


%!shared f xt
%! f = @(x)(- (0.7 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
%! xt = stk_sampling_regulargrid (20, 1, [0; 1]);

%!error  yt = stk_feval ();
%!error  yt = stk_feval (f);
%!test   yt = stk_feval (f, xt);
%!test   yt = stk_feval (f, xt, false);
%!error  yt = stk_feval (f, xt, false, pi^2);

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

%!shared t z_ref n
%! n = 20;
%! t = stk_sampling_regulargrid (n, 1, [0; 2*pi]);
%! z_ref = [sin(t.data) cos(t.data)];

%!test
%! t.colnames = {'time'};
%! z = stk_feval ({@sin @cos}, t);
%! assert (isa (z, 'stk_dataframe'));
%! assert (isequal (z.data, z_ref));

%!test
%! F = @(x)([sin(x) cos(x)]);
%! z = stk_feval (F, t);
%! assert (isequal (z.data, z_ref));

%!test
%! t = stk_sampling_regulargrid (n, 1, [0; 2*pi]);
%! F = {'sin' 'cos'};
%! z = stk_feval (F, t);
%! assert (isequal (z.data, [sin(t.data) cos(t.data)]));
%! assert (isequal (z.colnames, {'sin' 'cos'}));

%!test
%! F = @(t)([sin(t) cos(t)]);
%! G = @(t)(0.365 * t^2 + (cos ((t - 1)*(t - 2) + 0.579033)));
%! z = stk_feval ({@sin @cos G F 'tan'}, t);
%! assert (isequal (z.colnames, {'sin' 'cos' 'F3' 'F4_1' 'F4_2' 'tan'}));

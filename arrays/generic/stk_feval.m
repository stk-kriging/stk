% STK_FEVAL evaluates a function at given evaluation points
%
% CALL: Z = stk_feval (F, X)
%
%    evaluates the function F on the evaluation points X, where
%
%     * F can be either a function handle or a function name (string), and
%     * X can be either a numerical array or a dataframe.
%
%    The output Z is a one-column dataframe, with the same number of rows as X,
%    and the function name of F as variable name.
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
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

if ischar (f),
    numfcs = 1;
    f_{1} = f;
    zname{1} = f;
elseif isa (f, 'function_handle')
    numfcs = 1;
    f_{1} = f;
    zname{1} = func2str(f);
elseif isa (f, 'cell');
    numfcs = numel(f);
    for l = 1:numfcs
        if ~isa (f{l}, 'function_handle')
            errmsg = 'Argument ''f'' is not a cellarray of function handles.';
            stk_error (errmsg, 'IncorrectType');
        end
        zname{l} = func2str (f{l}); %#ok<AGROW>
    end
    f_ = f;
else
    errmsg = 'Incorrect type for argument ''f''.';
    stk_error (errmsg, 'IncorrectType');
end

if nargin < 3,
    progress_msg = false;
else
    if ~ islogical (progress_msg),
        errmsg = 'Incorrect type for argument ''progress_msg''.';
        stk_error (errmsg, 'IncorrectType');
    end
end

[n, d] = size (x);
if d == 0,
    error ('zero-dimensional inputs are not allowed.');
end

if n == 0, % no input => no output
    
    zdata = zeros (0, numfcs);
    
else % at least one input point
    
    zdata = zeros (n, numfcs);
    
    for i = 1:n,
        if progress_msg, fprintf ('feval %d/%d... ', i, n); end
        for l=1:numfcs
            zdata(i, l) = feval (f_{l}, xdata(i, :));
        end
        if progress_msg, fprintf ('done.\n'); end
    end
    
end

z = stk_dataframe (zdata, zname);
z.info = 'Created by stk_feval';

if isa (x, 'stk_dataframe'),
    z.rownames = x.rownames;
end

end % function stk_feval


%!shared f xt
%!  f = @(x)(- (0.7 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
%!  xt = stk_sampling_regulargrid (20, 1, [0; 1]);

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

%!test
%! t = stk_sampling_regulargrid (10, 1, [0; 2*pi]);
%! t.colnames = {'time'};
%! z = stk_feval ({@sin @cos}, t);
%! assert (isa (z, 'stk_dataframe'));
%! assert (all (size(z) == [10, 2]) );
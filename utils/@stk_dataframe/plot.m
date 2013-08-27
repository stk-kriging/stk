% PLOT [overloaded base function]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@supelec.fr>

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

function plot(x, z, varargin)

xx = double(x);
zz = double(z);

if size(xx, 2) > 1,
    
    stk_error('Incorrect size for argument x.', 'IncorrectSize');
    
else % ok, the first argument has one (and only one) column
    
    plot(xx, zz, varargin{:});
    
    if isa(x, 'stk_dataframe') && ~isempty(x.vnames)
        xlabel(x.vnames{1}, 'FontWeight', 'bold');
    end
    
    if isa(z, 'stk_dataframe') && ~isempty(z.vnames)
        if size(zz, 2) == 1,
            ylabel(z.vnames{1}, 'FontWeight', 'bold');
        else
            legend(z.vnames);
        end
    end
    
end % if

end % function plot

%!test % plot with x as a vector and z as a (univariate) dataframe
%! x = linspace(0, 2*pi, 30)';
%! z = stk_dataframe(sin(x));
%! figure; plot(x, z); close(gcf);

%!test % plot with x as a vector and z as a (multivariate) dataframe
%! x = linspace(0, 2*pi, 30)';
%! z = stk_dataframe([sin(x) cos(x)], {'sin' 'cos'});
%! figure; plot(x, z); close(gcf);

%!test % plot with x as a dataframe and z as a vector
%! x = stk_dataframe(linspace(0, 2*pi, 30)');
%! z = sin(double(x));
%! figure; plot(x, z); close(gcf);

%!error % the first argument should have one and only one column
%! x = stk_dataframe(rand(10, 2));
%! z = stk_dataframe(rand(10, 1));
%! plot(x, z);

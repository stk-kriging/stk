% STK_SPRINTF_LEVELS prints the levels of a factorial design into a string

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
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

function s = stk_sprintf_levels (x)

colnames = get (x.stk_dataframe, 'colnames');

d = length (x.levels);

for i = 1:d
    
    if isempty (colnames)
        line{i} = sprintf('levels for column #%d: ', i);
    else
        line{i} = sprintf('levels for variable %s: ', colnames{i});
    end
    
    L = x.levels{i};
    if isempty (L)
        line{i} = [line{i} '[]'];
    else
        for j = 1:(length(L) - 1)
            line{i} = [line{i} num2str(L(j)) ', '];
        end
        line{i} = [line{i} sprintf('%s', num2str(L(end)))];
    end
    
end

s = char (line{:});

end % function

% RUN_ALL_EXAMPLES runs all examples to check for errors

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version:   1.0
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%

clear all; close all; clc;

NB_EXAMPLES = 7;
script_name = cell(1, NB_EXAMPLES);
err = cell(1, NB_EXAMPLES);

for example_num = 1:NB_EXAMPLES,
    try
        script_name{example_num} = sprintf('example%02d', example_num);
        run(script_name{example_num});
    catch e
        err{example_num} = e;
    end
end

for example_num = 1:NB_EXAMPLES,
    fprintf('%s : ', script_name{example_num});
    if isempty(err{example_num})
        fprintf('ok\n');
    else
        fprintf('%s\n', err{example_num}.identifier);
    end
end

close all;

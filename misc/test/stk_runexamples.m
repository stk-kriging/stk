% STK_RUNEXAMPLES checks that all the examples run without errors.

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>
%
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

function stk_runexamples()

% run all examples, recursively
example_dir = fullfile(stk_get_root(), 'examples');
[scriptname, err] = stk_runexamples_recurs_(example_dir);

% display a summary
stk_disp_framedtext('stk_runexamples summary');

for i = 1:length(scriptname)
    fprintf('[%02d] %s %s ', i, scriptname{i}, ...
        repmat('.', 1, 30 - length(scriptname{i})));
    if isempty(err{i})
        fprintf('OK\n');
    else
        id = err{i}.identifier;
        if isempty(id),
            fprintf('ERROR (no identifier provided)\n');
        else
            fprintf('%s\n', id);
        end
    end
end

assignin('base', 'stkRunExamplesErrors', err);

fprintf('\n');

end % function stk_runexamples


function [scriptname, err] = stk_runexamples_recurs_(example_dir)

s = dir(example_dir);

scriptname = {};
err = {};

for i = 1:length(s),
    
    if s(i).isdir && (s(i).name(1) ~= '.')
        [n, e] = stk_runexamples_recurs_(fullfile(example_dir, s(i).name));
        scriptname = [scriptname n];
        err = [err e];
    else
        if ~isempty(regexp(s(i).name, '^stk_example.*.m$'))
            scriptname{end+1} = s(i).name(1:end-2);
            err{end+1} = stk_runscript(fullfile(example_dir, scriptname{end}));
            drawnow; pause(1.0); close all;
        end
    end
    
end

end % function stk_runexamples_recurs_

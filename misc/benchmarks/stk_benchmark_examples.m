% STK_BENCHMARK_EXAMPLES benchmarks all examples

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

function results = stk_benchmark_examples (nb_rep)

% Number of repetitions for each example script?
if nargin < 1
    nb_rep = 5;
end

% Save results
results = [];

% Browse example directory
d0 = fileparts (which ('stk_init'));
d0 = fullfile (d0, 'examples');
S0 = dir (d0);
for i = 1:(length (S0))
    if S0(i).isdir && (S0(i).name(1) ~= '.')
        
        % Browse sub-directory
        d1 = fullfile (d0, S0(i).name);
        S1 = dir (d1);
        for j = 1:(length (S1))
            if regexp (S1(j).name, '^stk_example.*\.m')
                
                res.name = S1(j).name;
                res.fullname = fullfile (d1, S1(j).name);
                res.runtime = zeros (1, nb_rep);
                
                % Run and time
                for k = 1:nb_rep
                    t0 = tic ();
                    try
                        run_in_isolation (res.fullname);
                        res.runtime(k) = toc (t0);
                    catch
                        toc (t0);  % stop the timer
                        res.runtime(k) = nan;
                    end
                    close all;  drawnow ();
                end
                
                res.median_runtime = median (res.runtime);
                if isempty (results)
                    results = res;
                else
                    results(end+1) = res;
                end
            end
        end
    end
end

% Display tic/toc results
for i = 1:(length (results))
    fprintf ('%20s: %7.3f sec\n', results(i).name, results(i).median_runtime);
end

end % function


function run_in_isolation (fullname)

run (fullname);
drawnow ();

end % function

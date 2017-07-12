% STK_BENCHMARK_  Benchmark stk_predict

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

function t = stk_benchmark_ (testfun, nargout, nrep)

varargout = cell (1, nargout);

% First, warm up + choose number of repetitions
nrep_internal = 1;
ok = false;
while ~ ok
    
    tic;
    for ii = 1:nrep_internal
        [varargout{:}] = testfun ();  %#ok<*NASGU>
    end
    t_ = toc ();
    
    if t_ > 1e-2
        ok = true;
    else
        nrep_internal = nrep_internal * 2;
    end
end

% Do the actual measurements
t = zeros (1, nrep);
for i = 1:nrep
    
    tic;
    for ii = 1:nrep_internal
        [varargout{:}] = testfun ();  %#ok<*NASGU>
    end
    t(i) = toc / nrep_internal;
    
end

end % function

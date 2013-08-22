% SET...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function kreq = set(kreq, propname, value)

% This class implements GREEDY EVALUATION: computations are made as soon as the
% required inputs are made available.

switch propname
    
    case 'xi'
        
        kreq.xi        = double (value);
        kreq.LS_Q      = []; % need to be recomputed
        kreq.LS_R      = []; % need to be recomputed
        kreq.RS        = []; % need to be recomputed
        kreq.lambda_mu = []; % need to be recomputed
        
        kreq = do_compute (kreq);
        
    case 'xt'
        
        kreq.xt        = double (value);
        kreq.RS        = []; % need to be recomputed
        kreq.lambda_mu = []; % need to be recomputed

        kreq = do_compute (kreq);
        
    otherwise
        
        error ('Unknown property.');
        
end
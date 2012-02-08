% STK_SAMPLING_MAXIMINLHS builds a maximin LHS design
%
% CALL: x = stk_sampling_maximinlhs(n, d, box, niter)
%
% FIXME: documentation incomplete

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%          =================================================
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
function x = stk_sampling_maximinlhs(n, d, box, niter)

if (nargin < 3) || isempty(box)
    xmin = zeros(1, d);
    xmax = ones(1, d);
else
    if ~isequal(size(box), [2, d]),
        error('box should be a 2xd array');
    end
    xmin = box(1,:);
    xmax = box(2,:);
end

if nargin < 4,
    niter = 1000;
end

if n == 0, % no input => no output
    
    xdata = zeros(0, d);
    
else % at least one input point
    
    xmin  = reshape(xmin, 1, d); % make sure we work we row vectors
    delta = reshape(xmax, 1, d) - xmin;   assert(all(delta > 0));
    
    xx = lhsdesign_(n, d, niter);
    
    xdata = ones(n, 1) * xmin + xx * diag(delta);
    
end

x = struct( 'a', xdata );

end


%%%%%%%%%%%%%%%%%%
%%% lhsdesign_ %%%
%%%%%%%%%%%%%%%%%%

function x = lhsdesign_( n, d, niter)

bestscore = 0;
x = [];

for j = 1:niter
    y = generatedesign_(n, d);    
    score = stk_mindist(y);    
    if isempty(x) || (score > bestscore)
        x = y;
        bestscore = score;
    end
end

end


%%%%%%%%%%%%%%%%%%%%%%%
%%% generatedesign_ %%%
%%%%%%%%%%%%%%%%%%%%%%%

function x = generatedesign_( n, d )

x = zeros(n, d);

for i = 1:d % for each dimension, draw a random permutation
    [sx, x(:,i)] = sort(rand(n,1)); %#ok<ASGLU>
end

x = (x - rand(size(x))) / n;

end

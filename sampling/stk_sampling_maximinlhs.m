% STK_SAMPLING_MAXIMINLHS builds a maximin LHS design
%
% CALL: x = stk_sampling_maximinlhs( n, d, box, niter )
%
% FIXME: documentation incomplete

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%          =================================================
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.0.2
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
function x = stk_sampling_maximinlhs( n, d, box, niter )

if (nargin < 3) || isempty(box)
    xmin = zeros(1,d);
    xmax = ones(1,d);
else
    [s1,s2] = size(box);
    if ~( (s1==2) && (s2==d) ),
        error('box should be a 2xd array');
    end
    xmin = box(1,:);
    xmax = box(2,:);
end

if nargin < 4,
    niter = 1000;
end

% NOT COMPATIBLE WITh OCTAVE
% validateattributes( n, {'numeric'}, {'integer','scalar','>=',0} ); 
% validateattributes( d, {'numeric'}, {'integer','scalar','>=',1} ); 
% validateattributes( xmin, {'numeric'}, {'vector','finite','nonnan'} );
% validateattributes( xmax, {'numeric'}, {'vector','finite','nonnan'} );

if n == 0, % no input => no output
    
    xdata = zeros(0,d);
    
else % at least one input point
    
    xmin  = reshape( xmin, 1, d ); % make sure we work we row vectors
    delta = reshape( xmax, 1, d ) - xmin;   assert(all( delta > 0 ));
    
    xx = lhsdesign_( n, d, niter );
    
    xdata = ones(n,1)*xmin + xx*diag(delta);

end

x = struct( 'a', xdata );

end

function X = lhsdesign_( n, d, niter)
   bestscore = 0;
   
   for j=1:niter
      x = generatedesign_ (n, d);
      
      score = score_(x);
      
      if score > bestscore
         X = x;
         bestscore = score;
      end
   end
end

function x = generatedesign_( n, d )

x = zeros(n,d);
for i=1:d % for each dimension, do a randperm
    [sx, idx] = sort(rand(n,1));
    x(:,i) = idx;
end

x = x - rand(size(x));

x = x / n;
end

function s = score_(x)
% compute score
   s = min(pdist(x));
end
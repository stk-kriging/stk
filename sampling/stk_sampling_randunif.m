% STK_SAMPLING_RANDUNIF yields uniformly distributed points on a box domain
%
% CALL: x = stk_sampling_randunif( n, d, box )
%
% STK_SAMPLING_RANDUNIF performs Monte-Carlo sampling with independent 
% uniform distributions
%
% FIXME: documentation incomplete

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%          =================================================
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
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
function x = stk_sampling_randunif( n, d, box )

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


% NOT COMPATIBLE WITh OCTAVE
% validateattributes( n, {'numeric'}, {'integer','scalar','>=',0} ); 
% validateattributes( d, {'numeric'}, {'integer','scalar','>=',1} ); 
% validateattributes( xmin, {'numeric'}, {'vector','finite','nonnan'} );
% validateattributes( xmax, {'numeric'}, {'vector','finite','nonnan'} );

if (length(n)~=1) && (length(n)~=d)
    error('n should either be a scalar or a vector of length d');
end

if n==0, % empty sample
    
    xdata = zeros(0,d);
    
else % at least one input point
        
    xmin  = reshape( xmin, 1, d ); % make sure we work we row vectors
    delta = reshape( xmax, 1, d ) - xmin;   assert(all( delta > 0 ));
    
    xx = rand( n, d );
    
    xdata = ones(n,1)*xmin + xx*diag(delta);

end

x = struct( 'a', xdata );

end

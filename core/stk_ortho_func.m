% STK_ORTHO_FUNC basis functions for the mean
%
% CALL: P = stk_ortho_func( x, model )
%
% STK_ORTHO_FUNC computes basis functions to deal with the mean of the
% random process
%
% FIXME: documentation incomplete
% 
% EXAMPLE: see examples/example02.m

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.0.2
%    Authors:   Julien Bect      <julien.bect@supelec.fr>
%               Emmanuel Vazquez <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging/
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
function P = stk_ortho_func( x, model )

if ~isfield(model,'Kx_cache'), % SYNTAX: x(factors), model            
    P = stk_ortho_func_( x, model.order );
        
else % SYNTAX: x(indices), model    
    if ~isfield(model,'Px_cache'),
        P = zeros( size(model.Kx_cache,1), 0 );
    else
        P = model.Px_cache( x, : );
    end

end

end

%%%%%%%%%%%%%%%%%%%%%%%
%%% stk_ortho_func_ %%%
%%%%%%%%%%%%%%%%%%%%%%%

function P = stk_ortho_func_( x, order )

[n,d] = size( x.a );

switch order
    
    case -1, % 'simple' kriging
        P = [];
    
    case 0, % 'ordinary' kriging
        P = ones(n,1);
    
    case 1, % linear trend
        P = [ ones(n,1) x.a ];
    
    case 2, % quadratic trend
        P = [ ones(n,1) x.a zeros(n,d*(d+1)/2) ];
        k = d+2;
        for i = 1:d
            for j = i:d
                P(:,k) = x.a(:,i) .* x.a(:,j);
                k = k+1;
            end
        end
    
    otherwise, % syntax error
        error('order should be in {-1,0,1,2}');

end

end

% STK_NARGINCHK checks whether the number of input arguments is acceptable.
%
% CALL: stk_narginchk(n_low, n_high)
%
%   checks whether the number of input arguments in the calling function is
%   between n_low and n_high, and throws an exception if it's note the case.
%
% CALL: [err_msg, err_mnemonic] = stk_narginchk(n_low, n_high)
% 
%   returns the error message and error mnemonic instead of throwing the
%   exception. The mnemonic is either 'NotEnoughInputArgs' (if the first
%   condition is violated) or 'TooManyInputArgs' (if the second condition is
%   violated).
%
% NOTES: 
%  * Although the exception is actually raised by stk_narginchk(), everything
%    looks like it has been sent by the calling function.
%  * Both Matlab and Octave have a function that does this, but unfortunately
%    they have different names (narginchk() in Matlab, nargchk() in Octave) and
%    different calling syntaxes.

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
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

function [err_msg, err_mnemonic] = stk_narginchk(n_low, n_high)

NOT_ENOUGH_MSG = 'Not enough input arguments.';
NOT_ENOUGH_MNEMONIC = 'NotEnoughInputArgs';

TOO_MANY_MSG = 'Too many input arguments.';
TOO_MANY_MNEMONIC = 'TooManyInputArgs';

% Such a funny mistake to do, when calling stk_narginchk()...
if nargin < 2,
    stk_error(NOT_ENOUGH_MSG, NOT_ENOUGH_MNEMONIC);
elseif nargin > 2,
    stk_error(TOO_MANY_MSG, TOO_MANY_MNEMONIC);
end

% Check that stk_narginchk has been called from a function.
stack = dbstack();
if length(stack) == 1,
    err_msg = 'stk_narginchk() must be called from a function';
    stk_error(err_msg, 'MustBeCalledFromAFunction');
end
    
n_argin = evalin('caller', 'nargin');
err_msg = [];
if n_argin < n_low,
    err_msg = NOT_ENOUGH_MSG;
    err_mnemonic = NOT_ENOUGH_MNEMONIC;
elseif n_argin > n_high,
    err_msg = TOO_MANY_MSG;
    err_mnemonic = TOO_MANY_MNEMONIC;
end

% If one of the conditions is violated AND no output argument is requested,
% then we throw an error
if (nargout == 0) && ~isempty(err_msg),
    % Pretend that the error has been thrown by the caller
    stack = stack(2:end);
    % And now we proceed to throw the exception.
    stk_error(err_msg, err_mnemonic, stack);
end

end % stk_narginchk

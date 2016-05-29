function ml_nv = set(ml_nv, propname, value)
% cstnoisevar = set(ml_nv, propname, value)
%
% Change multi-level noise variance parameter properties.

switch propname
    case 'lognoisevar'
        value = double(value);                              % assert class
        value = stk_checkSize(ml_nv.lognoisevar, value);    % check size
        ml_nv.lognoisevar = value;                          % change values
        
    case 'levels'
        value = double(value);	% assert class
        
        try
            value = stk_checkSize(ml_nv.levels, value); %if no problem,...
            ml_nv.levels = value;                       % change value
        catch err
           if strcmp(err.identifier, 'STK:stk_checkSize:IncorrectSize')
               %else, if the user would like to change the number of levels
               value = value(:)';
               
               nbOldLevel = length(ml_nv.levels);
               nbNewLevel = length(value);
               
               if nbOldLevel < nbNewLevel
                   % add new levels
                   ml_nv.levels = value;
                   ml_nv.lognoisevar = [ml_nv.lognoisevar, NaN*ones(1, nbNewLevel - nbOldLevel)];
               else %nbOldLevel > nbNewLevel
                  % delete old levels
                  ml_nv.levels = value;
                  ml_nv.lognoisevar = ml_nv.lognoisevar(1:nbNewLevel);
               end
           else % otherwise, launch the error
               throw(err);
           end
        end
        
    otherwise
        stk_error(['The nested design has not any property whose name is ',...
            propname, '.'], 'InvalidArgument')
end
end


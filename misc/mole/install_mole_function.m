function install_mole_function (function_name, mole_dir, do_addpath, prune_unused)

function_dir = fullfile (mole_dir, function_name);

if isempty (which (function_name)),  % if the function is absent
    
    function_mfile = fullfile (function_dir, [function_name '.m']);
    
    if exist (function_dir, 'dir') && exist (function_mfile, 'file')
        
        % fprintf ('[MOLE]  Providing function %s\n', function_name);
        if do_addpath,
            addpath (function_dir);
        end
        
    else
        
        warning (sprintf ('[MOLE]  Missing function: %s\n', function_name));
        
    end
    
elseif prune_unused && (exist (function_dir, 'dir'))
        
    rmdir (function_dir, 's');
        
end

end % function install_mole_function

%#ok<*SPWRN>

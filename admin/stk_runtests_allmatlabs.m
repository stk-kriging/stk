function stk_runtests_allmatlabs (matlab_basedir, output_dir)

fprintf ('\n/******************************\\\n' );
fprintf (  '|**  stk_runtests_allmatlabs **|\n'  );
fprintf ( '\\******************************/\n\n');

% Name of Matlab's executable
exe_name = 'matlab';
c = computer ();
if strcmp (c(1:3), 'win')
    exe_name = [exe_name '.exe'];
end

% Output directory
if nargin < 2
    output_dir = fileparts (mfilename ('fullpath'));
end
output_dir = fullfile (output_dir, ...
    'stk_runtests_allmatlabs', datestr(now, 'yyyymmdd-HHMMSS'));
mkdir (output_dir);

% STK directory
stk_dir = fileparts (which ('stk_version'));

% Scan directories
s = dir (matlab_basedir);
for i = 1:(length (s))
    if s(i).isdir && (~ (s(i).name(1) == '.'))

        % Check if this is looks like a Matlan directory
        matlab_bin = fullfile (matlab_basedir, s(i).name, 'bin', exe_name);
        if ~ exist (matlab_bin, 'file')
            continue
        end
        fprintf ('found: %s\n', matlab_bin);
        
        % Outut directory
        output_dir_ = fullfile (output_dir, s(i).name);
        mkdir (output_dir_);

        % Command to run in Matlab
        cmd0 = sprintf ([                          ...
            'cd (''%s'');  stk_init ();  ',        ...
            'stk_runtests ({}, ''save'', true, ',  ...
            '''output_dir'', ''%s'');  quit'], stk_dir, output_dir_);

        % System command to start Matlab
        % (old versions of Matlab do not have -sd and -batch)
        cmd = sprintf ('%s -nosplash -nodesktop -r "%s"', ...
            matlab_bin, cmd0);

        fprintf ('\ncmd = %s\n\n\n', cmd);

        % Ok, run the tests
        system (cmd);
    end
end

% Summarize outputs
tab = stk_runtests_allmatlabs_summary (output_dir);
disp (tab);

end % function

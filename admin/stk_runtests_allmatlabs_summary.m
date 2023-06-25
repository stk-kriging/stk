function tab = stk_runtests_allmatlabs_summary (output_dir)

% Prepare table
tab = {'Release', 'TOTAL', 'PASS', 'XFAIL', 'FAIL'};

% Scan output directory
s = dir (output_dir);
for i = 1:(length (s))
    if s(i).isdir && (s(i).name(1) == 'R')

        mat_file = fullfile (output_dir, s(i).name, 'stk_runtests.mat');
        if ~ exist (mat_file, 'file')
            continue
        end

        fprintf ('found: %s\n', s(i).name);

        tmp = load (mat_file);

        n_total = tmp.test_results.n_total;
        n_pass  = tmp.test_results.n_pass;
        n_xfail = tmp.test_results.n_xfail;
        n_fail  = n_total - n_pass - n_xfail;

        tab(end+1, :) = {s(i).name ...
            n_total n_pass n_xfail n_fail};  %#ok<AGROW>

    end % if
end % for

% Convert output to table if tables are available
if exist ('cell2table')  %#ok<EXIST>
    tab = cell2table (tab(2:end, 2:end), ...
        'VariableNames', tab(1, 2:end), 'RowNames', tab(2:end, 1));
end

end % function

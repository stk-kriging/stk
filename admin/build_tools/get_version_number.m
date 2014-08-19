function version_number = get_version_number ()

version_number = stk_version ();

pos = regexp (version_number, '[^\d\.]', 'once');
if ~ isempty (pos)
    original_version_number = version_number;
    version_number (pos:end) = [];
    warning (sprintf ('Truncating version number %s -> %s', ...
        original_version_number, version_number));
end

fprintf ('Version number: %s\n', version_number);

end

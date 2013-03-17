function b = get_column_indicator(x, s)

b = strcmp(s, x.vnames);

if ~any(b)
    if ~strcmp(s, 'a')
        errmsg = sprintf('There is no variable named %s.', idx(1).subs);
        stk_error(errmsg, 'UnknownVariable');
    else
        b = strcmp('mean', x.vnames);
        if any(b)
            warning(sprintf(['There is no variable named ''a''.\n' ...
                ' => Assuming that you''re an old STK user trying to ' ...
                'get the kriging mean.'])); %#ok<WNTAG,SPWRN>
        else
            warning(sprintf(['There is no variable named ''a''.\n' ...
                ' => Assuming that you''re an old STK user trying to ' ...
                'get the entire dataframe.'])); %#ok<WNTAG,SPWRN>
            b = true(size(b));
        end
    end
end

end % function get_column_indicator

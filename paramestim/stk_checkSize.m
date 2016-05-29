function newVal = stk_checkSize( oldVal, newVal )
% newVal = stk_checkSize( oldVal, newVal )
%
% Resize a new proposed value to the sizes of an old value.

[siz1, siz2] = size(oldVal);
[len1, len2] = size(newVal);

if (siz1 ~= len1) || (siz2 ~= len2)%if sizes do not fit,...
    if (siz1 == len2) && (siz2 == len1)%try transpose, ...
        newVal = newVal';
    elseif (siz1 == len1*len2) && (siz2 == 1)%try vector, ...
        newVal = reshape(newVal, len1, len2);
    elseif (siz1 == 1) && (siz2 == len1*len2)%try row vector, ...
        newVal = reshape(newVal', len1, len2);
    else
        stk_error(['The old value has size ', num2str(siz1),...
            'x', num2str(siz2),', but the new value has size ',...
            num2str(len1), 'x', num2str(len2), '.'], 'IncorrectSize')
    end
end
%else, do not change anything, the new value has the good dimensions.

end


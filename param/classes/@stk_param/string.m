function str = string(param)
% str = string(param)
%
% Write a parameter as a multi-row string

%% Name of properties to display
fields = fieldnames(param);             %the properties of covar_param
nameLength = zeros(length(fields), 1);	%the lenght of each properties names
maxNameLength = 0;                      %the maximum lenght of names

for kn = 1:length(nameLength)
    nameLength(kn, 1) = length(fields{kn, 1});
    if nameLength(kn, 1) > maxNameLength
        maxNameLength = nameLength(kn, 1);
    end
end%get back the longest property name length

%% Write properties
stringToDisplay = '';%first line, to initialize
for kf = 1:length(fields)
    property = get(param, fields{kf, 1});
    stringProperty = [repmat(' ', 1, maxNameLength - nameLength(kf, 1)),...
        fields{kf, 1}, ' : '];%complete the name by empty caracheter,
    %to align the ':'
    switch class(property)
        case 'char'
            stringProperty = ...
                [ [stringProperty; repmat(' ', size(property, 1) - 1, maxNameLength + 3)]...
                , property];
            
        case 'double'
            charProp = num2str(property);%convert num (matrix) to string
            stringProperty = ...
                [ [stringProperty; repmat(' ', size(property, 1) - 1, maxNameLength + 3)]...
                , charProp];
            
        case 'logical'
            charProp = num2str(property);%convert bool (matrix) to string
            charProp = cellstr(charProp);
            charProp = strrep(charProp, '0', 'false');  %change 0 and 1 
            charProp = strrep(charProp, '1', 'true ');  % by true and false
            charProp = char(charProp);
            stringProperty = ...
                [ [stringProperty; repmat(' ', size(property, 1) - 1, maxNameLength + 3)]...
                , charProp];
            
        otherwise
            stringProperty = strcat(stringProperty, ...
                [' < ', class(property), ' >']);
    end
    
    stringToDisplay = char (stringToDisplay, stringProperty);%vertical concatenation
end

stringToDisplay = stringToDisplay(2:(size(stringToDisplay, 1)), :);
%delete the first line, which is empty
str = stringToDisplay;
end


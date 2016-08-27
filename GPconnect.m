function [ obj1 ] = GPconnect( ind )
%Connect GPIB device
%   Connect via GPIB a device with index ind

% Find a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', ind, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', 0, ind);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);
end
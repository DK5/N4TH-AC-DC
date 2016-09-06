obj1 = instrfind('Type', 'serial', 'Port', 'COM1', 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial('COM1');
else
    fclose(obj1);
    obj1 = obj1(1)
end
Hornet = serial('COM3');    % specify com #
fopen(Hornet);

%% Get Pressure
pres = query(Hornet,'#01RDS');
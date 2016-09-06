Hornet = instrfind('Type', 'serial', 'Port', 'COM1', 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(Hornet)
    Hornet = serial('COM1','BaudRate',19200,'DataBits',8,'StopBits',1,'Terminator','CR');
else
    fclose(Hornet);
    Hornet = Hornet(1);
end
fopen(Hornet);

%% Get Pressure
pres = query(Hornet,'#01RDS');
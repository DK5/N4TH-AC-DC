Hornet = serial('COM3');    % specify com #
fopen(Hornet);

%% Get Pressure
pres = query(Hornet,'#01RDS');
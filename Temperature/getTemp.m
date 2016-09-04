function [ Temp ] = getTemp(volt_obj,Isrc)
%getTemp(volt_obj,Isrc) returns thermometer temperature
%   volt_obj - voltmeter obj
%   Isrc     - current in the thermometer

% fprintf(volt_obj,'*TRG');	% Send trigger
voltRead = NaN;
while(isnan(voltRead))
    data = query(volt_obj, ':sense:data:latest?');	% Request all stored readings
    voltRead = str2double(strsplit(data,','));	% Export readings to array
end
Temp = Res2Temp(voltRead/Isrc);

end
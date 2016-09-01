function [ Temp ] = getTemp(volt_obj,Isrc)
%getTemp(volt_obj,Isrc) returns thermometer temperature
%   volt_obj - voltmeter obj
%   Isrc     - current in the thermometer

fprintf(volt_obj, ':trace:feed:control never');	% Stop storing readings
data = query(volt_obj, ':data:data?');          % Request all stored readings
fprintf(volt_obj, ':trace:clear');              % Clear buffer
fprintf(volt_obj, ':trace:feed:control next');	% Start storing readings
voltRead = NaN;
while(isNaN(voltRead))
    voltRead = str2double(strsplit(data,','));	% Export readings to array
end
Temp = Res2Temp(voltRead/Isrc);

end


function protVoltage( voltage , HP_obj )
%supCurrent sets voltage protection level. If the output voltage 
% exceeds the over protection level (OVP), then the power supply output is disabled
%   voltage - voltage protection level (volts)
%   HP_obj  - GPIB object of the power supllier
fprintf(HP_obj,'PROT:STAT ON'); % turn on protection level
fprintf(HP_obj,['VOLT:PROT ',num2str(voltage)]);
end
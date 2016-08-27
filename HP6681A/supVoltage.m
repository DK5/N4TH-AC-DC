function supVoltage( voltage , HP_obj )
%supvoltage supplies voltage through the HP power supplier
%   voltage - voltage to be supplied (Volts)
%   HP_obj  - GPIB object of the power supllier
% fprintf(HP_obj,'SOUR:VOLT MIN');
fprintf(HP_obj,['SOUR:VOLT ',num2str(voltage)]);
end
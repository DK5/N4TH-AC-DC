function [ voltage ] = getVoltage( HP_obj )
%GETCURRENT returns the measured voltage by the power supplier sense
%terminals.
%   HP_obj - GPIB object of the power supllier
voltage = query(HP_obj,'MEAS:VOLT?');
end
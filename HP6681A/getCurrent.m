function [ current ] = getCurrent( HP_obj )
%GETCURRENT returns the measured current by the power supplier sense
%terminals.
%   HP_obj - GPIB object of the power supllier
current = query(HP_obj,'MEAS:CURR?');
end
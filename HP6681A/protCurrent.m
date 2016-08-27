function protCurrent( current , HP_obj )
%supCurrent sets current protection level. If the output current 
% exceeds the over protection level (OVP), then the power supply output is disabled
%   current - current protection level (Ampere)
%   HP_obj  - GPIB object of the power supllier
fprintf(HP_obj,'CURR:PROT:STAT ON'); % turn on protection level
fprintf(HP_obj,['CURR:PROT ',num2str(current)]);
end
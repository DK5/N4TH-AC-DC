function protClear( HP_obj )
%protClear(HP_obj) clears any protection levels that were set previously
%   voltage - voltage protection level (volts)
%   HP_obj  - GPIB object of the power supllier
fprintf(HP_obj,'OUTP:PROT:CLE'); % turn on protection level
end
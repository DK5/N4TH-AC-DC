function supCurrent( current , HP_obj )
%supCurrent supplies current through the HP power supplier
%   current - current to be supplied (Ampere)
%   HP_obj  - GPIB object of the power supllier
fprintf(HP_obj,['SOUR:CURR ',num2str(current)]);
end
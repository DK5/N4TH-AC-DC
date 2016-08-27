function output( state , HP_obj )
%output controls turns off/on the power supplier
%   state - on|1 or off|0
%   HP_obj  - GPIB object of the power supllier
if ~ischar(state)
    state = num2str(state);
end
fprintf(HP_obj,['OUTP ',state]);
end
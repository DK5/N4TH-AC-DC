function outputXFR( state , XFR_obj )
%XFRoutput turns off/on the power supplier
%   state - on|1 or off|0
%   XFR_obj  - GPIB object of the power supllier
if ~ischar(state)
    state = num2str(state);
end
fprintf(XFR_obj,['OUT ',state]);
end
function [ errorStr ] = getError( HP_obj )
%getError gets the returned error from the HP 
errorStr = query(HP_obj,'syst:err?');
end
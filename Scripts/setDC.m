function [ outDC ] = setDC( iDC , pwr_obj , N4TH )
%setAC(iDC,pwr_obj,N4TH) executes feedback loop on AC current
%   iDC - desired DC current
%   pwr_obj  - power supplier object
%   N4TH- N4TH object

output(0,pwr_obj);
supVoltage(5,pwr_obj);  % set voltage to 5 Volts
supCurrent(iDC,pwr_obj);% set current
output(1,pwr_obj);

% read DC current
pause(5);
outDC = getDC(N4TH);

ind = 1;    
% feedback loop
while abs(outDC/iDC - 1) > 0.002
    output(0,pwr_obj);
    outDC = outDC*(iDC/outDC);  % fixing current
    if outDC >= 75 && ind <= 3
        % if amplitude is too high and its under the 3rd try
        fprintf ('Try %i\n',ind);
        fprintf('Current is too high!!! %2.2f volt \n ',outDC);
        fprintf('Cannot reach %2.2fA. Actual current is %2.2fA\n',iDC,outDC);
        % turn off power supplier
        outDC = 0; supCurrent(outDC,pwr_obj);   % set current
        ind = ind+1; outDC = 0.01*ind;
        
    elseif outDC >= 75 && ind > 3;
        % if amplitude is too high and its over the 3rd try
        fprintf ('Couldn''t make it :( \n');
        % turn off power supplier and break
        outDC = 0; supCurrent(outDC,pwr_obj); output(0,pwr_obj); break;
    end
    
    supCurrent(outDC,pwr_obj);	% set current
    output(1,pwr_obj);          % turn output on
    pause(5);                   % wait for power supply
    outDC = getDC(N4TH);        % get DC current
end
end
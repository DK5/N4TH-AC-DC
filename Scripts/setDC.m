function [ outDC ] = setDC( iDC , pwr_obj , N4TH )
%setAC(iDC,pwr_obj,N4TH) executes feedback loop on AC current
%   iDC - desired DC current
%   pwr_obj  - power supplier object
%   N4TH- N4TH object
amp = 1.5 ; % amplification factor of dI/I
damp = 0.005;

outputHP(0,pwr_obj);    % turn off
supVoltage(5,pwr_obj);  % set voltage to 5 Volts
supCurrent(iDC,pwr_obj);% set current
outputHP(1,pwr_obj);    % turn on

% read DC current
pause(5); dt = 1;
out2DC = getDC(N4TH);

ind = 1;    
% feedback loop
while abs(out2DC/iDC - 1) > 0.002
%     outputHP(0,pwr_obj);
    out1DC = out2DC;    % save old current
    pause(1);         % pause before another measure
    out2DC = getDC(N4TH);   % measure current
    dI = abs(out2DC-out1DC)/dt; % calculate difference between two close measurements
    if out2DC < 0.8*iDC
        % low dI, low I (out2DC) --> high outDC
        outDC = iDC*(1+damp/(dI*out2DC))
    else
        % I is close
        outDC = iDC*(1+amp*dI/out2DC)
    end
    
    if outDC >= 15 && ind <= 3
        % if current is too high and its under the 3rd try
        fprintf ('Try %i\n',ind);
        fprintf('Current is too high!!! %2.2f Amps \n ',outDC);
        fprintf('Cannot reach %2.2fA. Actual current is %2.2fA\n',outDC,out2DC);
        % turn off power supplier
%         outDC = 0; supCurrent(outDC,pwr_obj);   % set current
        ind = ind+1; outDC = 0.01*ind;
        
    elseif outDC >= 15 && ind > 3;
        % if amplitude is too high and its over the 3rd try
        fprintf ('Couldn''t make it :( \n');
        % turn off power supplier and break
        outDC = 0; supCurrent(outDC,pwr_obj); outputHP(0,pwr_obj); break;
    end
    
    supCurrent(outDC,pwr_obj);	% set current
%     outputHP(1,pwr_obj);        % turn output on
    pause(3);                   % wait for power supply
    out2DC = getDC(N4TH)        % get DC current
end
end
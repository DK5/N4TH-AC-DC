function [ outDC ] = setDC( iDC , pwr_obj , N4TH )
%setAC(iDC,pwr_obj,N4TH) executes feedback loop on AC current
%   iDC - desired DC current
%   pwr_obj  - power supplier object
%   N4TH- N4TH object
tic;
figure('Name','Temperature control');  % open fig
errInterval = 0.02;

outputHP(0,pwr_obj);        % turn off
supVoltage(5,pwr_obj);  % set voltage to 5 Volts
supCurrent(iDC,pwr_obj);    % set current
outputHP(1,pwr_obj);        % turn on

measDC = getDC(N4TH,1);
    
plot(1:length(measDC),measDC,'-ob',...
    [1 length(measDC)],[iDC iDC],'-r',...
    [1 length(measDC)],(1-errInterval)*[iDC iDC],'-g',...
    [1 length(measDC)],(1+errInterval)*[iDC iDC],'-g');

ylim([measDC 1.5*iDC]); hold off;

dt = 0.1;

stable = 0;
while ~stable
    pause(dt)
    measDC(end+1) = getDC(N4TH);
    err(end+1) = (iDC - measDC(end))/iDC;
 
    plot(1:length(measDC),measDC,'-ob',...
        [1 length(measDC)],[iDC iDC],'-r',...
        [1 length(measDC)],(1-errInterval)*[iDC iDC],'-g',...
        [1 length(measDC)],(1+errInterval)*[iDC iDC],'-g');
    text(1.2,0.5*iDC,num2str(toc));
    ylim([(1-25*errInterval) (1+25*errInterval)]*iDC); hold off;
    
    
    if numel(err) > cor && ~sum(abs(err((end-cor):end)) > errInterval)
        % if last 10 temperatures were in the interval - stop
        stable = 1;
    end
end
toc

end
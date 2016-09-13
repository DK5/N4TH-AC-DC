function [ outDC ] = setDC( iDC , Ilimit , pwr_obj , N4TH )
%setAC(iDC,pwr_obj,N4TH) executes feedback loop on AC current
%   iDC - desired DC current
%   pwr_obj  - power supplier object
%   N4TH- N4TH object
tic;
figure('Name','DC current control');  % open fig
errInterval = 0.02;

outputHP(0,pwr_obj);        % turn off
supVoltage(5,pwr_obj);  % set voltage to 5 Volts
Is = 2*iDC;
if Is > Ilimit
    Is = Ilimit;
end
supCurrent(Is,pwr_obj);    % set current
outputHP(1,pwr_obj);        % turn on

outDC = getDC(N4TH,1);
% outDC = getDC(N4TH);
err = (iDC - outDC)/iDC;
    
plot(1:length(outDC),outDC,'-ob',...
    [1 length(outDC)],[iDC iDC],'-r',...
    [1 length(outDC)],(1-errInterval)*[iDC iDC],'-g',...
    [1 length(outDC)],(1+errInterval)*[iDC iDC],'-g');

% ylim([outDC 1.5*iDC]); 
hold off;

dt = 0.01; cor = 5;
stable = 0; flag = 0;
while ~stable
    pause(dt)
    outDC(end+1) = getDC(N4TH);
    err(end+1) = (iDC - outDC(end))/iDC;
 
    if outDC(end) > 1.01*iDC && ~flag
        supCurrent(iDC,pwr_obj);    % set current
        flag = 1;
    end
    
    plot(1:length(outDC),outDC,'-ob',...
        [1 length(outDC)],[iDC iDC],'-r',...
        [1 length(outDC)],(1-errInterval)*[iDC iDC],'-g',...
        [1 length(outDC)],(1+errInterval)*[iDC iDC],'-g');
    text(1.2,0.5*iDC,num2str(toc));
%     ylim([(1-25*errInterval) (1+25*errInterval)]*iDC);
    hold off;
    
    
    if numel(err) > cor && ~sum(abs(err((end-cor):end)) > errInterval)
        % if last 10 temperatures were in the interval - stop
        stable = 1;
    end
end
toc
outDC = outDC(end);
end
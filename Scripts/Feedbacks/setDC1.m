function [ outDC ] = setDC1( iDC , Ilimit , pwr_obj , N4TH )
%setAC(iDC,pwr_obj,N4TH) executes feedback loop on AC current
%   iDC - desired DC current
%   pwr_obj  - power supplier object
%   N4TH- N4TH object
if ~iDC
    outputHP(0,pwr_obj);      % turn off power supply
    outDC = 0;
    return;
end
    
on = str2double(query(pwr_obj,'OUTP?'));
if ~on
    supCurrent(0,pwr_obj);    % set current
    outputHP(1,pwr_obj);
    pause(5);
end

fprintf(N4TH,'SPEED,WINDOW,0.2');
pause(0.25);

tic;
figure(5);  % open fig ,'Name','DC current control'
errInterval = 0.02;

% outputHP(0,pwr_obj);        % turn off
supVoltage(5,pwr_obj);  % set voltage to 5 Volts
Is = 2*iDC;

outDC = getDC(N4TH,1);
err = (iDC - outDC)/iDC;
above = 0;

% if abs(outDC(end)/iDC) < 0.01
%     Is = iDC; above = 1;
% end

if Is > Ilimit
    Is = Ilimit;
end

supCurrent(Is,pwr_obj);    % set current
outputHP(1,pwr_obj);        % turn on

plot(1:length(outDC),outDC,'-ob',...
    [1 length(outDC)],[iDC iDC],'-r',...
    [1 length(outDC)],(1-errInterval)*[iDC iDC],'-g',...
    [1 length(outDC)],(1+errInterval)*[iDC iDC],'-g');

% ylim([outDC 1.5*iDC]); 
hold off;

dt = 0.01; cor = 10;
stable = 0; steps = 10; ind = steps-1;
steady = 0;

while ~stable
    pause(dt)
    outDC(end+1) = getDC(N4TH);
    err(end+1) = (iDC - outDC(end))/iDC;
 
    if outDC(end) < (1-errInterval)*iDC && ~steady
        while(ind >= 0)
            supCurrent((1+ind/steps)*iDC,pwr_obj);(1+ind/steps)*iDC    % set current
            ind = ind - 1;
            pause(0.3);
        end
    elseif outDC(end) > (1+errInterval)*iDC && ~steady
        supCurrent(0.5*iDC,pwr_obj);0.5*iDC
    else
        supCurrent(iDC,pwr_obj);iDC
        steady = 1;
    end
    
    plot(1:length(outDC),outDC,'-ob',...
        [1 length(outDC)],[iDC iDC],'-r',...
        [1 length(outDC)],(1-errInterval)*[iDC iDC],'-g',...
        [1 length(outDC)],(1+errInterval)*[iDC iDC],'-g');
    title('DC current control')

    text(1.2,0.5*iDC,num2str(toc));
%     ylim([(1-25*errInterval) (1+25*errInterval)]*iDC);
    hold off;
    
    
    if numel(err) > cor && ~sum(abs(err((end-cor):end)) > errInterval)
        % if last 10 readings were in the interval - stop
        stable = 1;
    end
end
toc
outDC = outDC(end);
end
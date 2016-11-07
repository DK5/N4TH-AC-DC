function [ outDC ] = setDC3( iDC , Ilimit , pwr_obj , N4TH )
%setAC(iDC,pwr_obj,N4TH) executes feedback loop on AC current
%   iDC - desired DC current
%   pwr_obj  - power supplier object
%   N4TH- N4TH object
if ~iDC
    outputHP(0,pwr_obj);    % set current
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
Is = 1+0.05*(iDC-1)^2;

outDC = getDC(N4TH,1);
err = (iDC - outDC)/iDC;
above = 0;

if outDC(end) > iDC
    % if reading is above value - set current to desired value
    % will result in slow relaxation
    Is = iDC; above = 1;
end

if Is > Ilimit
    % if initial current is above limit - set current to the limit
    Is = Ilimit;
end

supCurrent(Is,pwr_obj);    % set current
% outputHP(1,pwr_obj);        % turn on

plot(1:length(outDC),outDC,'-ob',...
    [1 length(outDC)],[iDC iDC],'-r',...
    [1 length(outDC)],(1-errInterval)*[iDC iDC],'-g',...
    [1 length(outDC)],(1+errInterval)*[iDC iDC],'-g');

% ylim([outDC 1.5*iDC]); 
hold off;

dt = 0.01; cor = 10;
stable = 0; steps = 10; ind = steps-1;
above
while ~stable
    pause(dt)
    outDC(end+1) = getDC(N4TH);
    err(end+1) = (iDC - outDC(end))/iDC;
 
    if outDC(end) < 1.01*iDC && ~above
        % started below iDC, now above error interval
        while(ind >= 0)
            supCurrent((1+ind/steps)*iDC,pwr_obj);(1+ind/steps)*iDC    % set current
            ind = ind - 1;
            pause(0.3);
        end
    elseif outDC(end) > 1.01*iDC && above 
        % started above iDC, now above error interval
        supCurrent(0.5*iDC,pwr_obj);0.5*iDC
    else
        supCurrent(iDC,pwr_obj);iDC
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
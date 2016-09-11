function setDCpid( iDC , limitDC , pwr_obj , N4TH )

figure('Temperature control');  % open fig
err = [];   % declare variable
errorInt = 0.002;

outputHP(0,pwr_obj);        % turn off
supVoltage(5,pwr_obj);  % set voltage to 5 Volts
supCurrent(iDC,pwr_obj);    % set current
outputHP(1,pwr_obj);        % turn on

measDC = getDC(N4TH,1);         % measure 5 temperatures
err(1) = (iDC - measDC)/iDC;	% calculate 5 initial errors
    
pHandle = plot(1:length(err),iDC - err*iDC,'-ob',[1 length(err)],[iDC iDC],'-r');
ylim([measDC 1.5*iDC]);

% PID constants
% u(t) = Kp*e(t) + Ki*integral({0,t},e(\tau),d\tau) + Kd*(de/dt)
dt = 2.5; cor = 10;
Kp = 1; Ki = 1; Kd = 1;

stable = 0;
while ~stable
    pause(dt)
    % measure Temperature
    measDC = getDC(N4TH);
    err(end+1) = (iDC - measDC)/iDC;
    % refresh plot
    refreshdata(pHandle,'base'); drawnow;

    intg = trapz(err)*dt;
    derr = (err(end-1) - err(end))/dt;

    u = Kp*err(end)+Ki*intg+Kd*derr;
    outDC = u*iDC; 
    
    if outDC >= limitDC && ind <= 3
        % if current is too high and its under the 3rd try
        fprintf ('Try %i\n',ind);
        fprintf('Current is too high!!! %2.2f Amps \n ',outDC);
        fprintf('Cannot reach %2.2fA. Supplying %2.2fA\n',outDC,0.9*limitDC);
        % turn off power supplier
        ind = ind+1; outDC = 0.9*limitDC;
    end
    
    supCurrent(outDC,pwr_obj);
    
    if numel(err) > cor && ~sum(abs(err(end-cor)) > errorInt/iDC)
        % if last 10 temperatures were in the interval - stop
        stable = 1;
    end
end

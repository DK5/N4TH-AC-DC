function setDCpid( iDC ,errInterval, limitDC , pwr_obj , N4TH )
tic;
figure(5);  % open fig
err = [];   % declare variable
errInterval = errInterval;

outputHP(0,pwr_obj);        % turn off
supVoltage(5,pwr_obj);  % set voltage to 5 Volts
supCurrent(iDC,pwr_obj);    % set current
outputHP(1,pwr_obj);        % turn on

measDC = getDC(N4TH,1);         % measure 5 temperatures
err(1) = (iDC - measDC)/iDC;	% calculate 5 initial errors
    
pHandle = plot(1:length(err),iDC - err*iDC,'-ob',...
    [1 length(err)],[iDC iDC],'-r',...
    [1 length(err)],(1-errInterval)*[iDC iDC],'-g',...
    [1 length(err)],(1+errInterval)*[iDC iDC],'-g');
% ylim([measDC 1.5*iDC]); hold off;


% PID constants
% u(t) = Kp*e(t) + Ki*integral({0,t},e(\tau),d\tau) + Kd*(de/dt)
dt = 0.1; cor = 10; steady = 0;
Kp = 5; Ki = 0; Kd = 0; Kt = 0.4;
steps = 10;

stable = 0;
while ~stable
    pause(dt)
    % measure Temperature
    measDC = getDC(N4TH);
    err(end+1) = (iDC - measDC)/iDC;

    intg = trapz(err)*dt;
    derr = (err(end-1) - err(end))/dt;

    u = Kt*(Kp*err(end)+Ki*intg+Kd*derr);
    outDC = (1+u)*iDC;
    outDC = outDC*(outDC>0);

    if steady || (u < 0 && abs(err(end)) < 3*errInterval)
        for ind = 1:steps
            outDC = (ind/steps)*iDC;
            pause(0.4);
        end
        steady = 1;
    elseif u < 0 && ~steady
        outDC = 0;
    elseif ~steady
        outDC = (1+u)*iDC;
    end
    
    if outDC >= limitDC
        % if current is too high and its under the 3rd try
        fprintf('Cannot reach %2.2fA. Supplying %2.2fA\n',outDC,0.9*limitDC);
        % turn off power supplier
        outDC = 0.95*limitDC;
    end
    
    plot(1:length(err),iDC - err*iDC,'-ob',...
        [1 length(err)],[iDC iDC],'-r',...
        [1 length(err)],(1-errInterval)*[iDC iDC],'-g',...
        [1 length(err)],(1+errInterval)*[iDC iDC],'-g');    ylim([0 1.5*iDC]); hold off; text(1.2,0.5*iDC,['Iout = ' num2str(outDC)]);
    
    supCurrent(outDC,pwr_obj);
    
    if numel(err) > cor && ~sum(abs(err((end-cor):end)) > errInterval)
        % if last 10 temperatures were in the interval - stop
        stable = 1;
    end
end
toc
end

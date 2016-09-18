function setTemp(spTemp,errorInt,Isrc,Rth,Plimit,volt_obj,XFR)

figure('Name','Temperature control');  % open fig
err = [];   % declare variable

for samp = 1:3
    measTemp = getTemp(volt_obj,Isrc);      % measure 5 temperatures
    err(samp) = (spTemp - measTemp)/spTemp; % calculate 5 initial errors
end

plot(1:length(err),spTemp - err*spTemp,'-ob',[1 length(err)],[spTemp spTemp],'-r');
hold off;

% PID constants
% u(t) = Kp*e(t) + Ki*integral({0,t},e(\tau),d\tau) + Kd*(de/dt)
dt = 0.2; cor = 30;
Kp = 5; Ki = 3; Kd = 3; Kt = 0.01;
Power = 20; % Plimit = 60;

stable = 0;
while ~stable
    pause(dt)
    % measure Temperature
    measTemp = getTemp(volt_obj,Isrc);
    err(end+1) = (spTemp - measTemp)/spTemp;
    plot(1:length(err),spTemp - err*spTemp,'-ob',[1 length(err)],[spTemp spTemp],'-r');
    % refresh plot
    
    intg = trapz(err)*dt;
    derr = (err(end) - err(end-1))/dt;

    u = Kt*(Kp*err(end)+Ki*intg+Kd*derr);
    outP = (1+u)*Power;
    if outP >= Plimit
        fprintf('Cannot reach %2.2fW. Supplying %2.2fW\n',outP,0.95*limitDC);
        % turn off power supplier
        outP = 0.95*Plimit;
    end
    outP = outP*(outP>0);
    xfrPower(outP, Rth , XFR );

    if numel(err) > cor && ~sum(abs(err((end-cor):end)) > errorInt/spTemp)
        % if last 10 temperatures were in the interval - stop
        stable = 1;
    end
end

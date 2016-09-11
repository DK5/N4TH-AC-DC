function setTemp1(spTemp,errorInt)

figure('Name','Power control');  % open fig
err = [];   % declare variable

for samp = 1:3
    measTemp = spTemp - 30;      % measure 5 temperatures
    err(samp) = (spTemp - measTemp)/spTemp; % calculate 5 initial errors
end
pHandle = plot(1:length(err),spTemp - err*spTemp,'-ob',[1 length(err)],[spTemp spTemp],'-r');

% PID constants
% u(t) = Kp*e(t) + Ki*integral({0,t},e(\tau),d\tau) + Kd*(de/dt)
dt = 0.5;
Kp = 0.5; Ki = 0.3; Kd = 0.3;
Power = measTemp;
 
stable = 0;
while ~stable
    pause(dt)
    % measure Temperature
    err(end+1) = (spTemp - measTemp)/spTemp;
    % refresh plot
    refreshdata(pHandle,'base'); drawnow;

    intg = trapz(err)*dt;
    derr = -(err(end-1) - err(end))/dt;

    u = Kp*err(end)+Ki*intg+Kd*derr;
%     xfrPower(u*Power, Rth , XFR );

    if numel(err) > 30 && ~sum(abs(err(end-30))> errorInt/spTemp)
        % if last 10 temperatures were in the interval - stop
        stable = 1;
    end
    measTemp = u*Power
end

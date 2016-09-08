function setTemp(spTemp,errorInt,Isrc,Rth,volt_obj,XFR,err)
dt = 0.05;
if exist('err','var') == 0
    % if not exists - first step
    figure('Temperature control');
    err = [];
    sHandle = plot(1:length(err),spTemp,'--r');
    pHandle = plot(1:length(err),spTemp - err*spTemp);
    for samp = 1:5
        measTemp = getTemp(volt_obj,Isrc);      % measure 5 temperatures
        err(samp) = (spTemp - measTemp)/spTemp; % calculate 5 initial errors
        refreshdata(pHandle,'base');refreshdata(sHandle,'base'); drawnow;   % refresh plot
        pause(dt);  % pause for a while
    end
    setTemp(spTemp,errorInt,Isrc,Rth,volt_obj,XFR,err);	% start recursion
elseif abs(err(end)*spTemp) < errorInt
    % if temperature is in the interval
    if numel(err) > 50 && sum(err(end-50)> errorInt/spTemp)
        % if last 50 temperatures were in the interval - stop
        return;
    end
end

% PID constants
% u(t) = Kp*e(t) + Ki*integral({0,t},e(\tau),d\tau) + Kd*(de/dt)
Kp = 5; Ki = 3; Kd = 3;
Power = 5;

% measure Temperature
measTemp = getTemp(volt_obj,Isrc);
err(end+1) = (spTemp - measTemp)/spTemp;

refreshdata(pHandle,'base'); drawnow;

intg = trapz(err)*dt;
derr = (err(end-1) - err(end))/dt;

u = Kp*err(end)+Ki*intg+Kd*derr;
xfrPower(u*Power, Rth , XFR );

end

function setTemp(spTemp,errorInt,Rth,volt_obj,XFR,err)
dt = 0.05;
if exists('err','var') == 0
    % if not exists - first step
    err = [];
    for samp = 1:5
        measTemp = getTemp(volt_obj);
        err(samp) = (spTemp - measTemp)/spTemp; 
        pause(dt);
    end
    setTemp(spTemp,volt_obj,err);
elseif err(end) < errorInt
    return;
end

% PID constants
% u(t) = Kp*e(t) + Ki*integral({0,t},e(\tau),d\tau) + Kd*(de/dt)
Kp = 1; Ki = 1; Kd = 1;
Power = 15;

% measure Temperature
measTemp = getTemp(volt_obj);
err(end+1) = (spTemp - measTemp)/spTemp;

intg = trapz(err)*dt;
derr = (err(end-1) - err(end))/dt;

u = Kp*err(end)+Ki*intg+Kd*derr;
xfrPower(u*Power, Rth , XFR );

end

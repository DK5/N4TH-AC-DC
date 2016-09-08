function setTemp(spTemp,errorInt,Isrc,Rth,volt_obj,XFR,err,const)
dt = 0.05;
if exist('const','var'); end
if exist('err','var') == 0
    % if not exists - first step
    err = []; const = 0;
    for samp = 1:5
        measTemp = getTemp(volt_obj,Isrc);
        err(samp) = (spTemp - measTemp)/spTemp; 
        pause(dt);
    end
    setTemp(spTemp,errorInt,Isrc,Rth,volt_obj,XFR,err);
elseif err(end)*spTemp < errorInt
    const = const+1;
    if const > 50
        return;
    end
end

% PID constants
% u(t) = Kp*e(t) + Ki*integral({0,t},e(\tau),d\tau) + Kd*(de/dt)
Kp = 1; Ki = 1; Kd = 1;
Power = 5;

% measure Temperature
measTemp = getTemp(volt_obj,Isrc);
err(end+1) = (spTemp - measTemp)/spTemp;

intg = trapz(err)*dt;
derr = (err(end-1) - err(end))/dt;

u = Kp*err(end)+Ki*intg+Kd*derr;
xfrPower(u*Power, Rth , XFR );

end

function setTemp(spTemp,errorInt,Isrc,Rth,volt_obj,XFR)

figure('Name','Temperature control');  % open fig
err = [];   % declare variable

for samp = 1:3
    measTemp = getTemp(volt_obj,Isrc);      % measure 5 temperatures
    err(samp) = (spTemp - measTemp)/spTemp; % calculate 5 initial errors
end

pHandle = plot(1:length(err),spTemp - err*spTemp,'-ob',[1 length(err)],[spTemp spTemp],'-r');
% linkdata on;
hold off;

% PID constants
% u(t) = Kp*e(t) + Ki*integral({0,t},e(\tau),d\tau) + Kd*(de/dt)
dt = 0.2; cor = 30;
Kp = 10; Ki = 10; Kd = 10;
Power = 20;

stable = 0; j = 3;
while ~stable
    j=j+1
    pause(dt)
    % measure Temperature
    measTemp = getTemp(volt_obj,Isrc);
    err(end+1) = (spTemp - measTemp)/spTemp;
    plot(1:length(err),spTemp - err*spTemp,'-ob',[1 length(err)],[spTemp spTemp],'-r');
    % refresh plot
%     refreshdata(pHandle,'caller'); drawnow;
    
    intg = trapz(err)*dt;
    derr = (err(end) - err(end-1))/dt;

    u = Kp*err(end)+Ki*intg+Kd*derr
    xfrPower((1+u)*Power, Rth , XFR );

    if numel(err) > cor && ~sum(abs(err(end-cor)) > errorInt/spTemp)
        % if last 10 temperatures were in the interval - stop
        num2str(spTemp - spTemp*err(end-cor))
        stable = 1;
    end
end

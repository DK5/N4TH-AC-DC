Isrc = 1e-5; dt = 0.5;
volt_obj = GPconnect(8);
figure('Name','Temperature status');  % open fig
measTemp(1) = getTemp(volt_obj,Isrc);
plot(1:length(measTemp),measTemp,'-ob'); hold off;

stable = 0;
while ~stable
    pause(dt)
    % measure Temperature
    measTemp(end+1) = getTemp(volt_obj,Isrc);
    % refresh plot
    plot(1:length(measTemp),measTemp,'-ob'); hold off;
end
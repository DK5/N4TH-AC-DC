%% Loss calculation
function [Loss] = LossPCcalc(waves)
% loss per cycle
current = waves.iAC;
freq = waves.frequency; %round(2.^(5:.25:14.25));
Loss = zeros(length(current),length(freq));
for c = 1:length(current) % amplitude scan current vs freq ?
    amplitude = ['AC' num2str(100*(round(10*current(c)))) 'mA'];
    for f = 1:length(freq)
        freqStr = ['F' num2str(freq(f)) 'Hz'];
        Loss(c,f) = abs(waves.(amplitude).(freqStr).average(1,3))/freq(f);
%         fprintf ('Current %0.1fA | Frequency %iHz\n',current(c),freq(f));
    end
end
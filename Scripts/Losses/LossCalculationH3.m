function [Loss] = LossCalculationH3(waves)
% calculate loss
current = waves.iAC;
freq = waves.frequency; %round(2.^(5:.25:14.25));
Loss = zeros(lentgh(current),lentgh(freq));
for c = 1:lentgh(current) % amplitude scan current vs freq ?
    amplitude = ['AC' num2str(100*(round(10*current(c)))) 'mA'];
    for f = 1:lentgh(freq)
        freq = ['F' num2str(freq(f)) 'Hz'];
        Loss(c,f) = abs(waves.(amplitude).(freq).average(1,19));
%         fprintf ('Current %0.1fA | Frequency %iHz\n',current(c),freq(f));
    end
end
%% Loss calculation
function [Loss] = LossCalculation(waves)
k=1;
for  current=sort(waves.iAC) % amplitude scan current vs freq ?
     i=1;    
    for f =waves.frequency %round(2.^(5:.25:14.25));
        freq=['F' num2str(f) 'Hz'];
        amplitude=['AC' num2str(100*(round(10*current))) 'mA'];
        Loss(k,i)=abs(waves.(amplitude).(freq).average(1,3));
        i=i+1;
%         fprintf ('Current %0.1fA | Frequency %iHz\n',current,f);
    end
    k=k+1;
end
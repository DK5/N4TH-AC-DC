% Main loop
output(0,pwr_obj);      % turn off power supply
supVoltage(5,pwr_obj);  % supply 5V (DC)

for iDC = DClist
    setDC(iDC,pwr_obj,N4TH);
    for f = frequency
        HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B') % turn off function generator
        
        for iAC = AClist
            % av = amplification
            setAC(iAC,f,fg,N4TH);
            [I,tempdata,amp] = N4TH_1P(iAC,f,av,round(averaging),N4TH,fg);
            freq=['F' num2str(f) 'Hz'];
            amplitude=['amp' num2str(100*(round(10*I))) 'mA'];
            data.(amplitude).(freq)=tempdata.(amplitude).(freq);
            fprintf ('current %0.1fA | Frequency %iHz | Amplitude %0.0fmV | Power %0.3fuW\n',iAC,f,1000*amp,1E6*data.(amplitude).(freq).average(1,3))
            if abs(I-iAC)>0.1;
                fprintf ('Warning! current is %i instead of %i\n',I,iAC); 
            end
%             pause (iAC*(3+f^2/2.5E7));
            pause (1+iAC*f/10000);
        end
        
    end
    
    data.iAC = sort(AClist);
    data.frequency = sort(frequency);
    
    HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B');	% turn off function generator 
    output(0,pwr_obj);  % turn off power supply
    
    ttime = toc;
    clc;
    
    fprintf ('Total elapsed time %0.1f minutes \n',ttime/60)
    
    data.loss = LossCalculation(data);
    data.lossH3 = LossCalculationH3(data);
    for i = 1:numel(data.frequency)
        data.lossPVPC(:,i) = data.loss(:,i)./(data.frequency(i)*volume);
    end
    data.runtitle = runtitle;
    save(runtitle,'data');
    %Plot and figure save
    h = lossplot(data);
    saveas(h,[pwd '\Figures\' runtitle],'fig')
end
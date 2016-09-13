% Main loop
outputHP(0,pwr_obj);      % turn off power supply
supVoltage(5,pwr_obj);  % supply 5V (DC)
Ilimit = 15;

for iDC = DClist
    HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B') % turn off function generator
    dcI = setDC(iDC,Ilimit,pwr_obj,N4TH);	% set DC current
    DCstr = ['DC',num2str(round(dcI)),'A'];
    for f = frequency
        HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B') % turn off function generator
        freq = ['F',num2str(f),'Hz'];   % field title
        for iAC = AClist
            [outAC,amp] = setAC(iAC,f,fg,N4TH);   % set AC current
            tempdata = N4TH_1P(outAC,f,av,round(averaging),N4TH);  % measure 1 point
            amplitude = ['AC',num2str(100*(round(10*outAC))),'mA'];    % field title
            data.(DCstr).(amplitude).(freq) = tempdata.(amplitude).(freq);
            fprintf ('current %0.1fA | Frequency %iHz | Amplitude %0.0fmV | Power %0.3fuW\n',iAC,f,1000*amp,1E6*data.(DCstr).(amplitude).(freq).average(1,3))
            if abs(outAC-iAC)>0.1;
                fprintf ('Warning! current is %i instead of %i\n',outAC,iAC); 
            end
            HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B') % turn off function generator

%             pause (iAC*(3+f^2/2.5E7));
            pause (1+iAC*f/10000);
        end
        outDC = getDC(N4TH);    % check DC current again
        if (outDC/iDC - 1) < 0.02
            setDC(iDC,Ilimit,pwr_obj,N4TH);    % set DC current
        end
    end
    
    data.(DCstr).iAC = sort(AClist);
    data.(DCstr).frequency = sort(frequency);
    
    HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B');	% turn off function generator     
    ttime = toc;
    clc;
    
    fprintf ('Total elapsed time %0.1f minutes \n',ttime/60)
    
    data.(DCstr).loss = LossCalculation(data.(DCstr));
    data.(DCstr).lossH3 = LossCalculationH3(data.(DCstr)); 
    for i = 1:numel(data.(DCstr).frequency)
        data.(DCstr).lossPVPC(:,i) = data.(DCstr).loss(:,i)./(data.(DCstr).frequency(i)*volume);
    end
    data.(DCstr).runtitle = runtitle;
    save(runtitle,'data');
    %Plot and figure save
    h = lossplot(data.(DCstr));
    saveas(h,[pwd '\Figures\' runtitle],'fig')
end

outputHP(0,pwr_obj);    % turn off DC supply
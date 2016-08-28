function [I,waves,amp] = measurepointN4th(current,f,av,averaging,N4th,fg)
[amp,I] = CalibratorN4th(f,current, fg, N4th);%disp('Xyu');
freq=['F' num2str(f) 'Hz'];
amplitude=['amp' num2str(100*(round(10*I))) 'mA'];
for i=1:averaging
    reading=[];
    fprintf(N4th,  'FAST,ON');
    pause(1.5);
    while isempty(reading)
        
        pause(.5);
        reading=query(N4th,  'LCR?');
        %         fprintf(N4th,  'FAST,OFF');
    end
    LCR = textscan(reading, '%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
    LCR=LCR{:}; LCR=str2double(LCR);
    reading=[];
    while isempty(reading)
        %         fprintf(N4th,  'FAST,ON');
        pause(.5);
        reading=query(N4th,  'POWER?');
        
    end
    fprintf(N4th,  'FAST,OFF');
    data = textscan(reading, '%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
    data=data{:}; data=str2double(data);
    Freq(i)=data(1);
    VA(i)=data(4);
    VAR(i)=data(6);
    ASR(i)=LCR(6);
    RSR(i)=LCR(11);
    IMP(i)=LCR(4);
    Irms(i)=data(21);
    Iac(i)=data(22);
    Idc(i)=data(23);
    P(i)=data(2);
    PHI(i)=data(15);
    Vrms(i)=data(12);
    Vac(i)=data(13);
    Vdc(i)=data(14);
    Vcf(i)=data(17);
    P_f(i)=data(3);     % power at fundamental f
    VA_f(i)=data(5);	% power at fundamental f
    P_dc(i)=data(10);	% DC power
    P_h(i)=data(11);	% power at specific harmonic (default 3)
end
waves.(amplitude).(freq).average(1,1)=mean(Irms); %     1 TRMS Current
waves.(amplitude).(freq).average(1,2)=mean(Freq); %     2 Frequency 
waves.(amplitude).(freq).average(1,3)=abs(mean(P)/av); %3 Active power P [W]
waves.(amplitude).(freq).average(1,4)=mean(VA)/av; %    4 Apparent power S [VA]
waves.(amplitude).(freq).average(1,5)=mean(PHI); %      5 Angle PHI
waves.(amplitude).(freq).average(1,6)=mean(VAR); %      6 Reactive Q [var]
waves.(amplitude).(freq).average(1,7)=mean(ASR)/av; %   7 Active serial resistance
waves.(amplitude).(freq).average(1,8)=mean(RSR)/av; %   8 Reactive serial resistance (reactance)
waves.(amplitude).(freq).average(1,9)=mean(IMP)/av; %   9 Impedance
waves.(amplitude).(freq).average(1,10)=mean(Vac)/av; %  10 AC Voltage
waves.(amplitude).(freq).average(1,11)=mean(Vdc)/av; %  11 DC Voltage
waves.(amplitude).(freq).average(1,12)=mean(Vrms)/av; % 12 TRMS Voltage
waves.(amplitude).(freq).average(1,13)=mean(Vcf); % Voltage Crest Factor
waves.(amplitude).(freq).average(1,14)=mean(Iac);  %AC current component fundamental
waves.(amplitude).(freq).average(1,15)=mean(Idc);  %DC current component
waves.(amplitude).(freq).average(1,16)=mean(P_f);  %Power at fundamental f [W]
waves.(amplitude).(freq).average(1,17)=mean(VA_f);  %Apparent power at fundamental f
waves.(amplitude).(freq).average(1,18)=mean(P_dc);  %DC power
waves.(amplitude).(freq).average(1,19)=mean(P_h);  %power at specific harmonic (default 3)
HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B') % Zero HP
end


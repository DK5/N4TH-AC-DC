function [waves] = N4TH_1P(f,av,averaging,N4TH,fg)
% N4TH_1P(current,f,av,averaging,N4th,fg) measures one-point from N4TH
% device
%   f       - frequency
%   av      - voltage amplification
%   N4th    - N4TH object
%   fg      - function generator object

freq = ['F' num2str(f) 'Hz'];
amplitude = ['amp' num2str(100*(round(10*I))) 'mA'];

for ind = 1:averaging
    % do avaraging over multiple measurements
    reading = [];
    fprintf(N4TH,'FAST,ON');
    pause(1.5);
    while isempty(reading)
        pause(.5);
        reading=query(N4TH,  'LCR?');
    end
    LCR = textscan(reading, '%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
    LCR = LCR{:}; LCR = str2double(LCR);
    
    reading=[];
    while isempty(reading)
        pause(.5);
        reading = query(N4TH,  'POWER?');    
    end
    fprintf(N4TH,  'FAST,OFF');
    data = textscan(reading, '%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
    data = data{:}; data = str2double(data);
    
    Freq(ind)=data(1);
    VA(ind)=data(4);
    VAR(ind)=data(6);
    ASR(ind)=LCR(6);
    RSR(ind)=LCR(11);
    IMP(ind)=LCR(4);
    Irms(ind)=data(21);
    Iac(ind)=data(22);
    Idc(ind)=data(23);
    P(ind)=data(2);
    PHI(ind)=data(15);
    Vrms(ind)=data(12);
    Vac(ind)=data(13);
    Vdc(ind)=data(14);
    Vcf(ind)=data(17);
    P_f(ind)=data(3);	% power at fundamental f
    VA_f(ind)=data(5);	% power at fundamental f
    P_dc(ind)=data(10); % DC power
    P_h(ind)=data(11);  % power at specific harmonic (default 3)
end

waves.(amplitude).(freq).average(1,1)=mean(Irms);	% 1 TRMS Current
waves.(amplitude).(freq).average(1,2)=mean(Freq);	% 2 Frequency
waves.(amplitude).(freq).average(1,3)=abs(mean(P)/av); % 3 Active power P [W]
waves.(amplitude).(freq).average(1,4)=mean(VA)/av;	% 4 Apparent power S [VA]
waves.(amplitude).(freq).average(1,5)=mean(PHI);	% 5 Angle PHI
waves.(amplitude).(freq).average(1,6)=mean(VAR);	% 6 Reactive Q [var]
waves.(amplitude).(freq).average(1,7)=mean(ASR)/av; % 7 Active serial resistance
waves.(amplitude).(freq).average(1,8)=mean(RSR)/av; % 8 Reactive serial resistance (reactance)
waves.(amplitude).(freq).average(1,9)=mean(IMP)/av; % 9 Impedance
waves.(amplitude).(freq).average(1,10)=mean(Vac)/av;	% 10 AC Voltage
waves.(amplitude).(freq).average(1,11)=mean(Vdc)/av;	% 11 DC Voltage
waves.(amplitude).(freq).average(1,12)=mean(Vrms)/av;	% 12 TRMS Voltage
waves.(amplitude).(freq).average(1,13)=mean(Vcf);	% Voltage Crest Factor
waves.(amplitude).(freq).average(1,14)=mean(Iac);	% AC current component fundamental
waves.(amplitude).(freq).average(1,15)=mean(Idc);	% DC current component
waves.(amplitude).(freq).average(1,16)=mean(P_f);	% Power at fundamental f [W]
waves.(amplitude).(freq).average(1,17)=mean(VA_f);	% Apparent power at fundamental f
waves.(amplitude).(freq).average(1,18)=mean(P_dc);  % DC power
waves.(amplitude).(freq).average(1,19)=mean(P_h);   % power at specific harmonic (default 3)

HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B');	% Zero HP

end
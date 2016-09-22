scaleWindow(N4TH);
reading = [];
%     fprintf(N4TH,'FAST,ON');
pause(.5);
reading=[];
while isempty(reading)
    pause(.5);
%     reading = query(N4TH,'POWER?');
    reading = query(N4TH,'DISPLAY?');
end
%     fprintf(N4TH,'FAST,OFF');
data = textscan(reading,'%s','Delimiter',',','CommentStyle','\','headerlines',0);
data = data{:}; data = str2double(data);

while isempty(reading)
    pause(.5);
    reading=query(N4TH,'LCR?');
end
LCR = textscan(reading,'%s','Delimiter',',','CommentStyle','\','headerlines',0);
LCR = LCR{:}; LCR = str2double(LCR);

reading = query(N4TH,'STREAM?');

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
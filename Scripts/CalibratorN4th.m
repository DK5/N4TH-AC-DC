function [amp,Current] = CalibratorN4th(f, I, fg ,N4th)

amp=0.01+I*(sqrt(f)/20000);%*sqrt(f);
HP8904A( fg,amp, f, 'sine', 2, 'on', 'B');

if f*5 <= 1000 
    noise=1000;
elseif f*5 >=22000
    noise=22000;
else
    noise=f*5;
end
% fprintf(N4th,  'FAST,ON');

fprintf(N4th,  ['NOISEF,PHASE1,ON,' num2str(noise) ]);
% fprintf(N4th,  'REZERO');
reading=[];
 fprintf(N4th,  'FAST,ON');
pause(1);
 while isempty(reading)
   
    pause(0.4);
    reading=query(N4th,  'VRMS,RMS?');
   
end
 fprintf(N4th,  'FAST,OFF');
vrms = textscan(reading, '%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
vrms=vrms{:};
vrms=str2double(vrms);
Current=vrms(6);
i=1;
while abs(Current/I -1 )>0.002
    amp=amp*(I/Current);
    if amp>=1.8&&i<=3;
        fprintf ('Try %i\n',i);
        fprintf(' Amplitude is too high!!! %2.2f volt \n ',amp);
        fprintf ('Cannot reach %2.2fA. Actual current is %2.2fA\n',I,Current);
        
        amp=0;HP8904A( fg,amp, f, 'sine', 2, 'on', 'B');pause (1);i=i+1;amp=0.01*i;
    elseif amp>=1.8&&i>3;  fprintf ('Couldn''t make it :( \n');
        amp=0;HP8904A( fg,amp, f, 'sine', 2, 'on', 'B');break;
    end
    
    HP8904A( fg,amp, f, 'sine', 2, 'on', 'B')
    clear data; clear reading;  
    reading=[];
    while isempty(reading)
        fprintf(N4th,  'FAST,ON');
        pause (.5)
        reading=query(N4th,  'VRMS,RMS?');
        fprintf(N4th,  'FAST,OFF');
    end
    vrms = textscan(reading, '%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
    vrms=vrms{:};
    vrms=str2double(vrms);
    Current=vrms(6);
end
end


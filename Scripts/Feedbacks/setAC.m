function [ outAC , amp ] = setAC( iAC  , f , fg , N4TH )
%setAC(iAC,f,fg,N4TH) executes feedback loop on AC current
%   iAC - desired AC current
%   f   - frequency
%   fg  - function generator object
%   N4TH- N4TH object

amp = 0.01 + iAC*(sqrt(f)/20000); %*sqrt(f);
% set function generator properties:
% channel B, sine wave, calculated amplitude, output port 2
HP8904A(fg, amp, f, 'sine', 2, 'on', 'B');

% noise calculation - low pass filter
if f*5 <= 1000 
    noise=1000;
elseif f*5 >= 22000
    noise=22000;
else
    noise=f*5;
end
fprintf(N4TH,['NOISEF,PHASE1,ON,' num2str(noise)]); % set low pass filter
fprintf(N4TH,'SPEED,WINDOW,0.5');
pause(0.6);

% read AC current
fprintf(N4TH,'COUPLI,PHASE1,ACONLY'); % set AC coupling
fprintf(N4TH,'FAST,ON');	% fast communication mode - on
pause(1);
outAC = getAC(N4TH);

ind = 1;    
% feedback loop
while abs(outAC/iAC - 1) > 0.004
    amp = amp*(iAC/outAC);  % fixing voltage amplitude
    if amp >= 1.8 && ind <= 3
        % if amplitude is too high and its under the 3rd try
        fprintf ('Try %i\n',ind);
        fprintf('Amplitude is too high!!! %2.2f volt \n ',amp);
        fprintf('Cannot reach %2.2fA. Actual current is %2.2fA\n',iAC,outAC);
        % turn off function generator
        amp = 0; HP8904A( fg,amp, f, 'sine', 2, 'on', 'B'); pause (1);
        ind = ind+1; amp = 0.01*ind;
        
    elseif amp >= 1.8 && ind > 3;
        % if amplitude is too high and its over the 3rd try
        fprintf ('Couldn''t make it :( \n');
        % turn off function generator and break
        amp = 0; HP8904A(fg,amp,f,'sine',2,'on','B'); break;
    end
    
    HP8904A(fg,amp,f,'sine',2,'on','B');
    outAC = getAC(N4TH);  % get AC current
end

fprintf(N4TH,'FAST,OFF');   % fast communication mode - off
end

function outAC = getAC(N4TH)
    % read AC current
    reading = [];   % prepare empty readings
    while isempty(reading)
        pause(.5);
        reading = query(N4TH,'VRMS,RMS?');  % read
    end
    vrms = textscan(reading,'%s','Delimiter', ',',...
                    'CommentStyle','\','headerlines',0);
    vrms = vrms{:};
    vrms = str2double(vrms);
    outAC = vrms(6);
end
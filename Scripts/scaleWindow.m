function scaleWindow(N4TH)
% scaleWindow( loss, N4TH) scales the measurement time window according to
% the measured loss value
%   N4TH - N4TH object

fprintf(N4TH,'SPEED,WINDOW,1');
% fprintf(N4TH,'SMOOTH,SLOW');
pause(2);

reading=[];
while isempty(reading)
    
    reading = query(N4TH,'POWER?'); 
    pause(.5); reading=[];
    reading = query(N4TH,'POWER?');
end

data = textscan(reading,'%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
data = data{:}; data = str2double(data);
loss = data(2);

scale = [100e-9,1000e-9]; % Watt
windowStr = ['3','2','1'];    % window scale - seconds

logic = loss < scale;	% find scale
[~,ind] = find(logic,1,'first');	% proper scale index is the first bigger

if isempty(ind)
    ind = length(windowStr);
end

windowStr(ind);
fprintf(N4TH,['SPEED,WINDOW,' windowStr(ind)]);

end
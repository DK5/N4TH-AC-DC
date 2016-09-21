function scaleWindow( loss, N4TH)
% scaleWindow( loss, N4TH) scales the measurement time window according to
% the measured loss value
%   N4TH - N4TH object

fprintf(N4TH,'FAST,ON');
reading = query(N4TH,'POWER?');
fprintf(N4TH,'FAST,OFF');
data = textscan(reading, '%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
data = data{:}; data = str2double(data);
loss = data(4);

scale = [50e-9,200e-9,1e-6]; % Watt
windowStr = ['5','3','1','0.5'];    % window scale - seconds

logic = loss < scale;	% find scale
[~,ind] = find(logic,1,'first');	% proper scale index is the first bigger

if isempty(ind)
    ind = length(windowStr);
end

fprintf(N4TH,['SPEED,WINDOW' windowStr(ind)]);

end
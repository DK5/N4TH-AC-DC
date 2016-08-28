function outDC = getDC(N4TH)
    % read DC current
    reading = [];   % prepare empty readings
    while isempty(reading)
        pause(.5);
        reading = query(N4TH,'VRMS,RMS?');  % read
    end
    vrms = textscan(reading,'%s','Delimiter', ',',...
                    'CommentStyle','\','headerlines',0);
    vrms = vrms{:};
    vrms = str2double(vrms);
    outDC = vrms(4);
end
function outDC = getDC(N4TH)
    % read DC current
    fprintf(N4TH,'COUPLI,PHASE1,DCONLY'); % set DC coupling
%     fprintf(N4TH,'FAST,ON');	% fast communication mode - on
    reading = [];   % prepare empty readings
    while isempty(reading)
        pause(.5);
        reading = query(N4TH,'VRMS,RMS?');  % read
    end
%     fprintf(N4TH,'FAST,OFF');	% fast communication mode - off
    vrms = textscan(reading,'%s','Delimiter', ',',...
                    'CommentStyle','\','headerlines',0);
    vrms = vrms{:};
    vrms = str2double(vrms);
    outDC = vrms(4);
end
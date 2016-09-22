function outDC = getDC(N4TH,prep)
    % read DC current
if exist('prep','var') && prep
        fprintf(N4TH,'COUPLI,PHASE1,DCONLY'); % set DC coupling
        fprintf(N4TH,'SPEED,WINDOW,0.2');
        pause(0.25);

end
%     fprintf(N4TH,'COUPLI,PHASE1,DCONLY'); % set DC coupling
%     fprintf(N4TH,'FAST,ON');	% fast communication mode - on
    reading = [];   % prepare empty readings
    while isempty(reading)
        pause(.3);
        reading = query(N4TH,'VRMS,RMS?');  % read
    end
%     fprintf(N4TH,'FAST,OFF');	% fast communication mode - off
    vrms = textscan(reading,'%s','Delimiter', ',',...
                    'CommentStyle','\','headerlines',0);
    vrms = vrms{:};
    vrms = str2double(vrms);
    outDC = vrms(4);
end
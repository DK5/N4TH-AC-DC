function setFreq( obj, freq, channel)
%freq writes frequency to the function generator
%   obj is the function generator object
%   freq is the desired frequency
%   channel is the channel name = 'A'|'B'

scale = [1,1e3];
logic = freq<scale;     % find scale
[~,ind] = max(logic);   % proper scale index is the first bigger

freq = freq/scale(ind); %scaling

term = {'HZ','KZ'};

try
    fprintf(obj, 'gm0');  % go to channel config
    fprintf(obj, '>');  % next display
    if channel == 'b' || channel == 'B'
        fprintf(obj, '>');  % next display
    end
    fprintf(obj, ['FR',channel,num2str(freq),term{ind}]);  % set frequency  to freq
catch
    error('Error setting frequency');
end
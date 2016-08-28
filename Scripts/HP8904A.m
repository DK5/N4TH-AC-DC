function HP8904A( obj, ampl, freq, form, out, state, channel)  
% HP8904A( obj, ampl, freq, form, out, state, channel) sets the function
% generator properties
%   obj - 8904A multifunction GPIB object
%   ampl is the desired amplitude
%   freq is the desired frequency
%   form is the desired waveform =
%        'sine'|'ramp'|'triangle'|'square'|'noise'|'dc'
%   out - output port: 1|2
%   state - output state: 'on'|'off'
%   channel is the channel name = 'A'|'B'

cmd = ['OO',num2str(out),state(1:2)];
try
    fprintf(obj, cmd);  % next display
catch
    error('Error setting frequency');
end

ampscale = [1e-6 , 1e-3 ,1];
logic = ampl<ampscale;     % find scale
[val,ampind] = max(logic);   % proper scale index is the first 1

if val == 0
    ampind = 3;
end

ampl = ampl/ampscale(ampind); %scaling
ampterm = {'UV','MV','VL'};
logic=[];

switch lower(form)
    case 'sine'
        formterm = 'SI';
    case 'ramp'
        formterm = 'RA';
    case 'triangle'
        formterm = 'TR';
    case 'square'
        formterm = SQ;
    case 'noise'
        formterm = 'NS';
    case 'dc'
        formterm = 'DC';
    otherwise
        error('Wrong waveform input');
end

freqscale = [1,1e3];
logic = freq<freqscale;     % find freqscale
[~,freqind] = max(logic);   % proper scale index is the first bigger
freq = freq/freqscale(freqind); %scaling
freqterm = {'HZ','KZ'};

try
    fprintf(obj, ['AP',channel,num2str(ampl),ampterm{ampind}]);  % set amplitude to ampl
    fprintf(obj, ['FR',channel,num2str(freq),freqterm{freqind}]);  % set frequency  to freq
    fprintf(obj, ['WF',channel,formterm]);  % set waveform
catch
    error('Error setting parameters');
end
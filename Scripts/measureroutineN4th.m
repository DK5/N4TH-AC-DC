cd ('C:\Users\Measurements PC\Dropbox\HTS Lab\Measurment PC\MATLAB')
path(path,'C:\Users\Measurements PC\Dropbox\HTS Lab\Measurment PC\MATLAB\Figures')
path(path,'C:\Users\Measurements PC\Dropbox\HTS Lab\Measurment PC\MATLAB\GPIB')
path(path,'C:\Users\Measurements PC\Dropbox\HTS Lab\Measurment PC\MATLAB\PicoScope')
path(path,'C:\Users\Measurements PC\Dropbox\HTS Lab\Measurment PC\MATLAB\ZES')
path(path,'C:\Users\Measurements PC\Dropbox\HTS Lab\Measurment PC\MATLAB\GPIB\8940A multifunction')
fg = GPconnect(10); % connect to function generator

N4th = instrfind('Type', 'serial', 'Port', 'COM3', 'Tag', '');
N4th = serial('COM3');

fopen(N4th);
%     set(N4th,'BaudRate',28800)
set(N4th,'Timeout',10);
%     fclose(N4th);

%%  This section to run !!!!!
volume=0.05*(0.0013/2)^2*pi; % Ask about sample volume (GUI)
question={'Wire type:','Wire shape:','Wire dimensions:','Vtap distance',...
    'Temperature','Version','Averaging (lower is faster)', 'Amplification'};
if exist('run','var')
    defaultanswer=run;
else
    defaultanswer={'Ni-MgB2 ',' round',' 1_3mm ',' Vtap 50mm',' 10K ',' v1','1', '1'};
end

choice=menu ('Change parameters?','Yes','No');
if choice==1
    run=inputdlg(question,'Input',1,defaultanswer);
    runtitle = cell2mat(strcat(run(1),run(2),run(3),run(4),run(5),run(6)));
end

frequency = sort([57 117:100:517 617:200:1017 1517:500:3017 4017:1000:18017]);
cur=sort([8 6 5 4 1 0.5 2 3 10]);
initQ={'Please enter scanning frequencies:','Please enter AC current values (RMS):'};
initA={num2str(frequency),num2str((cur))};
options.Resize='on';
options.WindowStyle='normal';
init=inputdlg(initQ,'Measurement parameters',6,initA,options);
% msg=msgbox('Don''t forget to charge capacitors and disconnect them from power supply','Reminder', 'warn');
% waitfor(msg);
choice=menu ('Start measurement?','Yes','Cancel');
frequency=str2num(cell2mat(init(1)));
cur=str2num(cell2mat(init(2)));

if choice==1
    av=str2num(cell2mat(run(8)));
    averaging=str2num(cell2mat(run(7)));
    clear data;
    data.title=run;
    data.list={'TRMS Current' 'Frequency' ...
        'Active power P [W]' 'Apparent power S [VA]'...
        'Angle PHI' 'Reactive Q [var]'...
        'Active serial resistance Rser'...
        'Reactive serial resistance Xser' 'Impedance'...
        'AC Voltage' 'DC voltage' 'TRMS Voltage'...
        'Voltage Crest Factor' 'AC current' 'DC current'};
    
    %% Main loop
    tic
    for   f =frequency
        %     chargewrn = warndlg('Charge capacitor bank!', 'A Warning Dialog');
        %     waitfor(chargewrn);
        %     amp=0.075;
        HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B')
        
        for   current=cur
            %         tic
            [I,tempdata,amp]=measurepointN4th(current,f,av,round(averaging),N4th,fg);
            % [I,tempdata,amp]=measurepointN4th(current,f,av,round(averaging*(1+0.5/current+114/f)),N4th,fg);
            %         HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B')
            freq=['F' num2str(f) 'Hz'];
            amplitude=['amp' num2str(100*(round(10*I))) 'mA'];
            data.(amplitude).(freq)=tempdata.(amplitude).(freq);
            fprintf ('Current %0.1fA | Frequency %iHz | Amplitude %0.0fmV | Power %0.3fuW\n',current,f,1000*amp,1E6*data.(amplitude).(freq).average(1,3))
            if abs(I-cur)>0.1;
                fprintf ('Warning! Current is %i instead of %i\n',I,current); 
            end
%             pause (current*(3+f^2/2.5E7));
            pause (1+current*f/10000);
        end
    end
    data.current = sort(cur);
    data.frequency = sort(frequency);
    HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B')
    ttime = toc;
    clc;
    fprintf ('Total elapsed time %0.1f minutes \n',ttime/60)
    
    
    
    
    data.loss=LossCalculation(data);
    data.lossH3=LossCalculationH3(data);
    for i=1:numel(data.frequency)
        data.lossPVPC(:,i)=data.loss(:,i)./(data.frequency(i)*volume);
    end
    runtitle = cell2mat(strcat(data.title(1),data.title(2),data.title(3),data.title(4),data.title(5),data.title(6)));
    data.runtitle=runtitle;
    save (runtitle,'data')% --------------------------------------------------
    %Plot and figure save
    h=lossplot(data);
    %%%
    saveas(h,[pwd '\Figures\' runtitle],'fig')
    
else
    clc; display('Canceled');
end

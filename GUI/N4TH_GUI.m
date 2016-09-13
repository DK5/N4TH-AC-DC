function varargout = N4TH_GUI(varargin)
% N4TH_GUI MATLAB code for N4TH_GUI.fig
%      N4TH_GUI, by itself, creates a new N4TH_GUI or raises the existing
%      singleton*.
%
%      H = N4TH_GUI returns the handle to a new N4TH_GUI or the handle to
%      the existing singleton*.
%
%      N4TH_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in N4TH_GUI.M with the given input arguments.
%
%      N4TH_GUI('Property','Value',...) creates a new N4TH_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before N4TH_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to N4TH_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help N4TH_GUI

% Last Modified by GUIDE v2.5 08-Sep-2016 09:53:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @N4TH_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @N4TH_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before N4TH_GUI is made visible.
function N4TH_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to N4TH_GUI (see VARARGIN)

% Choose default command line output for N4TH_GUI
handles.output = hObject;

% default answers
defaultanswer = {'Ni-MgB2 ','round','1_3mm','Vtap 50mm','v1','1','1','100','20','0.05*(0.0013/2)^2*pi'};
setappdata(0,'defAns',defaultanswer);

tempStr = '15K'; run = defaultanswer;
run{end} = eval(run{end}); % calculate volume
run = [run(1:4)';{tempStr};run(5:end)'];
runTitle = strjoin(run(1:6)');
setappdata(0,'runTitle',runTitle);
runStr = {runTitle;'DC = 0A  |  AC = 0A  | f = 0Hz'};
set(handles.txtRunTitle,'string',runStr);

Isrc = str2double(defaultanswer{8});
setappdata(0,'Isrc',Isrc);
setappdata(0,'maxTemp',50);

% connect to objects
devlist = {'Couldn''t connect to the following devices:'}; ind = 2;
try     % N4TH
    N4TH = instrfind('Type', 'serial', 'Port', 'COM3', 'Tag', '');
    % Create the serial port object if it does not exist
    % otherwise use the object that was found.
    if isempty(N4TH)
        N4TH = serial('COM3');
    else
        fclose(N4TH);
        N4TH = N4TH(1);
    end
    % Disconnect from instrument object, obj1.
    fclose(N4TH);
    % Connect to instrument object, obj1.
    fopen(N4TH);
    set(N4TH,'Timeout',15);
    setappdata(0,'N4TH',N4TH);
catch
%     errordlg('Couldn''t connect to the power supplier','Connection Error');
    devlist{ind,1} = '    - N4TH'; ind = ind + 1;
end

try     % function generator
    fg = GPconnect(10);    
    setappdata(0,'fg',fg);
catch
%     errordlg('Couldn''t connect to the function generator','Connection Error');
    devlist{ind,1} = '    - Function Generator'; ind = ind + 1;
end

try     % power supplier
    pwr_obj = GPconnect(5);
    setappdata(0,'pwr_obj',pwr_obj);
catch
%     errordlg('Couldn''t connect to the power supplier','Connection Error');
    devlist{ind,1} = '    - Power Supplier'; ind = ind + 1;
end

try     % voltmeter
    volt_obj = GPconnect(8);     % check the address
    prepVolt(volt_obj);
    setappdata(0,'volt_obj',volt_obj);
catch
%     errordlg('Couldn''t connect to the voltmeter','Connection Error');
    devlist{ind,1} = '    - Voltmeter'; ind = ind + 1;
end

try     % YOKOGAWA
    yoko_obj = GPconnect(23);     % check the address
    setYokoCurrent(Isrc,yoko_obj);
    setappdata(0,'yoko_obj',yoko_obj);
catch
%     errordlg('Couldn''t connect to the Yokogawa','Connection Error');
    devlist{ind,1} = '    - YOKOGAWA'; ind = ind + 1;
end

try     % XFR
    xfr_obj = GPconnect(14);     % check the address
%     thermoI(xfr_obj);
    setappdata(0,'xfr_obj',xfr_obj);
catch
%     errordlg('Couldn''t connect to the Yokogawa','Connection Error');
    devlist{ind,1} = '    - XANTREX XFR DC Power supply'; ind = ind + 1;
end

if ind>2
    errh = errordlg(devlist,'Connection Error');
    uiwait(errh);
end

% set temperature timer
TempControl_timer = @(~,~) TempControl(handles);
tempTimer = timer;
tempTimer.Name = 'Temperatre Control Timer';
tempTimer.TimerFcn = TempControl_timer;
tempTimer.Period = 1;
tempTimer.ExecutionMode = 'fixedRate';
start(tempTimer);
setappdata(0,'tempTimer',tempTimer);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes N4TH_GUI wait for user response (see UIRESUME)
% uiwait(handles.N4TH_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = N4TH_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edtFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edtAC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edtDC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnStart.
function btnStart_Callback(hObject, eventdata, handles)
% hObject    handle to btnStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fStr = get(handles.edtFreq,'string');
frequency = str2num(cell2mat(strsplit(fStr)));

acStr = get(handles.edtAC,'string');
AClist = str2num(cell2mat(strsplit(acStr)));

dcStr = get(handles.edtDC,'string');
DClist = str2num(cell2mat(strsplit(dcStr)));

runStr = get(handles.txtRunTitle,'string');
runTitle = getappdata(0,'runTitle');
config = getappdata(0,'defAns');
av = str2double(config{7}); averaging = str2double(config{6});
eval(['volume = ' config{10}]);

outputHP(0,pwr_obj);      % turn off power supply
supVoltage(5,pwr_obj);  % supply 5V (DC)
Ilimit = 15;

for iDC = DClist
    HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B') % turn off function generator
    dcI = setDC(iDC,Ilimit,pwr_obj,N4TH);	% set DC current
    DCstr = ['DC',num2str(round(dcI)),'A'];
    for f = frequency
        HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B') % turn off function generator
        freq = ['F',num2str(f),'Hz'];   % field title
        for iAC = AClist
            runStr{2} = ['DC = ',num2str(iDC),'A  |  AC = ',num2str(iAC)...
                ,'A  |  F = ',num2str(f),'Hz'];
            set(handles.txtRunTitle,'string',runStr);
            [outAC,amp] = setAC(iAC,f,fg,N4TH);   % set AC current
            tempdata = N4TH_1P_GUI(outAC,f,av,round(averaging),N4TH);  % measure 1 point
            amplitude = ['AC',num2str(100*(round(10*outAC))),'mA'];    % field title
            data.(DCstr).(amplitude).(freq) = tempdata.(amplitude).(freq);
            fprintf ('current %0.1fA | Frequency %iHz | Amplitude %0.0fmV | Power %0.3fuW\n',iAC,f,1000*amp,1E6*data.(DCstr).(amplitude).(freq).average(1,3))
            if abs(outAC-iAC)>0.1;
                fprintf ('Warning! current is %i instead of %i\n',outAC,iAC); 
            end
            HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B') % turn off function generator
            pause (1+iAC*f/10000);
            shutdownFlag = getappdata(0,'shutdownFlag');
            while shutdownFlag
                pause(2);
                shutdownFlag = getappdata(0,'shutdownFlag');
            end
        end
        
        outDC = getDC(N4TH);    % check DC current again
        if (outDC/iDC - 1) < 0.02
            setDC(iDC,Ilimit,pwr_obj,N4TH);    % set DC current
        end
    end
    
    data.(DCstr).iAC = sort(AClist);
    data.(DCstr).frequency = sort(frequency);
    
    ttime = toc;
    clc;
    
    fprintf ('Total elapsed time %0.1f minutes \n',ttime/60)
    
    data.(DCstr).loss = LossCalculation(data.(DCstr));
    data.(DCstr).lossH3 = LossCalculationH3(data.(DCstr)); 
    for i = 1:numel(data.(DCstr).frequency)
        data.(DCstr).lossPVPC(:,i) = data.(DCstr).loss(:,i)./(data.(DCstr).frequency(i)*volume);
    end
    data.(DCstr).runtitle = runTitle;
    save(runTitle,'data');
    %Plot and figure save
    h = lossplot(data.(DCstr));
    saveas(h,[pwd '\Figures\' runTitle],'fig')
end

outputHP(0,pwr_obj);    % turn off DC supply



function edtTemp_Callback(hObject, eventdata, handles)
% hObject    handle to edtTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtTemp as text
%        str2double(get(hObject,'String')) returns contents of edtTemp as a double


% --- Executes during object creation, after setting all properties.
function edtTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MAoTLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn1Point.
function btn1Point_Callback(hObject, eventdata, handles)
% hObject    handle to btn1Point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pcell = inputdlg({'Frequncy (Hz):','AC current (Amps):','DC current (Amps):'});
if isempty(pcell) || sum(cellfun(@isempty,pcell))
    warndlg('Canceled operation');
    return;
end
Freq = str2double(pcell{1});
iAC = str2double(pcell{2});
iDC = str2double(pcell{3});
runStr = get(handles.txtRunTitle,'string');
runStr{2} = ['DC = ',pcell{3},'A  |  AC = ',pcell{2},'A  |  F = ',pcell{1},'Hz'];
set(handles.txtRunTitle,'string',runStr);

N4TH = getappdata(0,'N4TH');
fg = getappdata(0,'fg');
pwr_obj = getappdata(0,'pwr_obj');
DClimit = 15;
setDC(iDC,DClimit,pwr_obj,N4TH);
setAC(iAC,Freq,fg,N4TH);

config = getappdata(0,'defAns');
av = str2double(config{7}); averaging = str2double(config{6});
eval(['volume = ' config{10}]);

data = N4TH_1P_GUI(Freq,iAC,av,averaging,N4TH,handles);


% --- Executes on button press in btnProp.
function btnProp_Callback(hObject, eventdata, handles)
% hObject    handle to btnProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
question={'Wire type','Wire shape','Wire dimensions','Vtap distance',...
	'Version','Averaging (lower is faster)', 'Amplification',...
    'Thermometer current (\muA)','Heater resistance (\Omega)','Volume of sample'};
defaultanswer = getappdata(0,'defAns'); % get default answers
options.Interpreter = 'tex';
run = inputdlg(question,'Input',1,defaultanswer,options);
if isempty(run)
    warndlg('No parameters were changed, the script will use the previus ones','Window Closed');
    return;
end
setappdata(0,'defAns',run);
tempStr = [get(handles.edtTemp,'string'),'K'];
run{end} = eval(run{end}); % calculate volume
run = [run(1:4);{tempStr};run(5:end)];
runTitle = strjoin(run(1:6)');
setappdata(0,'runTitle',runTitle);
setappdata(0,'run',run);
runStr = get(handles.txtRunTitle,'string');
runStr{1} = runTitle;
set(handles.txtRunTitle,'string',runStr);

Isrc = num2str(defaultanswer{8});
setappdata(0,'Isrc',Isrc);
yoko_obj = getappdata(0,'yoko_obj');
setYokoCurrent(Isrc,yoko_obj);


function [waves] = N4TH_1P_GUI(f,iAC,av,averaging,N4TH,handles)
% N4TH_1P(current,f,av,averaging,N4th,fg) measures one-point from N4TH device
%   f       - frequency
%   av      - voltage amplification
%   N4TH    - N4TH object
%   fg      - function generator object

% N4TH = getappdata(0,'N4TH');
% fg = getappdata(0,'fg');

freq = ['F',num2str(f),'Hz'];
amplitude = ['amp',num2str(100*(round(10*iAC))),'mA'];

fprintf(N4TH,'FAST,ON');
for ind = 1:averaging
    % do avaraging over multiple measurements
    reading = [];
    pause(1.5);
    while isempty(reading)
        pause(.5);
        reading=query(N4TH,  'LCR?');
    end
    LCR = textscan(reading, '%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
    LCR = LCR{:}; LCR = str2double(LCR);
    
    reading=[];
    while isempty(reading)
        pause(.5);
        reading = query(N4TH,  'POWER?');    
    end
    data = textscan(reading, '%s', 'Delimiter', ',', 'CommentStyle', '\','headerlines',0);
    data = data{:}; data = str2double(data);
    
    Freq(ind)=data(1); VA(ind)=data(4); VAR(ind)=data(6);
    ASR(ind)=LCR(6); RSR(ind)=LCR(11); IMP(ind)=LCR(4);
    Irms(ind)=data(21); Iac(ind)=data(22); Idc(ind)=data(23);
    P(ind)=data(2); PHI(ind)=data(15);
    Vrms(ind)=data(12); Vac(ind)=data(13); Vdc(ind)=data(14); Vcf(ind)=data(17);
    P_f(ind)=data(3);	% power at fundamental f
    VA_f(ind)=data(5);	% power at fundamental f
    P_dc(ind)=data(10); % DC power
    P_h(ind)=data(11);  % power at specific harmonic (default 3)
end
s
fprintf(N4TH,'FAST,OFF');
waves.(amplitude).(freq).average(1,1)= mean(Irms);	% 1 TRMS Current
waves.(amplitude).(freq).average(1,2)= mean(Freq);	% 2 Frequency
waves.(amplitude).(freq).average(1,3)= abs(mean(P)/av); % 3 Active power P [W]
waves.(amplitude).(freq).average(1,4)= mean(VA)/av;	% 4 Apparent power S [VA]
waves.(amplitude).(freq).average(1,5)= mean(PHI);	% 5 Angle PHI
waves.(amplitude).(freq).average(1,6)= mean(VAR);	% 6 Reactive Q [var]
waves.(amplitude).(freq).average(1,7)= mean(ASR)/av; % 7 Active serial resistance
waves.(amplitude).(freq).average(1,8)= mean(RSR)/av; % 8 Reactive serial resistance (reactance)
waves.(amplitude).(freq).average(1,9)= mean(IMP)/av; % 9 Impedance
waves.(amplitude).(freq).average(1,10)= mean(Vac)/av;	% 10 AC Voltage
waves.(amplitude).(freq).average(1,11)= mean(Vdc)/av;	% 11 DC Voltage
waves.(amplitude).(freq).average(1,12)= mean(Vrms)/av;	% 12 TRMS Voltage
waves.(amplitude).(freq).average(1,13)= mean(Vcf);	% Voltage Crest Factor
waves.(amplitude).(freq).average(1,14)= mean(Iac);	% AC current component fundamental
waves.(amplitude).(freq).average(1,15)= mean(Idc);	% DC current component
waves.(amplitude).(freq).average(1,16)= mean(P_f);	% Power at fundamental f [W]
waves.(amplitude).(freq).average(1,17)= mean(VA_f);	% Apparent power at fundamental f
waves.(amplitude).(freq).average(1,18)= mean(P_dc);  % DC power
waves.(amplitude).(freq).average(1,19)= mean(P_h);   % power at specific harmonic (default 3)

% HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B');	% Zero HP

% waves.(amplitude).(freq).average = 1:19;
statusStr = {['TRMS Current:  ' num2str(waves.(amplitude).(freq).average(1,1))];...
             ['Frequency:  ' num2str(waves.(amplitude).(freq).average(1,2))];...
             ['Active Power P [W]:  ' num2str(waves.(amplitude).(freq).average(1,3))];...
             ['Apparent Power S [VA]:  ' num2str(waves.(amplitude).(freq).average(1,4))];...
             ['Angle PHI:  ' num2str(waves.(amplitude).(freq).average(1,5))];...
             ['Reactive Q [var]:  ' num2str(waves.(amplitude).(freq).average(1,6))];...
             ['Active Serial Resistance:  ' num2str(waves.(amplitude).(freq).average(1,7))];...
             ['Reactive serial resistance (reactance):  ' num2str(waves.(amplitude).(freq).average(1,8))];...
             ['Impedance:  ' num2str(waves.(amplitude).(freq).average(1,9))];...
             ['AC Voltage:  ' num2str(waves.(amplitude).(freq).average(1,10))];...
             ['DC Voltage:  ' num2str(waves.(amplitude).(freq).average(1,11))];...
             ['TRMS Voltage:  ' num2str(waves.(amplitude).(freq).average(1,12))];...
             ['Voltage Crest Factor:  ' num2str(waves.(amplitude).(freq).average(1,13))];...
             ['AC Current Component Fundamental:  ' num2str(waves.(amplitude).(freq).average(1,14))];...
             ['DC Current Component:  ' num2str(waves.(amplitude).(freq).average(1,15))];...
             ['Power at Fundamental f [W]:  ' num2str(waves.(amplitude).(freq).average(1,16))];...
             ['Apparent Power at Fundamental f:  ' num2str(waves.(amplitude).(freq).average(1,17))];...
             ['DC Power:  ' num2str(waves.(amplitude).(freq).average(1,18))];...
             ['power at specific harmonic (default 3):  ' num2str(waves.(amplitude).(freq).average(1,19))]};

set(handles.txtStatus,'string',statusStr);

function TempControl(handles)
% TempControl controls on temperature
maxTemp = getappdata(0,'maxTemp');  % get temperature limit
volt_obj = getappdata(0,'volt_obj');% get voltmeter object
Isrc = getappdata(0,'Isrc');        % get sourced current in thermometer
shutdownFlag = getappdata(0,'shutdownFlag');
TempV = getTemp(volt_obj,Isrc*1e-6);% calculate Temperature 
% TempV = 100*rand(1);
spTemp = getappdata(0,'TempSet');
Temp = sprintf('%0.2f',TempV);      % format as text
if TempV > maxTemp   % check if Temp above allowed
    % Yes - shut down the system
    pwr_obj = getappdata(0,'pwr_obj');
    outputHP(0,pwr_obj);    % shutdown DC supplier
    fg = getappdata(0,'fg');
    HP8904A(fg,0,0,'sine',2,'off','B'); % shutdown function generator
    xfr_obj = getappdata(0,'xfr_obj');
    outputXFR(0,xfr_obj);   % sutdown power supply to heater resistor
    set(handles.txtNowTemp,'string',[Temp,'K - Shutdown']);
    setappdata(0,'shutdownFlag',1);
elseif shutdownFlag && TempV-spTemp < 0.3
    setappdata(0,'shutdownFlag',0);
else
    set(handles.txtNowTemp,'string',[Temp,'K']);
end


% --- Executes on button press in btnSetTemp.
function btnSetTemp_Callback(hObject, eventdata, handles)
% hObject    handle to btnSetTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spTemp = str2double(get(handles.edtSetTemp,'string'));
setappdata(0,'TempSet',spTemp);
configs = getappdata(0,'defAns');
Rth = str2double(configs{9});
volt_obj = getappdata(0,'volt_obj');
xfr_obj = getappdata(0,'xfr_obj');
setTemp(spTemp,interval,Rth,volt_obj,xfr_obj);
% waves.iAC = 1:5:100;
% waves.frequency = 100:17:500;
% waves.loss = waves.iAC'*waves.frequency;
% waves.runTitle = getappdata(0,'runTitle');
% lossplot_GUI(waves,handles)


function h = lossplot_GUI(data,handles)
[X,Y] = meshgrid(sort(data.iAC),sort(data.frequency));
axs = handles.axsPlot;
h = surf(axs,X,Y,1000.*data.loss','FaceColor','interp','FaceLighting','gouraud');
% X = 1:5:100; Y = 100:17:500;
% Z = Y'*X;
% h = surf(handles.axsPlot,X,Y,Z,'FaceColor','interp','FaceLighting','gouraud');
title(axs,data.runTitle,'Interpreter','none','Fontsize',12); 
axis(axs,[min(data.iAC) max(data.iAC) 200 max(data.frequency) 1100*min(min(data.loss,[],1)) 1100*max(max(data.loss,[],1))]);
xlabel(axs,'Current [A]rms','Fontsize',12);ylabel(axs,'frequency [Hz]','Fontsize',12);
zlabel(axs,'Losses [mW]','Fontsize',12);
set(axs,'FontSize',12);


function edtMaxTemp_Callback(hObject, eventdata, handles)
% hObject    handle to edtMaxTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currChar = get(handles.N4TH_GUI,'CurrentCharacter');
if isequal(currChar,char(13)) %char(13) == enter key
   % call the pushbutton callback
   btnMaxTemp_Callback(handles.btnMaxTemp, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of edtMaxTemp as text
%        str2double(get(hObject,'String')) returns contents of edtMaxTemp as a double


% --- Executes during object creation, after setting all properties.
function edtMaxTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtMaxTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnMaxTemp.
function btnMaxTemp_Callback(hObject, eventdata, handles)
% hObject    handle to btnMaxTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
maxTemp = str2double(get(handles.edtMaxTemp,'string'));
setappdata(0,'maxTemp',maxTemp);


% --- Executes when user attempts to close N4TH_GUI.
function N4TH_GUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to N4TH_GUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
devlist = {'Couldn''t disconnect from the following devices:'}; ind = 2;
% disconnect from objects
try     % N4TH
    N4TH = getappdata(0,'N4TH');
    fclose(N4TH);
catch
%     errordlg('Couldn''t disconnect from the power supplier','Disconnection Error');
    devlist{ind,1} = '    - N4TH'; ind = ind + 1;
end

try     % function generator
    fg = getappdata(0,'fg');
    HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B') % turn off function generator
    fclose(fg);
catch
%     errordlg('Couldn''t disconnect from the function generator','Disconnection Error');
    devlist{ind,1} = '    - Function Generator'; ind = ind + 1;
end

try     % power supplier
    pwr_obj = getappdata(0,'pwr_obj');
    outputHP(0,pwr_obj);    % turn off
    fclose(pwr_obj);
catch
%     errordlg('Couldn''t disconnect from the power supplier','Disconnection Error');
    devlist{ind,1} = '    - Power Supplier'; ind = ind + 1;
end

try     % voltmeter
    volt_obj = getappdata(0,'volt_obj');
    fclose(volt_obj);
catch
%     errordlg('Couldn''t disconnect from the voltmeter','Disconnection Error');
    devlist{ind,1} = '    - Voltmeter'; ind = ind + 1;
end

try     % YOKOGAWA
    yoko_obj = getappdata(0,'yoko_obj');
    fclose(yoko_obj);
catch
%     errordlg('Couldn''t connect to the Yokogawa','Connection Error');
    devlist{ind,1} = '    - YOKOGAWA'; ind = ind + 1;
end

try     % XFR
    xfr_obj = getappdata(0,'xfr_obj');
    outputXFR(0,xfr_obj);   % turn off
    fclose(xfr_obj);
catch
%     errordlg('Couldn''t connect to the Yokogawa','Connection Error');
    devlist{ind,1} = '    - XANTREX XFR DC Power supply'; ind = ind + 1;
end

if ind>2
    errordlg(devlist,'Disconnection Error');
end

try     % end timer
    tempTimer = getappdata(0,'tempTimer');
    stop(tempTimer);
catch
    errordlg('timer didn''t stop');
end

% Hint: delete(hObject) closes the figure
delete(hObject);

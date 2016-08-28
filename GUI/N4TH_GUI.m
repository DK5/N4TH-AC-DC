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

% Last Modified by GUIDE v2.5 27-Aug-2016 18:12:31

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

defaultanswer = {'Ni-MgB2 ','round','1_3mm','Vtap 50mm','v1','1','1','0.05*(0.0013/2)^2*pi'};
setappdata(0,'defAns',defaultanswer);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes N4TH_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = N4TH_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edtFreq_Callback(hObject, eventdata, handles)
% hObject    handle to edtFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtFreq as text
%        str2double(get(hObject,'String')) returns contents of edtFreq as a double


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



function edtAC_Callback(hObject, eventdata, handles)
% hObject    handle to edtAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtAC as text
%        str2double(get(hObject,'String')) returns contents of edtAC as a double


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



function edtDC_Callback(hObject, eventdata, handles)
% hObject    handle to edtDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtDC as text
%        str2double(get(hObject,'String')) returns contents of edtDC as a double


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
frequency = str2num(cell2mat(fStr));
acStr = get(handles.edtAC,'string');
iAC = str2num(cell2mat(acStr));
dcStr = get(handles.edtDC,'string');
iDC = str2num(cell2mat(dcStr));


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
if isempty(pcell)
    warndlg('Canceled operation');
    return;
end
Freq = str2num(pcell{1});
iAC = str2num(pcell{2});
iDC = str2num(pcell{3});


% --- Executes on button press in btnProp.
function btnProp_Callback(hObject, eventdata, handles)
% hObject    handle to btnProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
question={'Wire type:','Wire shape:','Wire dimensions:','Vtap distance',...
	'Version','Averaging (lower is faster)', 'Amplification','Sample Volume'};
defaultanswer = getappdata(0,'defAns'); % get default answers
run = inputdlg(question,'Input',1,defaultanswer);
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


function [waves] = GUI_N4TH_1P(f,av,averaging,N4TH,fg)
% N4TH_1P(current,f,av,averaging,N4th,fg) measures one-point from N4TH device
%   f       - frequency
%   av      - voltage amplification
%   N4th    - N4TH object
%   fg      - function generator object

freq = ['F',num2str(f),'Hz'];
amplitude = ['amp',num2str(100*(round(10*I))),'mA'];

for ind = 1:averaging
    % do avaraging over multiple measurements
    reading = [];
    fprintf(N4TH,'FAST,ON');
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
    fprintf(N4TH,  'FAST,OFF');
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

HP8904A( fg, 0, 440, 'sine', 2, 'on', 'B');	% Zero HP

function TempControl(handles)
% TempControl controls on temperature 


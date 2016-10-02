function varargout = plotGUI(varargin)
% PLOTGUI MATLAB code for plotGUI.fig
%      PLOTGUI, by itself, creates a new PLOTGUI or raises the existing
%      singleton*.
%
%      H = PLOTGUI returns the handle to a new PLOTGUI or the handle to
%      the existing singleton*.
%
%      PLOTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTGUI.M with the given input arguments.
%
%      PLOTGUI('Property','Value',...) creates a new PLOTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotGUI

% Last Modified by GUIDE v2.5 29-Sep-2016 10:19:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @plotGUI_OutputFcn, ...
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


% --- Executes just before plotGUI is made visible.
function plotGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotGUI (see VARARGIN)

% pathStr = pwd;
[pathStr name ext] = fileparts(mfilename('fullpath'));
sinds = find(pathStr=='\',2,'last');
sind = sinds(1);
dataPath = [pathStr(1:sind) 'Data\'];
setappdata(0,'dataPath',dataPath);

% Choose default command line output for plotGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = plotGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
defPath = getappdata(0,'dataPath');
[FileName,FilePath] = uigetfile([defPath '\*.mat'],'Select the MATLAB file containing Commands');
if FileName==0
    errordlg('Error Reading File','Error 0x002');
    return
end
load([FilePath,FileName]);  % get listbox contents
set(handles.txtVolume,'string',['Volume = ' num2str(data.volume)]);
set(handles.txtTitle,'string',FileName);
TempStr = getNamesByHead(data,'T');
set(handles.mnuTemp,'string',TempStr); set(handles.mnuTemp,'value',1);
DCstr = getNamesByHead(data.(['T' TempStr{1}]),'DC');
set(handles.mnuDC,'string',DCstr); set(handles.mnuDC,'value',1);
ACstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]),'AC');
set(handles.mnuAC,'string',ACstr); set(handles.mnuAC,'value',1);
Fstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]).(['AC' ACstr{1}]),'F');
set(handles.mnuFreq,'string',Fstr); set(handles.mnuFreq,'value',1);
setappdata(0,'data',data);


% --- Executes on selection change in mnuPlot.
function mnuPlot_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = get(hObject,'value');
switch choice
    case 1
        set(handles.mnuFreq,'enable','off');
        set(handles.mnuAC,'enable','on');
    case 2
        set(handles.mnuFreq,'enable','on');
        set(handles.mnuAC,'enable','off');
    case 3
        set(handles.mnuFreq,'enable','off');
        set(handles.mnuAC,'enable','off');
    case 4
        set(handles.mnuFreq,'enable','off');
        set(handles.mnuAC,'enable','on');
end
% Hints: contents = cellstr(get(hObject,'String')) returns mnuPlot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mnuPlot


% --- Executes during object creation, after setting all properties.
function mnuPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mnuPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mnuTemp.
function mnuTemp_Callback(hObject, eventdata, handles)
% hObject    handle to mnuTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TempStr = get(hObject,'string');
tind = get(hObject,'value');
data = getappdata(0,'data');
DCstr = getNamesByHead(data.(['T' TempStr{tind}]),'DC');
set(handles.mnuDC,'string',DCstr); set(handles.mnuDC,'value',1);
ACstr = getNamesByHead(data.(['T' TempStr{tind}]).(['DC' DCstr{1}]),'AC');
set(handles.mnuAC,'string',ACstr); set(handles.mnuAC,'value',1);
Fstr = getNamesByHead(data.(['T' TempStr{tind}]).(['DC' DCstr{1}]).(['AC' ACstr{1}]),'F');
set(handles.mnuFreq,'string',Fstr); set(handles.mnuFreq,'value',1);
% Hints: contents = cellstr(get(hObject,'String')) returns mnuTemp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mnuTemp


% --- Executes during object creation, after setting all properties.
function mnuTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mnuTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mnuDC.
function mnuDC_Callback(hObject, eventdata, handles)
% hObject    handle to mnuDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mnuDC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mnuDC


% --- Executes during object creation, after setting all properties.
function mnuDC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mnuDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mnuAC.
function mnuAC_Callback(hObject, eventdata, handles)
% hObject    handle to mnuAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mnuAC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mnuAC


% --- Executes during object creation, after setting all properties.
function mnuAC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mnuAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mnuFreq.
function mnuFreq_Callback(hObject, eventdata, handles)
% hObject    handle to mnuFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mnuFreq contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mnuFreq


% --- Executes during object creation, after setting all properties.
function mnuFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mnuFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkPC.
function chkPC_Callback(hObject, eventdata, handles)
% hObject    handle to chkPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
btnPlot_Callback(handles.btnPlot,eventdata,handles)
% Hint: get(hObject,'Value') returns toggle state of chkPC


% --- Executes on button press in chkPV.
function chkPV_Callback(hObject, eventdata, handles)
% hObject    handle to chkPV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
btnPlot_Callback(handles.btnPlot,eventdata,handles)
% Hint: get(hObject,'Value') returns toggle state of chkPV

function FieldNames = getNamesByHead(dataStruct,Head)
FieldNames = fieldnames(dataStruct);
eind = [];
for ind = 1:length(FieldNames)
    tstr = FieldNames{ind};
    if ~strcmp(tstr(1:length(Head)),Head)
        eind = [eind ind];
    else
        tstr(1:length(Head)) = [];
        FieldNames{ind} = tstr;
    end
end
FieldNames(eind) = [];


% --- Executes on button press in btnPlot.
function btnPlot_Callback(hObject, eventdata, handles)
% hObject    handle to btnPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = get(handles.mnuPlot,'value');
tind = get(handles.mnuTemp,'value');
TempStr = get(handles.mnuTemp,'string');
TempStr = ['T' TempStr{tind}];

dcind = get(handles.mnuDC,'value');
DCstr = get(handles.mnuDC,'string');
DCstr = ['DC' DCstr{dcind}];

data = getappdata(0,'data');
pdata = data.(TempStr).(DCstr);

pc = get(handles.chkPC,'value');
pv = get(handles.chkPV,'value');

F = pdata.frequency;
Loss = pdata.loss;

if pv
    Loss = Loss/data.volume;
end
if pc
    Loss = Loss./repmat(F,size(Loss,1),1);
end
        
switch choice
    case 1  % Loss vs.  F (2D)
        acind = get(handles.mnuAC,'value');
        ACstr = get(handles.mnuAC,'string'); ACstr = ACstr{acind};
        plot(handles.axsPlot,F,Loss(acind,:));
    case 2  % Loss vs.  AC (2D)
        ffind = get(handles.mnuAC,'value');
        Fstr = get(handles.mnuAC,'string'); Fstr = Fstr{ffind};
        AC = pdata.iAC;
        plot(handles.axsPlot,AC,Loss(:,ffind));
    case 3
        
    case 4
        
end
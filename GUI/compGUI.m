function varargout = compGUI(varargin)
% COMPGUI MATLAB code for compGUI.fig
%      COMPGUI, by itself, creates a new COMPGUI or raises the existing
%      singleton*.
%
%      H = COMPGUI returns the handle to a new COMPGUI or the handle to
%      the existing singleton*.
%
%      COMPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPGUI.M with the given input arguments.
%
%      COMPGUI('Property','Value',...) creates a new COMPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before compGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to compGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help compGUI

% Last Modified by GUIDE v2.5 01-Nov-2016 10:24:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @compGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @compGUI_OutputFcn, ...
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


% --- Executes just before compGUI is made visible.
function compGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to compGUI (see VARARGIN)

% Choose default command line output for compGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes compGUI wait for user response (see UIRESUME)
% uiwait(handles.compFig);


% --- Outputs from this function are returned to the command line.
function varargout = compGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in mnuTemp.
function mnuTemp_Callback(hObject, eventdata, handles)
% hObject    handle to mnuTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TempStr = get(hObject,'string');
tind = get(hObject,'value');
data = getappdata(0,'data2');
DCstr = getNamesByHead(data.(['T' TempStr{tind}]),'DC');
set(handles.mnuDC,'string',DCstr); set(handles.mnuDC,'value',1);
mnuDC_Callback(handles.mnuDC,eventdata,handles);

TempStr = TempStr{tind};
setappdata(0,'TempStr2',TempStr); setappdata(0,'tind2',tind); 
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
TempStr = get(handles.mnuTemp,'string');
tind = get(handles.mnuTemp,'value');
data = getappdata(0,'data2');
DCstr = get(handles.mnuDC,'string');
dcind = get(handles.mnuDC,'value');
ACstr = getNamesByHead(data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]),'AC');
set(handles.mnuAC,'string',ACstr); set(handles.mnuAC,'value',1);
mnuAC_Callback(handles.mnuAC,eventdata,handles);

DCstr = DCstr{dcind};
setappdata(0,'DCstr2',DCstr); setappdata(0,'dcind2',dcind); 
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
TempStr = get(handles.mnuTemp,'string');
tind = get(handles.mnuTemp,'value');
data = getappdata(0,'data2');
DCstr = get(handles.mnuDC,'string');
dcind = get(handles.mnuDC,'value');
ACstr = get(handles.mnuAC,'string');
acind = get(handles.mnuAC,'value');
Fstr = getNamesByHead(data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).(['AC' ACstr{acind}]),'F');
set(handles.mnuFreq,'string',Fstr); set(handles.mnuFreq,'value',1);
mnuFreq_Callback(handles.mnuFreq,eventdata,handles);

ACstr = ACstr{acind};
setappdata(0,'ACstr2',ACstr); setappdata(0,'acind2',acind); 
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
ffind2 = get(handles.mnuFreq,'value');
Fstr2 = get(handles.mnuFreq,'string'); Fstr2 = Fstr2{ffind2};
setappdata(0,'Fstr2',Fstr2); setappdata(0,'ffind2',ffind2); 
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


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
defPath = getappdata(0,'dataPath');
[FileName,FilePath] = uigetfile([defPath '\*.mat'],'Select the file containing the data. 2 files for comparision.');

if FileName==0
    errordlg('Error Reading File','Error 0x002');
    return
end

load([FilePath,FileName]);  % get listbox contents
set(handles.txtRunTitle,'string',FileName);

TempStr = getNamesByHead(data,'T');
set(handles.mnuTemp,'string',TempStr); set(handles.mnuTemp,'value',1);
DCstr = getNamesByHead(data.(['T' TempStr{1}]),'DC');
set(handles.mnuDC,'string',DCstr); set(handles.mnuDC,'value',1);
ACstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]),'AC');
set(handles.mnuAC,'string',ACstr); set(handles.mnuAC,'value',1);
Fstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]).(['AC' ACstr{1}]),'F');
set(handles.mnuFreq,'string',Fstr); set(handles.mnuFreq,'value',1);

setappdata(0,'data2',data);
setappdata(0,'runTitle2',data.runtitle);

setappdata(0,'tind2',1);
setappdata(0,'dcind2',1);
setappdata(0,'acind2',1);

cLoss = cell(length(TempStr),1);
cLossH3 = cLoss; cLossPC = cLoss; cLossH3PC = cLoss;

for tind = 1:length(TempStr)
    DCstr = getNamesByHead(data.(['T' TempStr{tind}]),'DC');
    mloss = zeros(length(ACstr),length(Fstr),length(DCstr));
    mlossH3 = zeros(length(ACstr),length(Fstr),length(DCstr));
    for dcind = 1:length(DCstr)
        mloss(:,:,dcind) = data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).loss;
        mlossH3(:,:,dcind) = data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).lossH3;
    end
    cLoss{tind} = mloss;
    cLossH3{tind} = mlossH3;
    F = data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).frequency;
    cLossPC{tind} = mloss./repmat(F,size(mloss,1),1,size(mloss,3));
    cLossH3PC{tind} = mlossH3./repmat(F,size(mlossH3,1),1,size(mlossH3,3));
end

setappdata(0,'cLoss2',cLoss); setappdata(0,'cLossH32',cLossH3);
setappdata(0,'cLossPC2',cLossPC); setappdata(0,'cLossH3PC2',cLossH3PC);


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


% --- Executes when user attempts to close compFig.
function compFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to compFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    plotFig = findall(0, 'Type', 'figure', 'Tag', 'plotFig');
    handles = guihandles(plotFig);
    set(handles.chkComp,'value',0);
    guidata(handles.plotFig,handles);
catch
end
% Hint: delete(hObject) closes the figure
delete(hObject);

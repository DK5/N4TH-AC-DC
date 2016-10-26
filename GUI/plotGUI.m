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

% Last Modified by GUIDE v2.5 26-Oct-2016 13:22:44

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

% set(handles.plotGUIfig,'CurrentAxes',handles.axsPlot);
% Choose default command line output for plotGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotGUI wait for user response (see UIRESUME)
% uiwait(handles.plotGUIfig);

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
[FileName,FilePath] = uigetfile([defPath '\*.mat'],'Select the file containing the data. 2 files for comparision.','MultiSelect','on');

if ~iscell(FileName)
    if FileName==0
        errordlg('Error Reading File','Error 0x002');
        return
    end
    load([FilePath,FileName]);  % get listbox contents
    cla(handles.axsPlot,'reset');
    set(handles.txtVolume,'string',['Volume = ' num2str(data.volume*10e9) '  mm^3']);
    % set(handles.txtTitle,'string',FileName);
    title(handles.axsPlot,FileName,'Interpreter','none');
    TempStr = getNamesByHead(data,'T');
    set(handles.mnuTemp,'string',TempStr); set(handles.mnuTemp,'value',1);
    DCstr = getNamesByHead(data.(['T' TempStr{1}]),'DC');
    set(handles.mnuDC,'string',DCstr); set(handles.mnuDC,'value',1);
    ACstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]),'AC');
    set(handles.mnuAC,'string',ACstr); set(handles.mnuAC,'value',1);
    Fstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]).(['AC' ACstr{1}]),'F');
    set(handles.mnuFreq,'string',Fstr); set(handles.mnuFreq,'value',1);
    setappdata(0,'data',data);
    setappdata(0,'runTitle',data.runtitle)

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
elseif length(FileName)==2
    cla(handles.axsPlot,'reset');
    load([FilePath,FileName{1}]);  % get listbox contents
    data2 = data;
    load([FilePath,FileName{2}]);  % get listbox contents
    
    if data.volume~=data2.volume
        errordlg('Volume doesn''t match','Error 0x004');
        return
    end
    
    set(handles.txtVolume,'string',['Volume = ' num2str(data.volume*10e9) '  mm^3']);
    % set(handles.txtTitle,'string',FileName);
    title(handles.axsPlot,[data.runtitle,' VS. ',data2.runtitle],'Interpreter','none');
    TempStr = getNamesByHead(data,'T');
    set(handles.mnuTemp,'string',TempStr); set(handles.mnuTemp,'value',1);
    DCstr = getNamesByHead(data.(['T' TempStr{1}]),'DC');
    set(handles.mnuDC,'string',DCstr); set(handles.mnuDC,'value',1);
    ACstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]),'AC');
    set(handles.mnuAC,'string',ACstr); set(handles.mnuAC,'value',1);
    Fstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]).(['AC' ACstr{1}]),'F');
    set(handles.mnuFreq,'string',Fstr); set(handles.mnuFreq,'value',1);
    setappdata(0,'data',data);
    
    setappdata(0,'runTitle',[data.runtitle,' vs. ',data2.runtitle])
    
    cLoss = cell(length(TempStr),1);
    cLossH3 = cLoss; cLossPC = cLoss; cLossH3PC = cLoss;
    
    for tind = 1:length(TempStr)
        DCstr = getNamesByHead(data.(['T' TempStr{tind}]),'DC');
        mloss = zeros(length(ACstr),length(Fstr),length(DCstr));
        mlossH3 = zeros(length(ACstr),length(Fstr),length(DCstr));
        for dcind = 1:length(DCstr)
            mloss(:,:,dcind) = data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).loss - data2.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).loss;
            mlossH3(:,:,dcind) = data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).lossH3 - data2.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).lossH3;
        end
        cLoss{tind} = mloss;
        cLossH3{tind} = mlossH3;
        F = data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).frequency;
        cLossPC{tind} = mloss./repmat(F,size(mloss,1),1,size(mloss,3));
        cLossH3PC{tind} = mlossH3./repmat(F,size(mlossH3,1),1,size(mlossH3,3));
    end
    
else
    errordlg('Can''t choose more than 2 files at once','Error 0x003');
    return
end

setappdata(0,'cLoss',cLoss); setappdata(0,'cLossH3',cLossH3);
setappdata(0,'cLossPC',cLossPC); setappdata(0,'cLossH3PC',cLossH3PC);



% --- Executes on selection change in mnuPlot.
function mnuPlot_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
TempStr = get(handles.mnuTemp,'string');
tind = get(handles.mnuTemp,'value');
data = getappdata(0,'data');
DCstr = get(handles.mnuDC,'string');
dcind = get(handles.mnuDC,'value');
ACstr = getNamesByHead(data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]),'AC');
set(handles.mnuAC,'string',ACstr); set(handles.mnuAC,'value',1);
Fstr = getNamesByHead(data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).(['AC' ACstr{1}]),'F');
set(handles.mnuFreq,'string',Fstr); set(handles.mnuFreq,'value',1);
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
data = getappdata(0,'data');
DCstr = get(handles.mnuDC,'string');
dcind = get(handles.mnuDC,'value');
ACstr = get(handles.mnuAC,'string');
acind = get(handles.mnuAC,'value');
Fstr = getNamesByHead(data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).(['AC' ACstr{acind}]),'F');
set(handles.mnuFreq,'string',Fstr); set(handles.mnuFreq,'value',1);
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
lossChoice = get(handles.mnuPlot,'value');
TempStr = get(handles.mnuTemp,'string');
data = getappdata(0,'data');
runTitle = getappdata(0,'runTitle');

pc = get(handles.chkPC,'value');
pv = get(handles.chkPV,'value');

switch lossChoice   % which loss to draw
    case 1
        LossStr = 'cLoss';
        LossTitle = 'Loss';
    case 2
        LossStr ='cLossH3';
        LossTitle = 'Loss H3';
end

if pc   % draw per cycle
    LossStr = [LossStr 'PC'];
end

Loss = getappdata(0,LossStr);

if pv   % draw per volume
    for tind = 1:length(TempStr)
        Loss{tind} = Loss{tind}/data.volume;
    end
end

tind = get(handles.mnuTemp,'value');
TempStr = TempStr{tind};
dcind = get(handles.mnuDC,'value');
DCstr = get(handles.mnuDC,'string'); DCstr = DCstr{dcind};
acind = get(handles.mnuAC,'value');
ACstr = get(handles.mnuAC,'string'); ACstr = ACstr{acind};
ffind = get(handles.mnuFreq,'value');
Fstr = get(handles.mnuFreq,'string'); Fstr = Fstr{ffind};

xVar = [1 4 6 8]; yVar = [1 3 5 7];
xind = get(handles.mnuX,'value');
yind = get(handles.mnuY,'value');

switch yVar(yind)*xVar(xind)
    case 1  % Loss vs.  F (2D)
        mLoss = Loss{tind}; F = data.(['T' TempStr]).(['DC' DCstr]).frequency;
        plot(handles.axsPlot,F,mLoss(acind,:,dcind)*1000);
        xlabel(handles.axsPlot,'frequency [Hz]');ylabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. Frequency , T = ',TempStr,' , DC = ',DCstr,' , AC = ',ACstr];runTitle},...
            'interpreter','none');
        
    case 4  % Loss vs.  AC (2D)
        AC = data.(['T' TempStr]).(['DC' DCstr]).iAC;
        mLoss = Loss{tind};
        plot(handles.axsPlot,AC,mLoss(:,ffind,dcind)*1000);
        xlabel(handles.axsPlot,'AC Current [A] rms');ylabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. AC , T = ',TempStr,' , DC = ',DCstr,' , F = ',Fstr];runTitle},...
            'interpreter','none');
        
    case 6  % Loss vs.  DC (2D)
        dcList = get(handles.mnuDC,'string');
        dcVals = strjoin(dcList',',');	% join strings
        dcVals(dcVals=='A') = [];       % remove units
        dcVals = str2num(dcVals);       %#ok<ST2NM> % build number array
        mLoss = Loss{tind}; dcLoss = reshape(mLoss(acind,ffind,:),size(mLoss,3),1,1);
        plot(handles.axsPlot,dcVals,dcLoss*1000);
        xlabel(handles.axsPlot,'DC Current [A] rms');ylabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. DC , T = ',TempStr,' , AC = ',ACstr,' , F = ',Fstr];runTitle},...
            'interpreter','none');
        
    case 8  % Loss vs. T (2D)
        tList = get(handles.mnuTemp,'string');
        tVals = strjoin(tList',',');   % join strings
        tVals(tVals=='K') = [];       % remove units
        tVals = str2num(tVals);       %#ok<ST2NM> % build number array
        lossT = zeros(1,length(tList));
        for tind = 1:length(tList)
            LossAll = Loss{tind};
            lossT(tind) = LossAll(acind,ffind,dcind);
        end
        plot(handles.axsPlot,tVals,lossT*1000);
        xlabel(handles.axsPlot,'Temperature [K]');ylabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. T , DC = ',DCstr,' , AC = ',ACstr,' , F = ',Fstr];runTitle},...
            'interpreter','none');
        
    case {3,12}  % Loss vs. F & AC (3D)
        pdata = data.(['T' TempStr]).(['DC' DCstr]);
        mLoss = Loss{tind}; mLoss = mLoss(:,:,dcind);
        [X,Y] = meshgrid(sort(pdata.iAC),sort(pdata.frequency));
        surf(handles.axsPlot,X,Y,1000.*mLoss','FaceColor','interp','FaceLighting','gouraud');
        try
            axis(handles.axsPlot,[min(pdata.iAC) max(pdata.iAC) min(pdata.frequency) max(pdata.frequency) 900*min(min(mLoss,[],1)) 1100*max(max(mLoss,[],1))]);
        catch
            disp('error setting axes');
        end
        xlabel(handles.axsPlot,'AC Current RMS [A]');ylabel(handles.axsPlot,'frequency [Hz]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. AC & F ,',' T = ',TempStr,' , DC = ',DCstr];runTitle},...
            'interpreter','none');

    case {5,18}  % Loss vs. F & DC (3D)
        pdata = data.(['T' TempStr]).(['DC' DCstr]);
        mLoss = Loss{tind}; mLoss = reshape(mLoss(acind,:,:),size(mLoss,2),size(mLoss,3),1);
        dcList = get(handles.mnuDC,'string');
        dcVals = strjoin(dcList',',');	% join strings
        dcVals(dcVals=='A') = [];       % remove units
        dcVals = str2num(dcVals);       %#ok<ST2NM> % build number array
        [X,Y] = meshgrid(dcVals,sort(pdata.frequency));
        surf(handles.axsPlot,X,Y,1000.*mLoss,'FaceColor','interp','FaceLighting','gouraud');
        try
            axis(handles.axsPlot,[min(dcVals) max(dcVals) min(pdata.frequency) max(pdata.frequency) 900*min(min(mLoss,[],1)) 1100*max(max(mLoss,[],1))]);
        catch
            disp('error setting axes');
        end
        xlabel(handles.axsPlot,'DC Current [A]');ylabel(handles.axsPlot,'frequency [Hz]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. DC & F ,',' T = ',TempStr,' , AC = ',ACstr];runTitle},...
            'interpreter','none');
        
    case {7,24}  % Loss vs. F & T (3D)
        tList = get(handles.mnuTemp,'string');
        tVals = strjoin(tList',',');  % join strings
        tVals(tVals=='K') = [];       % remove units
        tVals = str2num(tVals);       %#ok<ST2NM> % build number array
        fVals = data.(['T' TempStr]).(['DC' DCstr]).frequency;
        [X,Y] = meshgrid(fVals,tVals);
        lossT = zeros(length(tVals),length(fVals));
        for tind = 1:length(tList)
            LossAll = Loss{tind};
            lossT(tind,:) = LossAll(acind,:,dcind);
        end
        % axes('Fontsize',12);
        surf(handles.axsPlot,X,Y,1000.*lossT,'FaceColor','interp','FaceLighting','gouraud');
        try
            axis(handles.axsPlot,[min(fVals) max(fVals) min(tVals) max(tVals) 900*min(min(lossT,[],1)) 1100*max(max(lossT,[],1))]);
        catch
            disp('error setting axes');
        end
        xlabel(handles.axsPlot,'Frequency [Hz]');ylabel(handles.axsPlot,'Temperature [K]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. F & T ,',' DC = ',DCstr,' , AC = ',ACstr];runTitle},...
            'interpreter','none');
        
    case {20,30} % Loss vs. AC & DC (3D)
        pdata = data.(['T' TempStr]).(['DC' DCstr]);
        mLoss = Loss{tind}; mLoss = reshape(mLoss(:,ffind,:),size(mLoss,1),size(mLoss,3),1);
        dcList = get(handles.mnuDC,'string');
        dcVals = strjoin(dcList',',');	% join strings
        dcVals(dcVals=='A') = [];       % remove units
        dcVals = str2num(dcVals);       %#ok<ST2NM> % build number array
        [X,Y] = meshgrid(dcVals,sort(pdata.iAC));
        surf(handles.axsPlot,X,Y,1000.*mLoss,'FaceColor','interp','FaceLighting','gouraud');
        try
            axis(handles.axsPlot,[min(dcVals) max(dcVals) min(pdata.iAC) max(pdata.iAC) 900*min(min(mLoss,[],1)) 1100*max(max(mLoss,[],1))]);
        catch
            disp('error setting axes');
        end
        xlabel(handles.axsPlot,'DC Current [A]');ylabel(handles.axsPlot,'AC current RMS [A]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. DC & AC ,',' T = ',TempStr,' , F = ',Fstr];runTitle},...
            'interpreter','none');
        
    case {28,40} % Loss vs. AC & T (3D)
        tList = get(handles.mnuTemp,'string');
        tVals = strjoin(tList',',');  % join strings
        tVals(tVals=='K') = [];       % remove units
        tVals = str2num(tVals);       %#ok<ST2NM> % build number array
        acVals = data.(['T' TempStr]).(['DC' DCstr]).iAC;
        [X,Y] = meshgrid(acVals,tVals);
        lossT = zeros(length(tVals),length(acVals));
        for tind = 1:length(tList)
            LossAll = Loss{tind};
            lossT(tind,:) = LossAll(:,ffind,dcind)';
        end
        % axes('Fontsize',12);
        surf(handles.axsPlot,X,Y,1000.*lossT,'FaceColor','interp','FaceLighting','gouraud');
        try
            axis(handles.axsPlot,[min(acVals) max(acVals) min(tVals) max(tVals) 900*min(min(lossT,[],1)) 1100*max(max(lossT,[],1))]);
        catch
            disp('error setting axes');
        end
        xlabel(handles.axsPlot,'AC Current RMS [A]');ylabel(handles.axsPlot,'Temperature [K]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. AC & T ,',' DC = ',DCstr,' , F = ',Fstr];runTitle},...
            'interpreter','none');
        
    case {42,56} % Loss vs. DC & T (3D)
        tList = get(handles.mnuTemp,'string');
        tVals = strjoin(tList',',');   % join strings
        tVals(tVals=='K') = [];       % remove units
        tVals = str2num(tVals);       %#ok<ST2NM> % build number array
        dcList = get(handles.mnuDC,'string');
        dcVals = strjoin(dcList',',');	% join strings
        dcVals(dcVals=='A') = [];       % remove units
        dcVals = str2num(dcVals);       %#ok<ST2NM> % build number array
        [X,Y] = meshgrid(dcVals,tVals);
        lossT = zeros(length(tVals),length(dcVals));
        for tind = 1:length(tList)
            LossAll = Loss{tind};
            lossT(tind,:) = reshape(LossAll(acind,ffind,:),1,size(LossAll,3),1);
        end
        % axes('Fontsize',12);
        surf(handles.axsPlot,X,Y,1000.*lossT,'FaceColor','interp','FaceLighting','gouraud');
        try
            axis(handles.axsPlot,[min(dcVals) max(dcVals) min(tVals) max(tVals) 900*min(min(lossT,[],1)) 1100*max(max(lossT,[],1))]);
        catch
            disp('error setting axes');
        end
        xlabel(handles.axsPlot,'DC Current [A]');ylabel(handles.axsPlot,'Temperature [K]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title({[LossTitle, ' vs. DC & T ,',' AC = ',ACstr,' , F = ',Fstr];runTitle},...
            'interpreter','none');
        
    otherwise
        yVar(yind)*xVar(xind)
        error('Not a valid choice');
end

set(gca,'FontSize',12);


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FileName = '';% get(handles.file_name_edit,'String');  % get the desired filename
dataPath = getappdata(0,'dataPath');
[FileName,dir] = uiputfile('*.png','Save Script',[dataPath FileName]);
if ~dir
%     errordlg('No directory was chosen');
    return;
end
FileName = [dir,FileName(1:end-4)];
NewFig = figure;
ax_new = copyobj(handles.axsPlot,NewFig);
% hgsave(NewFig, 'myFigure.fig');
% set(NewFig,'units','inches');
% set(NewFig,'position',[0.25 0.25 0.5 0.5]);
% pos = get(NewFig,'Innerposition');
set(ax_new,'units','normalized','Position',[0.1 0.15 0.85 0.77]);
print(NewFig,FileName,'-r300','-dpng');
close(NewFig);
winopen([FileName,'.png']);


% --- Executes on button press in btnOpen.
function btnOpen_Callback(hObject, eventdata, handles)
% hObject    handle to btnOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NewFig = figure;
ax_new = copyobj(handles.axsPlot,NewFig);
% hgsave(NewFig, 'myFigure.fig');
% set(NewFig,'units','normalized');
% set(NewFig,'position',[0.25 0.25 0.5 0.5]);
% pos = get(NewFig,'Innerposition');
set(ax_new,'units','normalized','Position',[0.1 0.15 0.85 0.77]);


% --- Executes on selection change in mnuX.
function mnuX_Callback(hObject, eventdata, handles)
% hObject    handle to mnuX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xind = get(hObject,'value');
varStr = get(hObject,'string');
varStr(xind) = [];
varStr = [{'---'}; varStr];
set(handles.mnuY,'string',varStr);
% Hints: contents = cellstr(get(hObject,'String')) returns mnuX contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mnuX


% --- Executes during object creation, after setting all properties.
function mnuX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mnuX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mnuY.
function mnuY_Callback(hObject, eventdata, handles)
% hObject    handle to mnuY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mnuY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mnuY


% --- Executes during object creation, after setting all properties.
function mnuY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mnuY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

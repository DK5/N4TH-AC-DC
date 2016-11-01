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

% Last Modified by GUIDE v2.5 30-Oct-2016 12:01:14

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
[FileName,FilePath] = uigetfile([defPath '\*.mat'],'Select the file containing the data','MultiSelect','off');
% [FileName,FilePath] = uigetfile([defPath '\*.mat'],'Select the file containing the data. 2 files for comparision.','MultiSelect','on');

if ~iscell(FileName)
    if FileName==0
        errordlg('Error Reading File','Error 0x002');
        return
    end
    load([FilePath,FileName]);  % get listbox contents
    cla(handles.axsPlot,'reset');
    set(handles.btnSwap,'visible','off');
    set(handles.btnSwap,'enable','off');
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
    
    load([FilePath,FileName{1}]);  % get listbox contents
    data2 = data;
    load([FilePath,FileName{2}]);  % get listbox contents
    
    if data.volume~=data2.volume
        errordlg('Volume doesn''t match','Error 0x004');
        return
    end
    set(handles.txtVolume,'string',['Volume = ' num2str(data.volume*10e9) '  mm^3']);
    % set(handles.txtTitle,'string',FileName);
    TempStr = getNamesByHead(data,'T');
    set(handles.mnuTemp,'string',TempStr); set(handles.mnuTemp,'value',1);
    DCstr = getNamesByHead(data.(['T' TempStr{1}]),'DC');
    set(handles.mnuDC,'string',DCstr); set(handles.mnuDC,'value',1);
    ACstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]),'AC');
    set(handles.mnuAC,'string',ACstr); set(handles.mnuAC,'value',1);
    Fstr = getNamesByHead(data.(['T' TempStr{1}]).(['DC' DCstr{1}]).(['AC' ACstr{1}]),'F');
    set(handles.mnuFreq,'string',Fstr); set(handles.mnuFreq,'value',1);
    
    cLoss = cell(length(TempStr),1);
    cLossH3 = cLoss; cLossPC = cLoss; cLossH3PC = cLoss;
    
    for tind = 1:length(TempStr)
        DCstr = getNamesByHead(data.(['T' TempStr{tind}]),'DC');
        mloss = zeros(length(ACstr),length(Fstr),length(DCstr));
        mlossH3 = zeros(length(ACstr),length(Fstr),length(DCstr));
        for dcind = 1:length(DCstr)
            try
                mloss(:,:,dcind) = data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).loss - data2.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).loss;
                mlossH3(:,:,dcind) = data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).lossH3 - data2.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).lossH3;
            catch
                errordlg('AC & F values must agree','Error 0x005');
                return
            end
        end
        cLoss{tind} = mloss;
        cLossH3{tind} = mlossH3;
        F = data.(['T' TempStr{tind}]).(['DC' DCstr{dcind}]).frequency;
        cLossPC{tind} = mloss./repmat(F,size(mloss,1),1,size(mloss,3));
        cLossH3PC{tind} = mlossH3./repmat(F,size(mlossH3,1),1,size(mlossH3,3));
    end
    
    cla(handles.axsPlot,'reset');
    setappdata(0,'data',data);
    setappdata(0,'runTitle',[data.runtitle,' vs. ',data2.runtitle])
    title(handles.axsPlot,[data.runtitle,' vs. ',data2.runtitle],'Interpreter','none');
    set(handles.btnSwap,'visible','on');
    set(handles.btnSwap,'enable','on');
    
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
set(handles.mnuDC,'string',DCstr);
mnuDC_Callback(handles.mnuDC,eventdata,handles);
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
set(handles.mnuAC,'string',ACstr);
mnuAC_Callback(handles.mnuAC,eventdata,handles);
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
set(handles.mnuFreq,'string',Fstr);
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
    LossTitle = [LossTitle ' Per Cycle'];
end

Loss = getappdata(0,LossStr);

comp = get(handles.chkComp,'value');
if comp
    runTitle2 = getappdata(0,'runTitle2');
    volume2 = getappdata(0,'volume2');
    Loss2 = getappdata(0,[LossStr '2']);
    tind2 = getappdata(0,'tind2');
    TempStr2 = getappdata(0,'TempStr2');
    dcind2 = getappdata(0,'dcind2');
    DCstr2 = getappdata(0,'DCstr2');
    acind2 = getappdata(0,'acind2');
    ACstr2 = getappdata(0,'ACstr2');
    ffind2 = getappdata(0,'ffind2');
    Fstr2 = getappdata(0,'Fstr2');
end


if pv   % draw per volume
    LossTitle = [LossTitle ' Per Volume'];
    for tind = 1:length(TempStr)
        Loss{tind} = Loss{tind}/data.volume;
        if comp
            Loss2{tind} = Loss2{tind}/volume2;
        end
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
        pLoss = mLoss(acind,:,dcind);
        
        if comp
            mLoss2 = Loss2{tind2};
            pLoss = pLoss - mLoss2(acind2,:,dcind2);
            titleStr = {[LossTitle, ' vs. Frequency'];...
                [runTitle,' @ T = ',TempStr,' , DC = ',DCstr,' , AC = ',ACstr];...
                ['vs. ',runTitle2,' @ T = ',TempStr2,' , DC = ',DCstr2,' , AC = ',ACstr2]};
        else
            titleStr = {[LossTitle, ' vs. Frequency'];['T = ',TempStr,' , DC = ',DCstr,' , AC = ',ACstr];runTitle};
        end
        plot(handles.axsPlot,F,pLoss*1000);
        title(titleStr,'interpreter','none');
        xlabel(handles.axsPlot,'frequency [Hz]');ylabel(handles.axsPlot,'Losses [mW]');
        
        
    case 4  % Loss vs.  AC (2D)
        AC = data.(['T' TempStr]).(['DC' DCstr]).iAC;
        mLoss = Loss{tind}; pLoss = mLoss(:,ffind,dcind);
        
        if comp
            mLoss2 = Loss2{tind2};
            pLoss = pLoss - mLoss2(:,ffind2,dcind2);
            titleStr = {[LossTitle, ' vs. AC'];...
                [runTitle,' @ T = ',TempStr,' , DC = ',DCstr,' , F = ',Fstr];...
                ['vs. ',runTitle2,' @ T = ',TempStr2,' , DC = ',DCstr2,' , F = ',Fstr2]};
        else
            titleStr = {[LossTitle, ' vs. AC'];['T = ',TempStr,' , DC = ',DCstr,' , F = ',Fstr];runTitle};
        end
        plot(handles.axsPlot,AC,pLoss*1000);
        xlabel(handles.axsPlot,'AC Current [A] rms');ylabel(handles.axsPlot,'Losses [mW]');
        title(titleStr,'interpreter','none');
        
    case 6  % Loss vs.  DC (2D)
        dcList = get(handles.mnuDC,'string');
        dcVals = strjoin(dcList',',');	% join strings
        dcVals(dcVals=='A') = [];       % remove units
        dcVals = str2num(dcVals);       %#ok<ST2NM> % build number array
        mLoss = Loss{tind}; dcLoss = reshape(mLoss(acind,ffind,:),size(mLoss,3),1,1);
        
        if comp
            mLoss2 = Loss2{tind2};
            dcLoss2 = reshape(mLoss2(acind2,ffind2,:),size(mLoss2,3),1,1);
            dcLoss = dcLoss - dcLoss2;
             titleStr = {[LossTitle, ' vs. DC'];...
                [runTitle,' @ T = ',TempStr,' , AC = ',ACstr,' , F = ',Fstr];...
                ['vs. ',runTitle2,' @ T = ',TempStr2,' , AC = ',ACstr2,' , F = ',Fstr2]};
        else
            titleStr = {[LossTitle, ' vs. DC'];['T = ',TempStr,' , AC = ',ACstr,' , F = ',Fstr];runTitle};
        end
        plot(handles.axsPlot,dcVals,dcLoss*1000);
        xlabel(handles.axsPlot,'DC Current [A] rms');ylabel(handles.axsPlot,'Losses [mW]');
        title(titleStr,'interpreter','none');
        
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
        
        if comp
            lossT2 = zeros(1,length(tList));
            for tind = 1:length(tList)
                LossAll = Loss2{tind};
                lossT2(tind) = LossAll(acind2,ffind2,dcind2);
            end
            lossT = lossT - lossT2;
            titleStr = {[LossTitle, ' vs. T'];...
                [runTitle,' @ DC = ',DCstr,' , AC = ',ACstr,' , F = ',Fstr];...
                ['vs. ',runTitle2,' @ DC = ',DCstr2,' , AC = ',ACstr2,' , F = ',Fstr2]};
        else
            titleStr = {[LossTitle, ' vs. T'];['DC = ',DCstr,' , AC = ',ACstr,' , F = ',Fstr];runTitle};
        end
        plot(handles.axsPlot,tVals,lossT*1000);
        xlabel(handles.axsPlot,'Temperature [K]');ylabel(handles.axsPlot,'Losses [mW]');
        title(titleStr,'interpreter','none');
        
    case {3,12}  % Loss vs. F & AC (3D)
        pdata = data.(['T' TempStr]).(['DC' DCstr]);
        mLoss = Loss{tind}; mLoss = mLoss(:,:,dcind);
        [X,Y] = meshgrid(sort(pdata.iAC),sort(pdata.frequency));
        
        if comp
            mLoss2 = Loss{tind2}; mLoss2 = mLoss2(:,:,dcind2);
            mLoss = mLoss - mLoss2;
            titleStr = {[LossTitle, ' vs. F & AC'];...
                [runTitle,' @ T = ',TempStr,' , DC = ',DCstr];...
                ['vs. ',runTitle2,' @ T = ',TempStr2,' , DC = ',DCstr2]};
        else
            titleStr = {[LossTitle, ' vs. F & AC'];['T = ',TempStr,' , DC = ',DCstr];runTitle};
        end
        surf(handles.axsPlot,X,Y,1000.*mLoss','FaceColor','interp','FaceLighting','gouraud');
        xlabel(handles.axsPlot,'AC Current RMS [A]');ylabel(handles.axsPlot,'frequency [Hz]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title(titleStr,'interpreter','none');

    case {5,18}  % Loss vs. F & DC (3D)
        pdata = data.(['T' TempStr]).(['DC' DCstr]);
        mLoss = Loss{tind}; mLoss = reshape(mLoss(acind,:,:),size(mLoss,2),size(mLoss,3),1);
        dcList = get(handles.mnuDC,'string');
        dcVals = strjoin(dcList',',');	% join strings
        dcVals(dcVals=='A') = [];       % remove units
        dcVals = str2num(dcVals);       %#ok<ST2NM> % build number array
        [X,Y] = meshgrid(dcVals,sort(pdata.frequency));
        
        if comp
            mLoss2 = Loss{tind2}; mLoss2 = reshape(mLoss2(acind2,:,:),size(mLoss2,2),size(mLoss2,3),1);
            mLoss = mLoss - mLoss2;
            titleStr = {[LossTitle, ' vs. DC & F'];...
                [runTitle,' @ T = ',TempStr,' , AC = ',ACstr];...
                ['vs. ',runTitle2,' @ T = ',TempStr2,' , AC = ',ACstr2]};
        else
            titleStr = {[LossTitle, ' vs. DC & F'];['T = ',TempStr,' , AC = ',ACstr];runTitle};
        end
        surf(handles.axsPlot,X,Y,1000.*mLoss,'FaceColor','interp','FaceLighting','gouraud');
        xlabel(handles.axsPlot,'DC Current [A]');ylabel(handles.axsPlot,'frequency [Hz]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title(titleStr,'interpreter','none');
        
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
        
        if comp
            lossT2 = zeros(length(tVals),length(fVals));
            for tind = 1:length(tList)
                LossAll = Loss2{tind};
                lossT2(tind,:) = LossAll(acind2,:,dcind2);
            end
            lossT = lossT - lossT2;
            titleStr = {[LossTitle, ' vs. F & T'];...
                [runTitle,' @ DC = ',DCstr,' , AC = ',ACstr];...
                ['vs. ',runTitle2,' @ DC = ',DCstr2,' , AC = ',ACstr2]};
        else
            titleStr = {[LossTitle, ' vs. F & T'];['DC = ',DCstr,' , AC = ',ACstr];runTitle};
        end
        surf(handles.axsPlot,X,Y,1000.*lossT,'FaceColor','interp','FaceLighting','gouraud');
        xlabel(handles.axsPlot,'Frequency [Hz]');ylabel(handles.axsPlot,'Temperature [K]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title(titleStr,'interpreter','none');
        
    case {20,30} % Loss vs. AC & DC (3D)
        pdata = data.(['T' TempStr]).(['DC' DCstr]);
        mLoss = Loss{tind}; mLoss = reshape(mLoss(:,ffind,:),size(mLoss,1),size(mLoss,3),1);
        dcList = get(handles.mnuDC,'string');
        dcVals = strjoin(dcList',',');	% join strings
        dcVals(dcVals=='A') = [];       % remove units
        dcVals = str2num(dcVals);       %#ok<ST2NM> % build number array
        [X,Y] = meshgrid(dcVals,sort(pdata.iAC));
        
        if comp
            mLoss2 = Loss2{tind}; mLoss2 = reshape(mLoss2(:,ffind2,:),size(mLoss2,1),size(mLoss2,3),1);
            mLoss = mLoss - mLoss2;
            titleStr = {[LossTitle, ' vs. DC & AC'];...
                [runTitle,' @ T = ',TempStr,' , F = ',Fstr];...
                ['vs. ',runTitle2,' @ T = ',TempStr2,' , F = ',Fstr2]};
        else
            titleStr = {[LossTitle, ' vs. DC & AC'];['T = ',TempStr,' , F = ',Fstr];runTitle};
        end
        surf(handles.axsPlot,X,Y,1000.*mLoss,'FaceColor','interp','FaceLighting','gouraud');
        xlabel(handles.axsPlot,'DC Current [A]');ylabel(handles.axsPlot,'AC current RMS [A]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title(titleStr,'interpreter','none');
        
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
        
        if comp
            lossT2 = zeros(length(tVals),length(acVals));
            for tind = 1:length(tList)
                LossAll = Loss2{tind};
                lossT2(tind,:) = LossAll(:,ffind2,dcind2)';
            end
            lossT = lossT - lossT2;
            titleStr = {[LossTitle, ' vs. AC & T'];...
                [runTitle ' @ DC = ',DCstr,' , F = ',Fstr];...
                ['vs. ',runTitle2,' @ DC = ',DCstr2,' , F = ',Fstr2]};
        else
            titleStr = {[LossTitle, ' vs. AC & T'];['DC = ',DCstr,' , F = ',Fstr];runTitle};
        end
        surf(handles.axsPlot,X,Y,1000.*lossT,'FaceColor','interp','FaceLighting','gouraud');
        xlabel(handles.axsPlot,'AC Current RMS [A]');ylabel(handles.axsPlot,'Temperature [K]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title(titleStr,'interpreter','none');
        
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
        
        if comp
            lossT2 = zeros(length(tVals),length(dcVals));
            for tind = 1:length(tList)
                LossAll = Loss2{tind};
                lossT2(tind,:) = reshape(LossAll(acind2,ffind2,:),1,size(LossAll,3),1);
            end
            lossT = lossT - lossT2;
            titleStr = {[LossTitle, ' vs. DC & T'];...
                [runTitle,' @ AC = ',ACstr,' , F = ',Fstr];...
                ['vs. ',runTitle2,' @ AC = ',ACstr2,' , F = ',Fstr2]};
        else
            titleStr = {[LossTitle, ' vs. DC & T'];['AC = ',ACstr,' , F = ',Fstr];runTitle};
        end
        surf(handles.axsPlot,X,Y,1000.*lossT,'FaceColor','interp','FaceLighting','gouraud');
        xlabel(handles.axsPlot,'DC Current [A]');ylabel(handles.axsPlot,'Temperature [K]');
        zlabel(handles.axsPlot,'Losses [mW]');
        title(titleStr,'interpreter','none');
        
    otherwise
        yVar(yind)*xVar(xind);
        error('Not a valid choice');
end

set(gca,'FontSize',12);


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
th = get(handles.axsPlot,'Title');
titleStr = get(th,'string');
FileName = strjoin(titleStr,'_');
% FileName = strrep(FileName,' ','');
FileName = strrep(FileName,'.','');
FileName = strrep(FileName,',','_');
% FileName = '';% get(handles.file_name_edit,'String');  % get the desired filename
dataPath = getappdata(0,'dataPath');
[FileName,dir] = uiputfile('*.png','Save Script',[dataPath FileName]);
if ~dir
%     errordlg('No directory was chosen');
    return;
end
FileName = [dir,FileName(1:end-4)];
NewFig = figure('units','inches','position',[0.5 0.5 2 1.5]*3.5);
ax_new = copyobj(handles.axsPlot,NewFig);
% hgsave(NewFig, 'myFigure.fig');
% set(NewFig,'units','inches');
% set(NewFig,'position',[0.25 0.25 0.5 0.5]);
% pos = get(NewFig,'Innerposition');
set(ax_new,'units','normalized','Position',[0.1 0.1 0.85 0.77]);
print(NewFig,FileName,'-r400','-dpng');
close(NewFig);
winopen([FileName,'.png']);


% --- Executes on button press in btnOpen.
function btnOpen_Callback(hObject, eventdata, handles)
% hObject    handle to btnOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NewFig = figure('units','inches','position',[0.5 0.5 2 1.5]*3.5);
ax_new = copyobj(handles.axsPlot,NewFig);
% hgsave(NewFig, 'myFigure.fig');
% set(NewFig,'units','normalized');
% set(NewFig,'position',[0.25 0.25 0.5 0.5]);
% pos = get(NewFig,'Innerposition');
set(ax_new,'units','normalized','Position',[0.1 0.1 0.85 0.77]);


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


% --- Executes on button press in btnSwap.
function btnSwap_Callback(hObject, eventdata, handles)
% hObject    handle to btnSwap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cLoss = getappdata(0,'cLoss'); cLossPC = getappdata(0,'cLossPC');
cLossH3 = getappdata(0,'cLossH3'); cLossH3PC = getappdata(0,'cLossH3PC');
runTitle = getappdata(0,'runTitle');

for tind = length(cLoss)
     cLoss{tind} = -cLoss{tind};
     cLossPC{tind} = -cLossPC{tind};
     cLossH3{tind} = -cLossH3{tind};
     cLossH3PC{tind} = -cLossH3PC{tind};
end

vsind = strfind(runTitle,' vs. ');
newRunTitle = [runTitle(vsind+5:end),' vs. ',runTitle(1:vsind)];
setappdata(0,'runTitle',newRunTitle);
setappdata(0,'cLoss',cLoss); setappdata(0,'cLossH3',cLossH3);
setappdata(0,'cLossPC',cLossPC); setappdata(0,'cLossH3PC',cLossH3PC);


% --- Executes on button press in chkComp.
function chkComp_Callback(hObject, eventdata, handles)
% hObject    handle to chkComp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comp = get(hObject,'value');
if comp
    compGUI;
end
% Hint: get(hObject,'Value') returns toggle state of chkComp

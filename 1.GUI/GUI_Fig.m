function varargout = GUI_Fig(varargin)
% GUI_FIG MATLAB code for GUI_Fig.fig
%      GUI_FIG, by itself, creates a new GUI_FIG or raises the existing
%      singleton*.
%
%      H = GUI_FIG returns the handle to a new GUI_FIG or the handle to
%      the existing singleton*.
%
%      GUI_FIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FIG.M with the given input arguments.
%
%      GUI_FIG('Property','Value',...) creates a new GUI_FIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Fig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Fig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Fig

% Last Modified by GUIDE v2.5 07-Mar-2018 09:52:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Fig_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Fig_OutputFcn, ...
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

% --- Executes just before GUI_Fig is made visible.
function GUI_Fig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Fig (see VARARGIN)

% Choose default command line output for GUI_Fig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using GUI_Fig.

% UIWAIT makes GUI_Fig wait for user response (see UIRESUME)
% uiwait(handles.iVixIndexMonitor);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Fig_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
global dOptionTemp
global dOptionMarketInfo
global dVixIndex
global cSetupPlatform
global dRealTimeVix

% Data Refresh
handles.Table_OptionInfo.Data = dOptionTemp;
handles.s50ETFPrice.String = num2str(dOptionMarketInfo(end, 2));
handles.sCurrentTime.String = num2str(dVixIndex(end, 1));
handles.sVix.String = num2str(dVixIndex(end, 2));
handles.sVix_Call.String = num2str(dVixIndex(end, 3));
handles.sVix_Put.String = num2str(dVixIndex(end, 4));
handles.sWindStatus.String = cSetupPlatform.Wind.Status;

% Plot
dLocated = ~isnan(dRealTimeVix(:, 2));
plot(handles.Axes_Vix, ...
    dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 2), 'Black', ...
    dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 3), 'Red', ...
    dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 4), 'Blue', ...
    'LineWidth', 1.5)

handles.Axes_Vix.XLim = [0, 14400];
% handles.Axes_Vix.YLim = [0, 100];
handles.Axes_Vix.XTick = 0 : 1800 : 14400;
handles.Axes_Vix.XTickLabel = {'9:30:00','10:00:00','10:30:00','11:00:00','11:30:00','13:30:00','14:00:00','14:30:00','15:00:00'};
% handles.Axes_Vix.YTick = 0 : 10 : 100;
% handles.Axes_Vix.YTickLabel = {'0','10','20','30','40','50','60','70','80', '90', '100'};
cLegend = {'Vix', 'Vxo_Call', 'Vxo_Put'};

if ~isempty(cLegend)
    legend(handles.Axes_Vix, cLegend)
else
end
title(handles.Axes_Vix, 'Vix Indexs')


dLocated = ~isnan(dRealTimeVix(:, 5));
plot(handles.Axes_ETF, dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 5), 'LineWidth',1.5 ...
    , 'Color', 'Black')

if max(abs(dRealTimeVix(dLocated, 5))) <= 2
    handles.Axes_ETF.YLim = [-2, 2];
    handles.Axes_ETF.YTick = -2 : 0.5 : 2;
    handles.Axes_ETF.YTickLabel = {'-2.0%','-1.5%','-1.0%','-0.5%','0.0%','0.5%','+1.0%','+1.5%','+2.0%'};
    
elseif max(abs(dRealTimeVix(dLocated, 5))) <= 4
    handles.Axes_ETF.YLim = [-4, 4];
    handles.Axes_ETF.YTick = -4 : 1 : 4;
    handles.Axes_ETF.YTickLabel = {'-4.0%','-3.0%','-2.0%','-1.0%','0.0%','1.0%','+2.0%','+3.0%','+4.0%'};
    
elseif max(abs(dRealTimeVix(dLocated, 5))) <= 6
    handles.Axes_ETF.YLim = [-6, 6];
    handles.Axes_ETF.YTick = -6 : 1.5 : 6;
    handles.Axes_ETF.YTickLabel = {'-6.0%','-4.5%','-3.0%','-1.5%','0.0%','1.5%','+3.0%','+4.5%','+6.0%'};
    
elseif max(abs(dRealTimeVix(dLocated, 5))) <= 8
    handles.Axes_ETF.YLim = [-8, 8];
    handles.Axes_ETF.YTick = -8 : 2 : 8;
    handles.Axes_ETF.YTickLabel = {'-8.0%','-6.0%','-4.0%','-2.0%','0.0%','2.0%','+4.0%','+6.0%','+8.0%'};
    
elseif max(abs(dRealTimeVix(dLocated, 5))) <= 10
    handles.Axes_ETF.YLim = [-10, 10];
    handles.Axes_ETF.YTick = -10 : 2 : 10;
    handles.Axes_ETF.YTickLabel = {'-10.0%','-8.0%','-6.0%','-4.0%','-2.0%','0.0%', '+2.0%','+4.0%','+6.0%','+8.0%', '+10.0%'};
    
else
    handles.Axes_ETF.YLim = [-10.1, 10.1];
    handles.Axes_ETF.YTick = [-10.1, -10 : 2 : 10, 10.1];
    handles.Axes_ETF.YTickLabel = {'-10.1%', '-10.0%','-8.0%','-6.0%','-4.0%','-2.0%','0.0%', '+2.0%','+4.0%','+6.0%','+8.0%', '+10.0%', '+10.1%'};
    
end

handles.Axes_ETF.XLim = [0, 14400];
handles.Axes_ETF.XTick = 0 : 1800 : 14400;
handles.Axes_ETF.XTickLabel = {'9:30:00','10:00:00','10:30:00','11:00:00','11:30:00','13:30:00','14:00:00','14:30:00','15:00:00'};
title(handles.Axes_ETF, '50ETF ож╪ш')


% --- Executes during object creation, after setting all properties.
function Axes_Vix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_Vix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Axes_Vix
hObject.XLim = [0, 14400];
hObject.YLim = [0, 100];
hObject.XTick = 0 : 1800 : 14400;
hObject.XTickLabel = {'9:30:00','10:00:00','10:30:00','11:00:00','11:30:00','13:30:00','14:00:00','14:30:00','15:00:00'};
hObject.YTick = 0 : 10 : 100;
hObject.YTickLabel = {'0','10','20','30','40','50','60','70','80', '90', '100'};

% --- Executes during object creation, after setting all properties.
function Table_OptionInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Table_OptionInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dOptionTemp

hObject.Data = dOptionTemp;


% --- Executes when entered data in editable cell(s) in Table_OptionInfo.
function Table_OptionInfo_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Table_OptionInfo (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function Axes_ETF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_ETF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Axes_ETF
hObject.XLim = [0, 14400];
hObject.XTick = 0 : 1800 : 14400;
hObject.XTickLabel = {'9:30:00','10:00:00','10:30:00','11:00:00','11:30:00','13:30:00','14:00:00','14:30:00','15:00:00'};


% --- Executes when user attempts to close iVixIndexMonitor.
function iVixIndexMonitor_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to iVixIndexMonitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
global cSetupPlatform

cSetupPlatform.GUI.IsOpen = false;

function Fun_Save_Image(handle)
axes(handle);
newfig=figure;
set(newfig,'visible','off');
set(newfig,'color','w');
newaxes=copyobj(handles.Axes_Vix,newfig);
set(newaxes,'Units','default','Position','default');

str=fullfile([],'123.jpg');
f=getframe(newfig);
f=frame2im(f);
imwrite(f,str, 'jpg');
close(newfig)


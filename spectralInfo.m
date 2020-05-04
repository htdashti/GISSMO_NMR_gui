function varargout = spectralInfo(varargin)
% SPECTRALINFO MATLAB code for spectralInfo.fig
%      SPECTRALINFO, by itself, creates a new SPECTRALINFO or raises the existing
%      singleton*.
%
%      H = SPECTRALINFO returns the handle to a new SPECTRALINFO or the handle to
%      the existing singleton*.
%
%      SPECTRALINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECTRALINFO.M with the given input arguments.
%
%      SPECTRALINFO('Property','Value',...) creates a new SPECTRALINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spectralInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spectralInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spectralInfo

% Last Modified by GUIDE v2.5 11-Jul-2016 10:51:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spectralInfo_OpeningFcn, ...
                   'gui_OutputFcn',  @spectralInfo_OutputFcn, ...
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


% --- Executes just before spectralInfo is made visible.
function spectralInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spectralInfo (see VARARGIN)

% Choose default command line output for spectralInfo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spectralInfo wait for user response (see UIRESUME)
% uiwait(handles.figure1);

handles.selected_domain = varargin{1};
handles.selected_spectrum = varargin{2};
handles.field = varargin{3};
handles.integral_coeff = varargin{4};
guidata(hObject, handles);
process(hObject, eventdata, handles);

function process(hObject, eventdata, handles)
global Peak_positions
Peak_positions = [];
dcm_obj = datacursormode(handles.figure1);
set(dcm_obj,'UpdateFcn',@myupdatefcn);

selected_domain = handles.selected_domain;
selected_spectrum = handles.selected_spectrum;
axes(handles.axes1);
plot(selected_domain, selected_spectrum);
integ = sum(selected_spectrum)*handles.integral_coeff;
title(sprintf('Integral of the selected region: %.03f', integ));
set(gca, 'xdir', 'reverse');
hold off




function txt = myupdatefcn(empt,event_obj)
global Peak_positions
if size(Peak_positions, 1) == 2
    Peak_positions = [];
end
% Customizes text of data tips
pos = get(event_obj,'Position');
Peak_positions(end+1, :) = [pos(1), pos(2)];
if size(Peak_positions, 1) == 2
    txt = 'now process the selected peaks!';
else
    txt = 'select one more peak!';
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Peak_positions
if size(Peak_positions, 1) < 2
    errordlg('Please select two peaks!');
    return
end

selected_domain = handles.selected_domain;
selected_spectrum = handles.selected_spectrum;
axes(handles.axes1);
plot(selected_domain, selected_spectrum);
hold on

Ylim = ylim(handles.axes1);
Peak1_ppm = Peak_positions(1, 1);
Peak1_amp = Peak_positions(1, 2);
scatter(Peak1_ppm, Peak1_amp, 'rx')
scatter(Peak1_ppm, Peak1_amp, 'ro')

Peak2_ppm = Peak_positions(2, 1);
Peak2_amp = Peak_positions(2, 2);
scatter(Peak2_ppm, Peak2_amp, 'rx')
scatter(Peak2_ppm, Peak2_amp, 'ro')

Mean = mean([Peak1_ppm, Peak2_ppm]);
plot([Mean;Mean], [Ylim(1);Ylim(2)], '--k');
plot([Peak1_ppm; Peak2_ppm], [Peak2_amp;Peak2_amp], 'b')


integ = sum(selected_spectrum)*handles.integral_coeff;
title({sprintf('Integral of the selected region: %.03f', integ), sprintf('difference in Hz: %.03f', handles.field*(abs(Peak1_ppm-Peak2_ppm))), sprintf('mean in ppm: %.03f', Mean)});
Peak_positions = [];

set(gca, 'xdir', 'reverse');
hold off


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
process(hObject, eventdata, handles)

% --- Outputs from this function are returned to the command line.
function varargout = spectralInfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1)
%delete(hObject);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --------------------------------------------------------------------
% function uitoggletool4_ClickedCallback(hObject, eventdata, handles)
% % hObject    handle to uitoggletool4 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% function uitoggletool7_ClickedCallback(hObject, eventdata, handles)
% % hObject    handle to uitoggletool7 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % datacursormode(handles.axes1);
% i = 0;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

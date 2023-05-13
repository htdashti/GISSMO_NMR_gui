function varargout = Guided_optimization(varargin)
% GUIDED_OPTIMIZATION MATLAB code for Guided_optimization.fig
%      GUIDED_OPTIMIZATION, by itself, creates a new GUIDED_OPTIMIZATION or raises the existing
%      singleton*.
%
%      H = GUIDED_OPTIMIZATION returns the handle to a new GUIDED_OPTIMIZATION or the handle to
%      the existing singleton*.
%
%      GUIDED_OPTIMIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDED_OPTIMIZATION.M with the given input arguments.
%
%      GUIDED_OPTIMIZATION('Property','Value',...) creates a new GUIDED_OPTIMIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Guided_optimization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Guided_optimization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Guided_optimization

% Last Modified by GUIDE v2.5 14-Apr-2017 14:56:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Guided_optimization_OpeningFcn, ...
                   'gui_OutputFcn',  @Guided_optimization_OutputFcn, ...
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


% --- Executes just before Guided_optimization is made visible.
function Guided_optimization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Guided_optimization (see VARARGIN)

% Choose default command line output for Guided_optimization
handles.output = hObject;
handles.atom_names = varargin{1};
setappdata(0,'ABx_oprimization_var', []);
% Update handles structure
guidata(hObject, handles);
init(hObject, eventdata, handles)
% UIWAIT makes Guided_optimization wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function init(hObject, eventdata, handles)
global parameters_bothner_by

handles = guidata(hObject);
atom_names = handles.atom_names;
Data = cell(length(atom_names), 2);
for i=1:length(atom_names)
    Data{i, 1} = atom_names{i}; Data{i, 2} = false;
end
set(handles.bothnerby_angle_text, 'String', sprintf('%.01f', parameters_bothner_by.angle));
set(handles.uitable1, 'Data', Data, 'ColumnFormat', {'char', 'logical'}, 'ColumnEditable', [false, true]);
set(handles.uitable2, 'Data', Data, 'ColumnFormat', {'char', 'logical'}, 'ColumnEditable', [false, true]);


% --- Executes on button press in Optimize.
function Optimize_Callback(hObject, eventdata, handles)
global parameters_bothner_by
% hObject    handle to Optimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitable1, 'Data');
strongly_coupled = [];
for i=1:size(data, 1)
    if data{i, 2}
        strongly_coupled = [strongly_coupled; i];
    end
end
data = get(handles.uitable2, 'Data');
weakly_coupled = [];
for i=1:size(data, 1)
    if data{i, 2}
        weakly_coupled = [weakly_coupled; i];
    end
end
if length(strongly_coupled) ~= 2
    errordlg('You need to select two spins!')
    return
end
if length(weakly_coupled) ~= 1 && length(weakly_coupled) ~= 2
    errordlg('You need to select one or two spins!')
    return
end

% if min(strongly_coupled) > max(weakly_coupled)
%     choice = questdlg({'The corresponding coupling constants are selected from the lower-triangle of the spin-matrix.', 'the selected strong and weak spins will be swapped. Would you like to continue?'}, 'auto-swapping the spins', 'Yes', 'No', 'Yes');
%     if strcmp(choice, 'Yes')
%         temp = strongly_coupled;
%         strongly_coupled = weakly_coupled;
%         weakly_coupled = temp;
%     else
%         return
%     end
% end

ABx_oprimization_var.strong = strongly_coupled;
ABx_oprimization_var.weak = weakly_coupled;
ABx_oprimization_var.strong_flag = get(handles.strong_flag, 'Value');
ABx_oprimization_var.weak_flag = get(handles.weak_flag, 'Value');
val = str2double(get(handles.bothnerby_angle_text, 'String'));
ABx_oprimization_var.angle = 30;
parameters_bothner_by.angle = val;

setappdata(0,'ABx_oprimization_var', ABx_oprimization_var);
Cancel_Callback(hObject, eventdata, handles)

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);
% --- Outputs from this function are returned to the command line.
function varargout = Guided_optimization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in strong_flag.
function strong_flag_Callback(hObject, eventdata, handles)
% hObject    handle to strong_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of strong_flag


% --- Executes on button press in weak_flag.
function weak_flag_Callback(hObject, eventdata, handles)
% hObject    handle to weak_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of weak_flag


% --- Executes on button press in degree_60.
function degree_60_Callback(hObject, eventdata, handles)
% hObject    handle to degree_60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.degree_30, 'Value', 0);

% Hint: get(hObject,'Value') returns toggle state of degree_60


% --- Executes on button press in degree_30.
function degree_30_Callback(hObject, eventdata, handles)
% hObject    handle to degree_30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of degree_30
set(handles.degree_60, 'Value', 0);

% --- Executes on key press with focus on degree_60 and none of its controls.
function degree_60_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to degree_60 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
set(handles.degree_30, 'Value', 0);


% --- Executes on key press with focus on degree_30 and none of its controls.
function degree_30_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to degree_30 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
set(handles.degree_30, 'Value', 0);



function bothnerby_angle_text_Callback(hObject, eventdata, handles)
% hObject    handle to bothnerby_angle_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bothnerby_angle_text as text
%        str2double(get(hObject,'String')) returns contents of bothnerby_angle_text as a double


% --- Executes during object creation, after setting all properties.
function bothnerby_angle_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bothnerby_angle_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

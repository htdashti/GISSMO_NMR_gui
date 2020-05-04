function varargout = add_spins(varargin)
% ADD_SPINS MATLAB code for add_spins.fig
%      ADD_SPINS, by itself, creates a new ADD_SPINS or raises the existing
%      singleton*.
%
%      H = ADD_SPINS returns the handle to a new ADD_SPINS or the handle to
%      the existing singleton*.
%
%      ADD_SPINS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADD_SPINS.M with the given input arguments.
%
%      ADD_SPINS('Property','Value',...) creates a new ADD_SPINS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before add_spins_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to add_spins_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help add_spins

% Last Modified by GUIDE v2.5 13-Jul-2018 09:58:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @add_spins_OpeningFcn, ...
                   'gui_OutputFcn',  @add_spins_OutputFcn, ...
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


% --- Executes just before add_spins is made visible.
function add_spins_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to add_spins (see VARARGIN)

% Choose default command line output for add_spins
handles.output = hObject;
input = varargin{1};
handles.cs = input.cs;
handles.spin_names = input.spin_names;

output.spin_names = {};
output.cs = [];
setappdata(0, 'new_spins', output);

% Update handles structure
guidata(hObject, handles);
init_gui(hObject, eventdata, handles) 
% UIWAIT makes add_spins wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function init_gui(hObject, eventdata, handles) 
cs = handles.cs;
spin_names = handles.spin_names;
data = cell(length(cs), 2);
for i=1:length(cs)
    data{i,1} = spin_names{i};
    data{i, 2}=cs(i);
end
set(handles.uitable1, 'data', data, 'ColumnName', {'spin label', 'Chemical shift'});

% --- Outputs from this function are returned to the command line.
function varargout = add_spins_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_num_spins_Callback(hObject, eventdata, handles)
function edit_num_spins_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_create_Callback(hObject, eventdata, handles)
num_new_spins = str2double(get(handles.edit_num_spins, 'String'));
if isnan(num_new_spins)
    uiwait(msgbox('number of spins is not a number?!'));
    return
end
data = cell(num_new_spins, 2);
set(handles.uitable2, 'data', data, 'ColumnName', {'spin label', 'Chemical shift'}, 'ColumnEditable', [true, true], 'Visible', 'On');

% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)
data = get(handles.uitable2, 'data');
new_names = cell(size(data, 1), 1);
cs = zeros(size(new_names));
for i=1:length(new_names)
    new_names{i} = data{i, 1};
    cs(i) = str2double(data{i, 2});
    if nnz(strcmp(new_names{i}, handles.spin_names)) ~= 0
        uiwait(msgbox({'duplicate spin label:', new_names{i}}))
        return
    end
    if isnan(cs(i))
        uiwait(msgbox({'CS should be numeric:', sprintf('spin: %s', new_names{i})}))
    end
end
output.spin_names = new_names;
output.cs = cs;
setappdata(0, 'new_spins', output);
close(handles.figure1);

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);

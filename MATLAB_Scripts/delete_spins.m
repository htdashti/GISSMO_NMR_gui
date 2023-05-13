function varargout = delete_spins(varargin)
% DELETE_SPINS MATLAB code for delete_spins.fig
%      DELETE_SPINS, by itself, creates a new DELETE_SPINS or raises the existing
%      singleton*.
%
%      H = DELETE_SPINS returns the handle to a new DELETE_SPINS or the handle to
%      the existing singleton*.
%
%      DELETE_SPINS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DELETE_SPINS.M with the given input arguments.
%
%      DELETE_SPINS('Property','Value',...) creates a new DELETE_SPINS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before delete_spins_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to delete_spins_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help delete_spins

% Last Modified by GUIDE v2.5 13-Jul-2018 09:58:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @delete_spins_OpeningFcn, ...
                   'gui_OutputFcn',  @delete_spins_OutputFcn, ...
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


% --- Executes just before delete_spins is made visible.
function delete_spins_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to delete_spins (see VARARGIN)

% Choose default command line output for delete_spins
handles.output = hObject;
input = varargin{1};
handles.cs = input.cs;
handles.spin_names = input.spin_names;
setappdata(0, 'delete_spins', []);
% Update handles structure
guidata(hObject, handles);
init(hObject, eventdata, handles)
% UIWAIT makes delete_spins wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function init(hObject, eventdata, handles)
cs = handles.cs;
spin_names = handles.spin_names;
data = cell(length(cs), 3);
for i=1:length(cs)
    data{i, 1} = false;
    data{i, 2} = spin_names{i};
    data{i, 3} = cs(i);
end
set(handles.uitable1, 'data', data, 'ColumnName', {'remove', 'spin label', 'Chemical shift'}, 'ColumnEditable', [true, false, false]);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = delete_spins_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_delete.
function pushbutton_delete_Callback(hObject, eventdata, handles)
data = get(handles.uitable1, 'data');
removed = cell2mat(data(:, 1));
num_del = nnz(removed);
if num_del > 0
    choice = questdlg(sprintf('%d spins will be removed. Would you like to continue?', num_del), 'Adding new spin', 'Yes', 'No', 'No');
    if strcmp(choice, 'No')
        return
    end
end
setappdata(0, 'delete_spins', removed);
close(handles.figure1);

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
setappdata(0, 'delete_spins', []);
close(handles.figure1);

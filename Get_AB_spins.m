function varargout = Get_AB_spins(varargin)
% GET_AB_SPINS MATLAB code for Get_AB_spins.fig
%      GET_AB_SPINS, by itself, creates a new GET_AB_SPINS or raises the existing
%      singleton*.
%
%      H = GET_AB_SPINS returns the handle to a new GET_AB_SPINS or the handle to
%      the existing singleton*.
%
%      GET_AB_SPINS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GET_AB_SPINS.M with the given input arguments.
%
%      GET_AB_SPINS('Property','Value',...) creates a new GET_AB_SPINS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Get_AB_spins_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Get_AB_spins_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Get_AB_spins

% Last Modified by GUIDE v2.5 22-Mar-2017 14:22:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Get_AB_spins_OpeningFcn, ...
                   'gui_OutputFcn',  @Get_AB_spins_OutputFcn, ...
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


% --- Executes just before Get_AB_spins is made visible.
function Get_AB_spins_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Get_AB_spins (see VARARGIN)

% Choose default command line output for Get_AB_spins
handles.output = hObject;

input = varargin{1};
handles.atom_names = input.atom_names;

% Update handles structure
guidata(hObject, handles);
init(hObject, handles)

% UIWAIT makes Get_AB_spins wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function init(hObject, handles)
handles = guidata(hObject);
data = cell(length(handles.atom_names), 2);
for i=1:length(handles.atom_names)
    data{i, 1} = handles.atom_names{i};
    data{i, 2} = false;
end
set(handles.uitable1, 'Data', data, 'ColumnEditable', [false, true]);
setappdata(0, 'AB_spins_flag', []);
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Get_AB_spins_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitable1, 'Data');
out = [];
for i=1:size(data, 1)
    if data{i, 2}
        out = [out; i];
    end
end
if length(out) ~= 2
    errordlg('you need to select spins A and B (two spins)');
    return;
end
setappdata(0, 'AB_spins_flag', out);
cancel_Callback(hObject, eventdata, handles)

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);

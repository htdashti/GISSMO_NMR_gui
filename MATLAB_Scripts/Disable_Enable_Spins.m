function varargout = Disable_Enable_Spins(varargin)
% DISABLE_ENABLE_SPINS MATLAB code for Disable_Enable_Spins.fig
%      DISABLE_ENABLE_SPINS, by itself, creates a new DISABLE_ENABLE_SPINS or raises the existing
%      singleton*.
%
%      H = DISABLE_ENABLE_SPINS returns the handle to a new DISABLE_ENABLE_SPINS or the handle to
%      the existing singleton*.
%
%      DISABLE_ENABLE_SPINS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISABLE_ENABLE_SPINS.M with the given input arguments.
%
%      DISABLE_ENABLE_SPINS('Property','Value',...) creates a new DISABLE_ENABLE_SPINS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Disable_Enable_Spins_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Disable_Enable_Spins_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Disable_Enable_Spins

% Last Modified by GUIDE v2.5 13-Feb-2017 11:26:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Disable_Enable_Spins_OpeningFcn, ...
                   'gui_OutputFcn',  @Disable_Enable_Spins_OutputFcn, ...
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


% --- Executes just before Disable_Enable_Spins is made visible.
function Disable_Enable_Spins_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Disable_Enable_Spins (see VARARGIN)

% Choose default command line output for Disable_Enable_Spins
handles.output = hObject;
input = varargin{1};
spin_names = input.spin_names;
setappdata(0, 'selectedSpins', true(length(spin_names), 1));
handles.spin_names = spin_names;
% Update handles structure
guidata(hObject, handles);
init(hObject, eventdata, handles);
% UIWAIT makes Disable_Enable_Spins wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function init(hObject, eventdata, handles)
handles = guidata(hObject);
spin_names = handles.spin_names;
data = cell(length(spin_names), 2);
for i=1:size(data, 1)
    data{i, 1} = spin_names{i};
    data{i, 2} = true;
end
set(handles.uitable1, 'Data', data, 'ColumnEditable', [false true]);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Disable_Enable_Spins_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)
data = get(handles.uitable1, 'data');
selected = true(size(data, 1), 1);
for i=1:size(data, 1)
    if ~data{i, 2}
        selected(i) = false;
    end
end
setappdata(0, 'selectedSpins', selected);
cancel_Callback(hObject, eventdata, handles)

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);

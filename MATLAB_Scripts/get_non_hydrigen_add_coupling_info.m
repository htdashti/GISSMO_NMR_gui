function varargout = get_non_hydrigen_add_coupling_info(varargin)
% GET_NON_HYDRIGEN_ADD_COUPLING_INFO MATLAB code for get_non_hydrigen_add_coupling_info.fig
%      GET_NON_HYDRIGEN_ADD_COUPLING_INFO, by itself, creates a new GET_NON_HYDRIGEN_ADD_COUPLING_INFO or raises the existing
%      singleton*.
%
%      H = GET_NON_HYDRIGEN_ADD_COUPLING_INFO returns the handle to a new GET_NON_HYDRIGEN_ADD_COUPLING_INFO or the handle to
%      the existing singleton*.
%
%      GET_NON_HYDRIGEN_ADD_COUPLING_INFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GET_NON_HYDRIGEN_ADD_COUPLING_INFO.M with the given input arguments.
%
%      GET_NON_HYDRIGEN_ADD_COUPLING_INFO('Property','Value',...) creates a new GET_NON_HYDRIGEN_ADD_COUPLING_INFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before get_non_hydrigen_add_coupling_info_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to get_non_hydrigen_add_coupling_info_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help get_non_hydrigen_add_coupling_info

% Last Modified by GUIDE v2.5 25-Feb-2017 19:45:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @get_non_hydrigen_add_coupling_info_OpeningFcn, ...
                   'gui_OutputFcn',  @get_non_hydrigen_add_coupling_info_OutputFcn, ...
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


% --- Executes just before get_non_hydrigen_add_coupling_info is made visible.
function get_non_hydrigen_add_coupling_info_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to get_non_hydrigen_add_coupling_info (see VARARGIN)

% Choose default command line output for get_non_hydrigen_add_coupling_info
handles.output = hObject;
input = varargin{1};
handles.data = input.data;
handles.index = input.index;
% Update handles structure
guidata(hObject, handles);
init(hObject, handles)

function init(hObject, handles)
handles = guidata(hObject);
spin_names = handles.data{handles.index, 1};
coupling = handles.data{handles.index, 2};
set(handles.text3, 'String', spin_names);
set(handles.text5, 'String', coupling);
setappdata(0, 'non_hyd_tag', '');
guidata(hObject, handles);
% UIWAIT makes get_non_hydrigen_add_coupling_info wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = get_non_hydrigen_add_coupling_info_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function name_Callback(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name as text
%        str2double(get(hObject,'String')) returns contents of name as a double


% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
Note = get(handles.name, 'String');
setappdata(0, 'non_hyd_tag', Note);
close(handles.figure1);

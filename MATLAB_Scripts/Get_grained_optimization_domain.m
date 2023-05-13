function varargout = Get_grained_optimization_domain(varargin)
% GET_GRAINED_OPTIMIZATION_DOMAIN MATLAB code for Get_grained_optimization_domain.fig
%      GET_GRAINED_OPTIMIZATION_DOMAIN, by itself, creates a new GET_GRAINED_OPTIMIZATION_DOMAIN or raises the existing
%      singleton*.
%
%      H = GET_GRAINED_OPTIMIZATION_DOMAIN returns the handle to a new GET_GRAINED_OPTIMIZATION_DOMAIN or the handle to
%      the existing singleton*.
%
%      GET_GRAINED_OPTIMIZATION_DOMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GET_GRAINED_OPTIMIZATION_DOMAIN.M with the given input arguments.
%
%      GET_GRAINED_OPTIMIZATION_DOMAIN('Property','Value',...) creates a new GET_GRAINED_OPTIMIZATION_DOMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Get_grained_optimization_domain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Get_grained_optimization_domain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Get_grained_optimization_domain

% Last Modified by GUIDE v2.5 20-Jan-2017 12:33:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Get_grained_optimization_domain_OpeningFcn, ...
                   'gui_OutputFcn',  @Get_grained_optimization_domain_OutputFcn, ...
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


% --- Executes just before Get_grained_optimization_domain is made visible.
function Get_grained_optimization_domain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Get_grained_optimization_domain (see VARARGIN)

% Choose default command line output for Get_grained_optimization_domain
handles.output = hObject;
Min = varargin{1};
Max = varargin{2};
set(handles.edit1, 'String', sprintf('%.03f', Min));
set(handles.edit2, 'String', sprintf('%.03f', Max));
setappdata(0,'grained_cs_domain', [0, Min, Max]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Get_grained_optimization_domain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Get_grained_optimization_domain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)
% hObject    handle to Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Min = str2double(get(handles.edit1, 'String'));
Max = str2double(get(handles.edit2, 'String'));
setappdata(0,'grained_cs_domain', [1, Min, Max]);
close(handles.figure1);

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

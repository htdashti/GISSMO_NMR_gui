function varargout = DrawInchi_Gui(varargin)
% DRAWINCHI_GUI MATLAB code for DrawInchi_Gui.fig
%      DRAWINCHI_GUI, by itself, creates a new DRAWINCHI_GUI or raises the existing
%      singleton*.
%
%      H = DRAWINCHI_GUI returns the handle to a new DRAWINCHI_GUI or the handle to
%      the existing singleton*.
%
%      DRAWINCHI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRAWINCHI_GUI.M with the given input arguments.
%
%      DRAWINCHI_GUI('Property','Value',...) creates a new DRAWINCHI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DrawInchi_Gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DrawInchi_Gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DrawInchi_Gui

% Last Modified by GUIDE v2.5 11-Jul-2016 10:50:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DrawInchi_Gui_OpeningFcn, ...
                   'gui_OutputFcn',  @DrawInchi_Gui_OutputFcn, ...
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


% --- Executes just before DrawInchi_Gui is made visible.
function DrawInchi_Gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DrawInchi_Gui (see VARARGIN)

% Choose default command line output for DrawInchi_Gui
handles.output = hObject;
input = varargin{1};
handles.inchi = input.InChI;
% Update handles structure
guidata(hObject, handles);
init(hObject, handles)
% UIWAIT makes DrawInchi_Gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function init(hObject, handles)
handles = guidata(hObject);
set(handles.edit1, 'String', handles.inchi);

% --- Outputs from this function are returned to the command line.
function varargout = DrawInchi_Gui_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in Draw.
function Draw_Callback(hObject, eventdata, handles)
% hObject    handle to Draw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inchi = get(handles.edit1, 'String');
%try
BGobj = convert_inchi_to_graph(inchi);
h = my_bggui(BGobj);
% i = 0;
% f = get(h.biograph.hgAxes, 'Parent');
%         print(f, '-djpeg', sprintf('%s/inchi.jpg','.'));
%         close(f);
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);
%delete(hObject);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

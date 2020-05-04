function varargout = Load_inchi_fig_gui(varargin)
% LOAD_INCHI_FIG_GUI MATLAB code for Load_inchi_fig_gui.fig
%      LOAD_INCHI_FIG_GUI, by itself, creates a new LOAD_INCHI_FIG_GUI or raises the existing
%      singleton*.
%
%      H = LOAD_INCHI_FIG_GUI returns the handle to a new LOAD_INCHI_FIG_GUI or the handle to
%      the existing singleton*.
%
%      LOAD_INCHI_FIG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_INCHI_FIG_GUI.M with the given input arguments.
%
%      LOAD_INCHI_FIG_GUI('Property','Value',...) creates a new LOAD_INCHI_FIG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_inchi_fig_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_inchi_fig_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Load_inchi_fig_gui

% Last Modified by GUIDE v2.5 11-Jul-2016 10:50:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_inchi_fig_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_inchi_fig_gui_OutputFcn, ...
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


% --- Executes just before Load_inchi_fig_gui is made visible.
function Load_inchi_fig_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_inchi_fig_gui (see VARARGIN)

% Choose default command line output for Load_inchi_fig_gui
handles.output = hObject;
Paths = varargin{1};
%Path_figure = Paths{1};
inchi =  Paths{1};
Path_figure2 = Paths{2};

set(handles.edit1, 'String', inchi);
% if exist(Path_figure, 'file')
%     im = imread(Path_figure);
%     axes(handles.axes1)
%     imshow(im);
% else
%     axes(handles.axes2);
%     plot([0;1], [1;1]);
%     plot([0;0], [0;1]);
%     set(gca, 'xlim', [0 1]);
%     set(gca, 'ylim', [0 1]);
%     text(.9, .5, 'graph representation of the InChI is not available')
% end
if exist(Path_figure2, 'file')
    im = imread(Path_figure2);
    axes(handles.axes2)
    imshow(im);
else
    uiwait(msgbox('Figure was not found! check the path in the xml file.'))
    axes(handles.axes2);
    plot([0;1], [1;1]);
    plot([0;0], [0;1]);
    set(gca, 'xlim', [0 1]);
    set(gca, 'ylim', [0 1]);
    text(.9, .5, '2D plot of the molecule is not available')
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_inchi_fig_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Load_inchi_fig_gui_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
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

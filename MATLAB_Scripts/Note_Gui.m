function varargout = Note_Gui(varargin)
% NOTE_GUI MATLAB code for Note_Gui.fig
%      NOTE_GUI, by itself, creates a new NOTE_GUI or raises the existing
%      singleton*.
%
%      H = NOTE_GUI returns the handle to a new NOTE_GUI or the handle to
%      the existing singleton*.
%
%      NOTE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NOTE_GUI.M with the given input arguments.
%
%      NOTE_GUI('Property','Value',...) creates a new NOTE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Note_Gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Note_Gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Note_Gui

% Last Modified by GUIDE v2.5 22-Dec-2016 11:59:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Note_Gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Note_Gui_OutputFcn, ...
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


% --- Executes just before Note_Gui is made visible.
function Note_Gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Note_Gui (see VARARGIN)

% Choose default command line output for Note_Gui
handles.output = hObject;
input = varargin{1};
setappdata(0,'entry_note_text', input.note);
setappdata(0,'entry_note_status', input.status);

set(handles.notes, 'String', input.note);
array = get(handles.status, 'String');
index = 1;
for i=1:length(array)
    if strcmpi(array{i},input.status)
        index = i;
    end
end
set(handles.status, 'Value', index);
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)
% hObject    handle to Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.status, 'Value');
text = get(handles.notes, 'String');
if isempty(text) && index == 1
    return
end
array = get(handles.status, 'String');
status = array{index};
if ~isempty(text)
    note = sprintf('%s', text(1, :));
    for i=2:size(text, 1)
        note = sprintf('%s\n%s', note, text(i, :));
    end
else
    note = '';
end
setappdata(0,'entry_note_text', note);
setappdata(0,'entry_note_status', status);
Cancel_Callback(hObject, eventdata, handles);

% UIWAIT makes Note_Gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Note_Gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function notes_Callback(hObject, eventdata, handles)
% hObject    handle to notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notes as text
%        str2double(get(hObject,'String')) returns contents of notes as a double


% --- Executes during object creation, after setting all properties.
function notes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes on selection change in status.
function status_Callback(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns status contents as cell array
%        contents{get(hObject,'Value')} returns selected item from status


% --- Executes during object creation, after setting all properties.
function status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

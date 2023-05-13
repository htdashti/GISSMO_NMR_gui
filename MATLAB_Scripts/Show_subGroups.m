function varargout = Show_subGroups(varargin)
% SHOW_SUBGROUPS MATLAB code for Show_subGroups.fig
%      SHOW_SUBGROUPS, by itself, creates a new SHOW_SUBGROUPS or raises the existing
%      singleton*.
%
%      H = SHOW_SUBGROUPS returns the handle to a new SHOW_SUBGROUPS or the handle to
%      the existing singleton*.
%
%      SHOW_SUBGROUPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOW_SUBGROUPS.M with the given input arguments.
%
%      SHOW_SUBGROUPS('Property','Value',...) creates a new SHOW_SUBGROUPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Show_subGroups_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Show_subGroups_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Show_subGroups

% Last Modified by GUIDE v2.5 11-Jul-2016 10:51:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Show_subGroups_OpeningFcn, ...
                   'gui_OutputFcn',  @Show_subGroups_OutputFcn, ...
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


% --- Executes just before Show_subGroups is made visible.
function Show_subGroups_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Show_subGroups (see VARARGIN)

% Choose default command line output for Show_subGroups
handles.output = hObject;
Text = {};
Entry = varargin{1};

for i=1:length(Entry.coupling_matrix)
    if ~strcmp(Entry.coupling_matrix(i).label, 'merged')
        Text{end+1} = sprintf('atoms in sub matrix (%d):', Entry.coupling_matrix(i).index-1);
        for j=1:length(Entry.coupling_matrix(i).spin_names)
            Text{end+1} = sprintf('     %s', Entry.coupling_matrix(i).spin_names{j});
        end
    end
end
set(handles.edit1, 'String', Text);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Show_subGroups wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Show_subGroups_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
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

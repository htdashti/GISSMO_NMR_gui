function varargout = Split_matrix(varargin)
% SPLIT_MATRIX MATLAB code for Split_matrix.fig
%      SPLIT_MATRIX, by itself, creates a new SPLIT_MATRIX or raises the existing
%      singleton*.
%
%      H = SPLIT_MATRIX returns the handle to a new SPLIT_MATRIX or the handle to
%      the existing singleton*.
%
%      SPLIT_MATRIX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPLIT_MATRIX.M with the given input arguments.
%
%      SPLIT_MATRIX('Property','Value',...) creates a new SPLIT_MATRIX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Split_matrix_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Split_matrix_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Split_matrix

% Last Modified by GUIDE v2.5 11-Jul-2016 10:52:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Split_matrix_OpeningFcn, ...
                   'gui_OutputFcn',  @Split_matrix_OutputFcn, ...
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


% --- Executes just before Split_matrix is made visible.
function Split_matrix_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Split_matrix (see VARARGIN)

% Choose default command line output for Split_matrix
handles.output = hObject;
handles.number_of_subMatrices = varargin{1};
handles.atom_names = varargin{2};
setappdata(0,'submatrices',cell(0));
% Update handles structure
guidata(hObject, handles);
init_uitable(hObject, eventdata, handles, varargin)

% UIWAIT makes Split_matrix wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function init_uitable(hObject, eventdata, handles, varargin)
atom_names = handles.atom_names;
data = cell(length(atom_names), 2);
for i=1:length(atom_names)
    data{i, 1} = atom_names{i};
    data{i, 2} = 'choose';
end
number_of_subMatrices = handles.number_of_subMatrices;
groups = {'choose'};
for i=1:number_of_subMatrices
    groups{end+1} = sprintf('subMatrix(%d)', i);
end
handles.groups = groups;
columnname = {'atom name','sub matrix id'};
columnformat = {'char',groups};
set(handles.uitable1, 'Data', data,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnEditable', [false true],...
            'RowName',[]);
guidata(hObject, handles);
        


% --- Outputs from this function are returned to the command line.
function varargout = Split_matrix_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Split_matrix.
function Split_matrix_Callback(hObject, eventdata, handles)
% hObject    handle to Split_matrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitable1, 'data');
number_of_subMatrices = handles.number_of_subMatrices;
groups = handles.groups;
submatrices = cell(number_of_subMatrices, 1);
for i=1:size(data, 1)
    if strcmp(data{i, 2}, 'choose')
        errordlg(sprintf('need to assign atom %s to a sub matrix', data{i, 1}))
        return
    else
        for j=1:length(groups)
            if strcmp(data{i, 2}, sprintf('subMatrix(%d)', j))
                submatrices{j} = [submatrices{j};i];
                continue
            end
        end
    end
end
setappdata(0,'submatrices',submatrices);
close(handles.figure1);



% --- Executes on button press in Close.
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);
%delete(hObject);


% --- Executes on key press with focus on Close and none of its controls.
function Close_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Close (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

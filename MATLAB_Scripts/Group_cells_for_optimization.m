function varargout = Group_cells_for_optimization(varargin)
% GROUP_CELLS_FOR_OPTIMIZATION MATLAB code for Group_cells_for_optimization.fig
%      GROUP_CELLS_FOR_OPTIMIZATION, by itself, creates a new GROUP_CELLS_FOR_OPTIMIZATION or raises the existing
%      singleton*.
%
%      H = GROUP_CELLS_FOR_OPTIMIZATION returns the handle to a new GROUP_CELLS_FOR_OPTIMIZATION or the handle to
%      the existing singleton*.
%
%      GROUP_CELLS_FOR_OPTIMIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GROUP_CELLS_FOR_OPTIMIZATION.M with the given input arguments.
%
%      GROUP_CELLS_FOR_OPTIMIZATION('Property','Value',...) creates a new GROUP_CELLS_FOR_OPTIMIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Group_cells_for_optimization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Group_cells_for_optimization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Group_cells_for_optimization

% Last Modified by GUIDE v2.5 27-Apr-2017 09:41:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Group_cells_for_optimization_OpeningFcn, ...
                   'gui_OutputFcn',  @Group_cells_for_optimization_OutputFcn, ...
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


% --- Executes just before Group_cells_for_optimization is made visible.
function Group_cells_for_optimization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Group_cells_for_optimization (see VARARGIN)

% Choose default command line output for Group_cells_for_optimization
handles.output = hObject;
handles.Indices = varargin{1};
handles.atom_names = varargin{2};
setappdata(0,'optimization_grouped_indices',cell(0));
% Update handles structure
guidata(hObject, handles);
Draw_matrices(hObject, eventdata, handles, varargin);


function Draw_matrices(hObject, eventdata, handles, varargin)
atom_names = handles.atom_names;
Indices = handles.Indices;

data = cell(size(Indices, 1), 2);

for i=1:size(Indices, 1)
    data{i, 1} = sprintf('%s-%s', atom_names{Indices(i, 1)}, atom_names{Indices(i, 2)});
    data{i, 2} = 'choose';
end
number_of_subMatrices = size(Indices, 1);
groups = {'choose'};
for i=1:number_of_subMatrices
    groups{end+1} = sprintf('Group(%d)', i);
end
handles.groups = groups;
columnname = {'cell spin names','group id'};
columnformat = {'char',groups};
set(handles.uitable1, 'Data', data,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnEditable', [false true],...
            'RowName',[]);
set(handles.automated_grouping, 'Value', 0)
guidata(hObject, handles);

% UIWAIT makes Group_cells_for_optimization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Group_cells_for_optimization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function automated_grouping_Callback(hObject, eventdata, handles)
data = get(handles.uitable1, 'Data');
if get(handles.automated_grouping, 'Value') == 1
    for i=1:size(data, 1)
        data{i, 2} = 'Group(1)';
    end
    set(handles.uitable1, 'Data', data);
else
    for i=1:size(data, 1)
        data{i, 2} = 'choose';
    end
    set(handles.uitable1, 'Data', data);
end
guidata(hObject, handles);
drawnow;
% --- Executes on button press in OK_pushbutton.
function OK_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OK_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitable1, 'Data');
for i=1:size(data, 1)
    if strcmp(data{i, 2}, 'choose')
        errordlg(sprintf('need to assign atom %s to a group', data{i, 1}))
        return
    else
        data{i, 2} = strrep(data{i, 2}, 'Group(', '');
        data{i, 2} = strrep(data{i, 2}, ')', '');
        data{i, 2} = str2double(data{i, 2});
    end
end
out = cell2mat(data(:, 2));
setappdata(0,'optimization_grouped_indices',out);
close(handles.figure1);

% --- Executes on button press in Cancel_pushbutton.
function Cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1)
%delete(hObject);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in automated_grouping.

% hObject    handle to automated_grouping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of automated_grouping

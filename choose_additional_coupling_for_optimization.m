function varargout = choose_additional_coupling_for_optimization(varargin)
% CHOOSE_ADDITIONAL_COUPLING_FOR_OPTIMIZATION MATLAB code for choose_additional_coupling_for_optimization.fig
%      CHOOSE_ADDITIONAL_COUPLING_FOR_OPTIMIZATION, by itself, creates a new CHOOSE_ADDITIONAL_COUPLING_FOR_OPTIMIZATION or raises the existing
%      singleton*.
%
%      H = CHOOSE_ADDITIONAL_COUPLING_FOR_OPTIMIZATION returns the handle to a new CHOOSE_ADDITIONAL_COUPLING_FOR_OPTIMIZATION or the handle to
%      the existing singleton*.
%
%      CHOOSE_ADDITIONAL_COUPLING_FOR_OPTIMIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSE_ADDITIONAL_COUPLING_FOR_OPTIMIZATION.M with the given input arguments.
%
%      CHOOSE_ADDITIONAL_COUPLING_FOR_OPTIMIZATION('Property','Value',...) creates a new CHOOSE_ADDITIONAL_COUPLING_FOR_OPTIMIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before choose_additional_coupling_for_optimization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to choose_additional_coupling_for_optimization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help choose_additional_coupling_for_optimization

% Last Modified by GUIDE v2.5 09-Feb-2017 12:36:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @choose_additional_coupling_for_optimization_OpeningFcn, ...
                   'gui_OutputFcn',  @choose_additional_coupling_for_optimization_OutputFcn, ...
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


% --- Executes just before choose_additional_coupling_for_optimization is made visible.
function choose_additional_coupling_for_optimization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to choose_additional_coupling_for_optimization (see VARARGIN)

% Choose default command line output for choose_additional_coupling_for_optimization
handles.output = hObject;
handles.in_processing_info = varargin{1};
% Update handles structure
guidata(hObject, handles);
init(hObject, eventdata, handles);
% UIWAIT makes choose_additional_coupling_for_optimization wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function init(hObject, eventdata, handles)
handles = guidata(hObject);
in_processing_info = handles.in_processing_info;
additional_coupling_matrix = in_processing_info.additional_couplings_groups;
Num_spin_groups = length(unique(additional_coupling_matrix(:, 3)));
Num_coupling_groups = length(unique(additional_coupling_matrix(:, 4)));

data = cell(1, 5);
data_row_counter = 0;
for s_g_iter=1:Num_spin_groups
    for c_g_iter=1:Num_coupling_groups
        matrix_indices = find(additional_coupling_matrix(:, 3) == s_g_iter & additional_coupling_matrix(:, 4) == c_g_iter);
        if isempty(matrix_indices)
            continue
        end
        indices = additional_coupling_matrix(matrix_indices, 1);
        atoms_names = in_processing_info.spin_names(indices);
        atom_names_2_show = atoms_names{1};
        for i=2:length(atoms_names)
            atom_names_2_show = sprintf('%s,%s', atom_names_2_show, atoms_names{i});
        end
        coupling_constant = additional_coupling_matrix(matrix_indices(1), 2);
        data_row_counter = data_row_counter+1;
        data{data_row_counter, 1} = atom_names_2_show;
        data{data_row_counter, 2} = coupling_constant;
        data{data_row_counter, 3} = sprintf('group(%d)', s_g_iter);
        data{data_row_counter, 4} = sprintf('group(%d)', c_g_iter);
        data{data_row_counter, 5} = true;
        data{data_row_counter, 6} = sprintf('group(%d)', data_row_counter);
    end
end

groups_name = cell(1, size(data, 1));
for i=1:size(data, 1)
    groups_name{1, i} = sprintf('group(%d)', i);
end

set(handles.uitable1, 'Data', data, 'ColumnEditable', [false, false, false, false, true, true], 'ColumnFormat',{'char', 'numeric', 'char', 'char', 'logical', groups_name});
setappdata(0, 'selected_add_coupling_groups', []);


function Ok_Callback(hObject, eventdata, handles)
data = get(handles.uitable1, 'Data');
selected_groups = [];
for i=1:size(data, 1)
    if data{i, 5}
        s_g_index = textscan(data{i, 3}, 'group(%d)');
        s_g_index = s_g_index{1};
        c_g_index = textscan(data{i, 4}, 'group(%d)');
        c_g_index = c_g_index{1};
        same_group = textscan(data{i, 6}, 'group(%d)');
        same_group = same_group{1};
        selected_groups = [selected_groups; [s_g_index, c_g_index, same_group]];
    end
end
setappdata(0, 'selected_add_coupling_groups', selected_groups);
Cancel_Callback(hObject, eventdata, handles)

function Cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);




% --- Outputs from this function are returned to the command line.
function varargout = choose_additional_coupling_for_optimization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

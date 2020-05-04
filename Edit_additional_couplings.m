function varargout = Edit_additional_couplings(varargin)
% EDIT_ADDITIONAL_COUPLINGS MATLAB code for Edit_additional_couplings.fig
%      EDIT_ADDITIONAL_COUPLINGS, by itself, creates a new EDIT_ADDITIONAL_COUPLINGS or raises the existing
%      singleton*.
%
%      H = EDIT_ADDITIONAL_COUPLINGS returns the handle to a new EDIT_ADDITIONAL_COUPLINGS or the handle to
%      the existing singleton*.
%
%      EDIT_ADDITIONAL_COUPLINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDIT_ADDITIONAL_COUPLINGS.M with the given input arguments.
%
%      EDIT_ADDITIONAL_COUPLINGS('Property','Value',...) creates a new EDIT_ADDITIONAL_COUPLINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Edit_additional_couplings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Edit_additional_couplings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Edit_additional_couplings

% Last Modified by GUIDE v2.5 11-Oct-2016 11:42:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Edit_additional_couplings_OpeningFcn, ...
                   'gui_OutputFcn',  @Edit_additional_couplings_OutputFcn, ...
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


% --- Executes just before Edit_additional_couplings is made visible.
function Edit_additional_couplings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Edit_additional_couplings (see VARARGIN)

% Choose default command line output for Edit_additional_couplings
handles.output = hObject;
input = varargin{1};
handles.atom_names = input.atom_names ;
handles.additional_coupling = input.additional_coupling;

% Update handles structure
guidata(hObject, handles);
init(hObject, eventdata, handles);
% UIWAIT makes Edit_additional_couplings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function init(hObject, eventdata, handles)
handles = guidata(hObject);
spin_names = handles.atom_names;
additional_coupling_matrix = handles.additional_coupling;


Num_spin_groups = length(unique(additional_coupling_matrix(:, 3)));
Num_coupling_groups = length(unique(additional_coupling_matrix(:, 4)));

data = cell(1, 3);
data_row_counter = 0;
for s_g_iter=1:Num_spin_groups
    for c_g_iter=1:Num_coupling_groups
        matrix_indices = find(additional_coupling_matrix(:, 3) == s_g_iter & additional_coupling_matrix(:, 4) == c_g_iter);
        if isempty(matrix_indices)
            continue
        end
        indices = additional_coupling_matrix(matrix_indices, 1);
        atoms_names = spin_names(indices);
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
    end
end
set(handles.uitable1, 'data', data, 'ColumnEditable', [false, true, false, false], 'ColumnName', {'spin names', 'coupling', 'spin group ID', 'coupling group ID'});

setappdata(0,'edited_additional_coeff',additional_coupling_matrix);

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Edit_additional_couplings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)
% hObject    handle to Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updated_additional_coupling = handles.additional_coupling;

data_spins = get(handles.uitable1, 'Data');
for i=1:size(data_spins, 1)
    spin_group_id = textscan(data_spins{i, 3}, 'group(%d)');
    spin_group_id = spin_group_id{1};
    
    coupling_group_id = textscan(data_spins{i, 4}, 'group(%d)');
    coupling_group_id = coupling_group_id{1};
    indices = updated_additional_coupling(:, 3) == spin_group_id & updated_additional_coupling(:, 4) == coupling_group_id;
    updated_additional_coupling(indices, 2) = data_spins{i, 2};
end

setappdata(0,'edited_additional_coeff',updated_additional_coupling);
close(handles.figure1);



function num_coeff_Callback(hObject, eventdata, handles)
% hObject    handle to num_coeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_coeff as text
%        str2double(get(hObject,'String')) returns contents of num_coeff as a double


% --- Executes during object creation, after setting all properties.
function num_coeff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_coeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Close.
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

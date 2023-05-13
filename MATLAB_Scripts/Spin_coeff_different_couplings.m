function varargout = Spin_coeff_different_couplings(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Spin_coeff_different_couplings_OpeningFcn, ...
                   'gui_OutputFcn',  @Spin_coeff_different_couplings_OutputFcn, ...
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


% --- Executes just before Spin_coeff_different_couplings is made visible.
function Spin_coeff_different_couplings_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for Spin_coeff_different_couplings
handles.output = hObject;
setappdata(0,'Additional_coupling_table',[]);
handles.atom_names = varargin{1};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Spin_coeff_different_couplings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Spin_coeff_different_couplings_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;






% --- Executes on button press in create.
function create_Callback(hObject, eventdata, handles)
Num_groups = str2double(get(handles.Num_groups_spins, 'String'));
Num_additional_couplings = str2double(get(handles.Num_coeff, 'String'));
atom_names = handles.atom_names;
groups_name = cell(1, Num_groups+1);
groups_name{1} = 'select';
for i=1:Num_groups
    groups_name{i+1} = sprintf('group(%d)', i);
end
% atom names table
data = cell(length(atom_names), 2);
for i=1:length(atom_names)
    data{i, 1} = atom_names{i};
    data{i, 2} = 'select';
end
ColumnName = {'Spin names','Group ID'}; % 'ColumnName',
Editable = [false, true]; % 'ColumnEditable',[false true true]
set(handles.uitable1, 'Data', data,  'ColumnName',ColumnName, 'ColumnEditable', Editable, 'ColumnFormat',{'char', groups_name});
set(handles.uitable1, 'Visible', 'On');
set(handles.text5, 'Visible', 'On');

% coeffs
data = cell(Num_additional_couplings, 2);
for i=1:size(data, 1)
    data{i, 1} = '';
    data{i, 2} = 'select';
end
ColumnName = {'Coupling constant','Group ID'}; % 'ColumnName',
Editable = [true, true]; % 'ColumnEditable',[false true true]
set(handles.uitable2, 'Data', data,  'ColumnName',ColumnName, 'ColumnEditable', Editable, 'ColumnFormat',{'char', groups_name});
set(handles.uitable2, 'Visible', 'On');
set(handles.text6, 'Visible', 'On');
handles.Num_groups = Num_groups;
guidata(hObject, handles);


% --- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)

data_spins = get(handles.uitable1, 'data');

Num_groups = handles.Num_groups;
spins_groups = cell(Num_groups, 1);
for s_g_iter=1:Num_groups
    spin_indices = find(strcmp(data_spins(:, 2), sprintf('group(%d)', s_g_iter)) == 1);
    spins_groups{s_g_iter} = spin_indices;
end

data_coupling = get(handles.uitable2, 'data');
for i=1:size(data_coupling, 1)
    if strcmp(data_coupling{i, 2}, 'select') || isnan(str2double(data_coupling{i, 1}))
        errordlg('error in "Additional couplings" matrix:you need to assign a number to the additional coupling and assign the coupling to a spin group!')
        return
    end
end

for i=1:size(data_coupling, 1)
    if nnz(strcmp(data_coupling(:, 2), 'select')) ~= 0
        msgbox('please assign every coupling constant to a group of spins');
        uiwait(gcf);
        return
    end
end
Additional_coupling = [];
for i=1:size(data_coupling, 1)
    assigned_group = data_coupling{i, 2};
    for j=1:length(spins_groups)
        if strcmp(assigned_group,sprintf('group(%d)', j))
            for k=1:length(spins_groups{j})
                % index ccoupling group_index coupling_index
                Additional_coupling = [Additional_coupling; [spins_groups{j}(k), str2double(data_coupling{i, 1}), j, i]];
            end
        end
    end
end
setappdata(0,'Additional_coupling_table',Additional_coupling);
Cancel_Callback(hObject, eventdata, handles)

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);

function Num_groups_spins_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function Num_groups_spins_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Num_coeff_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function Num_coeff_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

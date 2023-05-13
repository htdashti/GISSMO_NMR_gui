function varargout = Merge_additional_couplings(varargin)
% MERGE_ADDITIONAL_COUPLINGS MATLAB code for Merge_additional_couplings.fig
%      MERGE_ADDITIONAL_COUPLINGS, by itself, creates a new MERGE_ADDITIONAL_COUPLINGS or raises the existing
%      singleton*.
%
%      H = MERGE_ADDITIONAL_COUPLINGS returns the handle to a new MERGE_ADDITIONAL_COUPLINGS or the handle to
%      the existing singleton*.
%
%      MERGE_ADDITIONAL_COUPLINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MERGE_ADDITIONAL_COUPLINGS.M with the given input arguments.
%
%      MERGE_ADDITIONAL_COUPLINGS('Property','Value',...) creates a new MERGE_ADDITIONAL_COUPLINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Merge_additional_couplings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Merge_additional_couplings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Merge_additional_couplings

% Last Modified by GUIDE v2.5 24-Feb-2017 14:42:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Merge_additional_couplings_OpeningFcn, ...
                   'gui_OutputFcn',  @Merge_additional_couplings_OutputFcn, ...
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


% --- Executes just before Merge_additional_couplings is made visible.
function Merge_additional_couplings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Merge_additional_couplings (see VARARGIN)

% Choose default command line output for Merge_additional_couplings
handles.output = hObject;
input = varargin{1};
handles.merged_spin_names = input.merged_spin_names;
handles.to_be_merged_additional_couplints = input.to_be_merged_additional_couplints;
% Update handles structure
guidata(hObject, handles);
init(hObject, eventdata, handles)
% UIWAIT makes Merge_additional_couplings wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function init(hObject, eventdata, handles)
handles = guidata(hObject);
merged_spin_names = reshape(handles.merged_spin_names, 1, length(handles.merged_spin_names));
merged_spin_names = ['discard', merged_spin_names, 'not listed'];
to_be_merged_additional_couplints = handles.to_be_merged_additional_couplints;
groups_spin_names = {};
data_counter = 0;
for i=1:length(to_be_merged_additional_couplints)
    grouped = to_be_merged_additional_couplints(i).grouped;
    spin_names = to_be_merged_additional_couplints(i).spin_names;
    unique_spin_groups = unique(grouped(:, 3));
    unique_coupling_groups = unique(grouped(:, 4));
    for j=1:length(unique_spin_groups)
        for k=1:length(unique_coupling_groups)
            indices = grouped(:, 3) == unique_spin_groups(j) & grouped(:, 4) == unique_coupling_groups(k);
            spin_indices = grouped(indices, 1);
            if isempty(spin_indices)
                continue
            end
            current_spin_names = spin_names(spin_indices);
            groups_spin_names{end+1} = current_spin_names;
            to_show_spin_names = current_spin_names{1};
            for l=2:length(current_spin_names)
                to_show_spin_names  = sprintf('%s,%s', to_show_spin_names, current_spin_names{l});
            end
            coupling = grouped(indices, 2);
            coupling = coupling(1);
            data_counter = data_counter+1;
            data{data_counter, 1} = to_show_spin_names;
            data{data_counter, 2} = coupling;
            data{data_counter, 3} = 'discard';
        end
    end
end
handles.groups_spin_names = groups_spin_names;
set(handles.uitable1, 'Data', data, 'ColumnFormat', {'char', 'numeric', merged_spin_names}, 'ColumnEditable', [false, false, true]);
output.data = data;
output.table_out = [];
output.note = {};
setappdata(0, 'bring_additional_coupling_2merged', output);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Merge_additional_couplings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
merged_spin_names = handles.merged_spin_names;
data = get(handles.uitable1, 'Data');
assigned = [];
output.note = {};
for i=1:size(data, 1)
    if strcmp(data{i, 3}, 'not listed')
        input.data = data;
        input.index = i;
        get_non_hydrigen_add_coupling_info(input);
        uiwait(gcf);
        note = getappdata(0, 'non_hyd_tag');
        output.note{end+1} = sprintf('spin name(s):"%s", coupling of "%f" with "%s"', data{i, 1}, data{i, 2}, note);
    else
        if ~strcmp(data{i, 3}, 'discard')
            to_spin_names = handles.groups_spin_names{i};
            from_spin_name = data{i, 3};
            to_indices = [];
            from_index = [];
            for j=1:length(to_spin_names)
                index = find(strcmp(merged_spin_names, to_spin_names{j}));
                to_indices = [to_indices; index];
            end
            from_index = find(strcmp(merged_spin_names, from_spin_name));
            coupling = data{i, 2};
            assigned = [assigned; [to_indices, from_index.*ones(size(to_indices)), coupling.*ones(size(to_indices))]];
        end
    end
end
for i=1:size(assigned, 1)
    if assigned(i, 1) > assigned(i, 2)
        temp = assigned(i, 1);
        assigned(i, 1) = assigned(i, 2);
        assigned(i, 2) = temp;
    end
end
merged_assigned = {};
merged_counter = 0;
seen = false(size(assigned, 1), 1);
for i=1:size(assigned, 1)
    if ~seen(i)
        merged_counter = merged_counter+1;
        merged_assigned{merged_counter, 1} = assigned(i, 1);
        merged_assigned{merged_counter, 2} = assigned(i, 2);
        merged_assigned{merged_counter, 3} = assigned(i, 3);
        for j=i+1:size(assigned, 1)
            if ~seen(j) && assigned(i, 1) == assigned(j, 1) && assigned(i, 2) == assigned(j, 2)
                seen(j) = true;
                merged_assigned{merged_counter, 3} = [merged_assigned{merged_counter, 3}; assigned(j, 3)];
            end
        end
    end
end
table_out = zeros(size(merged_assigned));
for i=1:size(merged_assigned, 1)
    table_out(i, 1) = merged_assigned{i, 1};
    table_out(i, 2) = merged_assigned{i, 2};
    table_out(i, 3) = mean(merged_assigned{i, 3});
end
if (isempty(table_out) || nnz(table_out) == 0) && isempty(output.note)
    choice = questdlg({'You have not assigned the couplins to any spin (3rd column)', 'would you like to exit the merge process without assinging the couplings?'}, 'no additional coupling was assigned', 'Yes', 'No', 'No');
    if strcmp(choice, 'No')
        return
    end
end
if ~isempty(output.note)
    output.note{1} = sprintf('Non-hydrogen additional coupling;\n%s', output.note{1});
end
output.data = data;
output.table_out = table_out;
setappdata(0, 'bring_additional_coupling_2merged', output);
cancel_Callback(hObject, eventdata, handles)


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);

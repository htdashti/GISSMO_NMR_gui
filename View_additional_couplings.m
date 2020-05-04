function varargout = View_additional_couplings(varargin)
% VIEW_ADDITIONAL_COUPLINGS MATLAB code for View_additional_couplings.fig
%      VIEW_ADDITIONAL_COUPLINGS, by itself, creates a new VIEW_ADDITIONAL_COUPLINGS or raises the existing
%      singleton*.
%
%      H = VIEW_ADDITIONAL_COUPLINGS returns the handle to a new VIEW_ADDITIONAL_COUPLINGS or the handle to
%      the existing singleton*.
%
%      VIEW_ADDITIONAL_COUPLINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_ADDITIONAL_COUPLINGS.M with the given input arguments.
%
%      VIEW_ADDITIONAL_COUPLINGS('Property','Value',...) creates a new VIEW_ADDITIONAL_COUPLINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before View_additional_couplings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to View_additional_couplings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help View_additional_couplings

% Last Modified by GUIDE v2.5 01-Nov-2016 09:26:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @View_additional_couplings_OpeningFcn, ...
                   'gui_OutputFcn',  @View_additional_couplings_OutputFcn, ...
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


% --- Executes just before View_additional_couplings is made visible.
function View_additional_couplings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to View_additional_couplings (see VARARGIN)

% Choose default command line output for View_additional_couplings
handles.output = hObject;
input = varargin{1};
atom_names = input.atom_names;
additional_coupling = input.additional_coupling;
% Update handles structure
guidata(hObject, handles);
init(hObject, eventdata, handles, atom_names, additional_coupling) 
% UIWAIT makes View_additional_couplings wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function init(hObject, eventdata, handles, atom_names, additional_coupling)
additional_coupling_matrix = additional_coupling;
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
        atoms_names = atom_names(indices);
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

set(handles.uitable1, 'Data', data, 'ColumnName', {'spin names', 'coupling', 'spins group ID', 'couplings group ID'});

% --- Outputs from this function are returned to the command line.
function varargout = View_additional_couplings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Ok.
function Ok_Callback(hObject, eventdata, handles)
% hObject    handle to Ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

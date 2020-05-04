function varargout = GAUSSIAN_Select_Spins(varargin)
% GAUSSIAN_SELECT_SPINS MATLAB code for GAUSSIAN_Select_Spins.fig
%      GAUSSIAN_SELECT_SPINS, by itself, creates a new GAUSSIAN_SELECT_SPINS or raises the existing
%      singleton*.
%
%      H = GAUSSIAN_SELECT_SPINS returns the handle to a new GAUSSIAN_SELECT_SPINS or the handle to
%      the existing singleton*.
%
%      GAUSSIAN_SELECT_SPINS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAUSSIAN_SELECT_SPINS.M with the given input arguments.
%
%      GAUSSIAN_SELECT_SPINS('Property','Value',...) creates a new GAUSSIAN_SELECT_SPINS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GAUSSIAN_Select_Spins_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GAUSSIAN_Select_Spins_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GAUSSIAN_Select_Spins

% Last Modified by GUIDE v2.5 19-Sep-2016 12:52:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GAUSSIAN_Select_Spins_OpeningFcn, ...
                   'gui_OutputFcn',  @GAUSSIAN_Select_Spins_OutputFcn, ...
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


% --- Executes just before GAUSSIAN_Select_Spins is made visible.
function GAUSSIAN_Select_Spins_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GAUSSIAN_Select_Spins (see VARARGIN)

% Choose default command line output for GAUSSIAN_Select_Spins
handles.output = hObject;
data = varargin{1};
atoms = data.atoms;
Data = cell(length(atoms), 3);
for i=1:length(atoms)
    Data{i, 1} = atoms(i).Type;
    Data{i, 2} = atoms(i).CS;
    Data{i, 3} = false;
end
set(handles.uitable1, 'Data', Data, 'ColumnFormat', {'char', 'numeric', 'logical'}, 'ColumnEditable', [false, false, true]);
selection = true(size(Data, 1), 1);
setappdata(0,'selected_atoms', selection);

guidata(hObject, handles);

% UIWAIT makes GAUSSIAN_Select_Spins wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GAUSSIAN_Select_Spins_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Open_Mol_file.
function Open_Mol_file_Callback(hObject, eventdata, handles)
% hObject    handle to Open_Mol_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plot_a_mol_file

% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
data = get(handles.uitable1, 'Data');
selection = false(size(data, 1), 1);
for i=1:length(selection)
    selection(i) = data{i, 3};
end
setappdata(0,'selected_atoms', selection);
close(handles.figure1)


function cancel_Callback(hObject, eventdata, handles)
close(handles.figure1)

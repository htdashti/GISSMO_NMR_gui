function varargout = create_spin_matrix(varargin)
% CREATE_SPIN_MATRIX MATLAB code for create_spin_matrix.fig
%      CREATE_SPIN_MATRIX, by itself, creates a new CREATE_SPIN_MATRIX or raises the existing
%      singleton*.
%
%      H = CREATE_SPIN_MATRIX returns the handle to a new CREATE_SPIN_MATRIX or the handle to
%      the existing singleton*.
%
%      CREATE_SPIN_MATRIX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_SPIN_MATRIX.M with the given input arguments.
%
%      CREATE_SPIN_MATRIX('Property','Value',...) creates a new CREATE_SPIN_MATRIX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_spin_matrix_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_spin_matrix_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_spin_matrix

% Last Modified by GUIDE v2.5 20-Jan-2017 11:45:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_spin_matrix_OpeningFcn, ...
                   'gui_OutputFcn',  @create_spin_matrix_OutputFcn, ...
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


% --- Executes just before create_spin_matrix is made visible.
function create_spin_matrix_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_spin_matrix (see VARARGIN)

% Choose default command line output for create_spin_matrix
%coupling_matrix.spin_names = names;
%coupling_matrix.coupling_matrix = matrix;
%coupling_matrix.CS = diag(matrix);
        
handles.output = hObject;
setappdata(0,'create_spin_spin_names', []);
setappdata(0,'create_spin_coupling_matrix', []);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes create_spin_matrix wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = create_spin_matrix_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Number_of_spins_Callback(hObject, eventdata, handles)
% hObject    handle to Number_of_spins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Number_of_spins as text
%        str2double(get(hObject,'String')) returns contents of Number_of_spins as a double


% --- Executes during object creation, after setting all properties.
function Number_of_spins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Number_of_spins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Create.
function Create_Callback(hObject, eventdata, handles)
num_spins = str2double(get(handles.Number_of_spins, 'String'));
guidata(hObject, handles);
data_name = cell(num_spins, 1);
set(handles.Spin_names, 'Visible', 'On');
set(handles.spin_matrix_text, 'Visible', 'On');
set(handles.Spin_names, 'data', data_name, 'ColumnEditable', true);
data_spins = zeros(num_spins);
set(handles.spin_matrix, 'Visible', 'On');
set(handles.spin_names_text, 'Visible', 'On');
set(handles.spin_matrix, 'data', data_spins, 'ColumnEditable', true(1, num_spins));


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spin_names = get(handles.Spin_names, 'data');
spin_matrix = get(handles.spin_matrix, 'data');

setappdata(0,'create_spin_spin_names', spin_names);
setappdata(0,'create_spin_coupling_matrix', spin_matrix);

cancel_Callback(hObject, eventdata, handles);

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1)

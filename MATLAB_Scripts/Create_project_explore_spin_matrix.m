function varargout = Create_project_explore_spin_matrix(varargin)
% CREATE_PROJECT_EXPLORE_SPIN_MATRIX MATLAB code for Create_project_explore_spin_matrix.fig
%      CREATE_PROJECT_EXPLORE_SPIN_MATRIX, by itself, creates a new CREATE_PROJECT_EXPLORE_SPIN_MATRIX or raises the existing
%      singleton*.
%
%      H = CREATE_PROJECT_EXPLORE_SPIN_MATRIX returns the handle to a new CREATE_PROJECT_EXPLORE_SPIN_MATRIX or the handle to
%      the existing singleton*.
%
%      CREATE_PROJECT_EXPLORE_SPIN_MATRIX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_PROJECT_EXPLORE_SPIN_MATRIX.M with the given input arguments.
%
%      CREATE_PROJECT_EXPLORE_SPIN_MATRIX('Property','Value',...) creates a new CREATE_PROJECT_EXPLORE_SPIN_MATRIX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Create_project_explore_spin_matrix_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Create_project_explore_spin_matrix_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Create_project_explore_spin_matrix

% Last Modified by GUIDE v2.5 24-Mar-2017 11:32:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Create_project_explore_spin_matrix_OpeningFcn, ...
                   'gui_OutputFcn',  @Create_project_explore_spin_matrix_OutputFcn, ...
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


% --- Executes just before Create_project_explore_spin_matrix is made visible.
function Create_project_explore_spin_matrix_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Create_project_explore_spin_matrix (see VARARGIN)

% Choose default command line output for Create_project_explore_spin_matrix
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
setappdata(0, 'input_coupling_matrix', []);
init(hObject, eventdata, handles)

% UIWAIT makes Create_project_explore_spin_matrix wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function init(hObject, eventdata, handles)
set(handles.button_load, 'visible', 'off');
set(handles.text2, 'visible', 'off');
set(handles.edit_num_spins, 'visible', 'off');
set(handles.button_create_empty, 'visible', 'off');
set(handles.hint, 'String', 'Select file-type of the input file');





% --- Outputs from this function are returned to the command line.
function varargout = Create_project_explore_spin_matrix_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
init(hObject, eventdata, handles)
index = get(handles.popupmenu1,'Value');
switch index
    case 1
        init(hObject, eventdata, handles)
    case 2
        set(handles.hint, 'String', {'>the first row and the first column contain spin names', ...
                                        '>The diag of the matrix represent the chemical shift of the spins', ...
                                        '>example: ', ...
                                        'consider a spin-matrix with two spins (10, 11)', ...
                                        'The csv file should look like:', ...
                                        ',1a, 1b', '1a, 1.76, -14', '1b, -14, 1.79'});
        set(handles.button_load, 'Visible', 'On');
    case 3
        set(handles.hint, 'String', 'Open an xml file that is previously generated by GISSMO');
        set(handles.button_load, 'Visible', 'On');
    case 4
        set(handles.hint, 'String', {'>This option is considered to load spin-matrices generated using the nmrDB website.', ...
                                    '>Ouputs of this website is a compressed file that contains a .json file.', ...
                                    '>Load the json file.'});
        set(handles.button_load, 'Visible', 'On');
    case 5
        set(handles.hint, 'String', {'>This option is considered to parse and load output of the Gaussian software package.', ...
                                    '>After loading the file, you will be asked to provide a reference value for the chemical shielding of protons.', ...
                                    '>Load Gaussian output file.'});
        set(handles.button_load, 'Visible', 'On');
    case 6
        set(handles.hint, 'String', {'>Specify number of spins below, we will generate an empty spin matrix', ...
                                    '>You can modify the spin names and the coupling constants later.'});
        set(handles.text2, 'Visible', 'On');
        set(handles.edit_num_spins, 'Visible', 'On');
        %set(handles.button_create_empty, 'Visible', 'On');
end

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hint_Callback(hObject, eventdata, handles)
function hint_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_load.
function button_load_Callback(hObject, eventdata, handles)
[FileName,PathName,~] = uigetfile('*.*', 'Select a file');
if isnumeric(FileName)
    return
end
fpath = sprintf('%s/%s', PathName, FileName);
handles.fpath = fpath;
guidata(hObject, handles);

function button_create_empty_Callback(hObject, eventdata, handles)



% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
index = get(handles.popupmenu1,'Value');
switch index
    case 1
        errordlg('You need to select a file-type')
        return
    case 2 % csv
        if ~isfield(handles, 'fpath')
            errordlg('You need to load a file')
            return
        end
        [names, matrix] = Load_spin_matrix_csv(handles.fpath);
        coupling_matrix.spin_names = names;
        coupling_matrix.coupling_matrix = matrix;
        coupling_matrix.CS = diag(matrix);
    case 3 % xml
        if ~isfield(handles, 'fpath')
            errordlg('You need to load a file')
            return
        end
        Entry = xml_parser(handles.fpath);
        coupling_matrix = Entry.coupling_matrix;
    case 4 % nmrDB
        if ~isfield(handles, 'fpath')
            errordlg('You need to load a file')
            return
        end
        [names, matrix] = Load_spin_matrix_nmrdb_json(handles.fpath);
        coupling_matrix.spin_names = names;
        coupling_matrix.coupling_matrix = matrix;
        coupling_matrix.CS = diag(matrix);
    case 5 % Gaussian
        if ~isfield(handles, 'fpath')
            errordlg('You need to load a file')
            return
        end
        [Matrix, atoms] = Load_spin_matrix_gaussian(handles.fpath);
        if isempty(atoms) || isempty(Matrix)
            errordlg('Could not load the spin matrix')
            return
        end
        msgbox({'The chemical shields and coupling constants are loaded.', 'Please load the reference chemical shields file.'})
        uiwait(gcf);
        if isfield(handles, 'open_folder')
            data.open_folder = handles.open_folder;
        else
            data.open_folder = './';
        end
        data.atoms = atoms;
        GAUSSIAN_Reference(data);
        uiwait(gcf);
        shift = getappdata(0,'reference_shift');
        for i=1:length(atoms)
            atoms(i).CS = shift-atoms(i).CS;
            Matrix(i, i) = atoms(i).CS;
        end
        data.atoms = atoms;
        GAUSSIAN_Select_Spins(data);
        uiwait(gcf);        
        selection = getappdata(0,'selected_atoms');
        matrix = Matrix;
        matrix(~selection, :) = [];
        matrix(:, ~selection) = [];
        array = 1:length(atoms);
        array(~selection) = [];
        names = cell(length(array), 1);
        for i=1:length(array)
            names{i} = sprintf('%d', array(i));
        end
        coupling_matrix.spin_names = names;
        for i=1:size(matrix, 1)
            for j=i+1:size(matrix, 1)
                matrix(i, j) = matrix(j, i);
            end
        end
        coupling_matrix.coupling_matrix = matrix;
        coupling_matrix.CS = diag(matrix);
    case 6 % empty
        num_spins = str2double(get(handles.edit_num_spins, 'String'));
        if isnan(num_spins) || ~isnumeric(num_spins)
            errordlg('Number of spins should be a number!')
            return
        end
        matrix = zeros(num_spins);
        names = cell(num_spins, 1);
        for i=1:num_spins
            names{i} = sprintf('%d', i);
        end
        coupling_matrix.coupling_matrix = matrix;
        coupling_matrix.CS = diag(matrix);
        coupling_matrix.spin_names = names;
end
setappdata(0, 'input_coupling_matrix', coupling_matrix);
Cancel_Callback(hObject, eventdata, handles)

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);


function edit_num_spins_Callback(hObject, eventdata, handles)
% hObject    handle to edit_num_spins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_num_spins as text
%        str2double(get(hObject,'String')) returns contents of edit_num_spins as a double


% --- Executes during object creation, after setting all properties.
function edit_num_spins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_num_spins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% hObject    handle to button_create_empty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
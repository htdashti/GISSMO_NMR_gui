function varargout = GAUSSIAN_Reference(varargin)
% GAUSSIAN_REFERENCE MATLAB code for GAUSSIAN_Reference.fig
%      GAUSSIAN_REFERENCE, by itself, creates a new GAUSSIAN_REFERENCE or raises the existing
%      singleton*.
%
%      H = GAUSSIAN_REFERENCE returns the handle to a new GAUSSIAN_REFERENCE or the handle to
%      the existing singleton*.
%
%      GAUSSIAN_REFERENCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAUSSIAN_REFERENCE.M with the given input arguments.
%
%      GAUSSIAN_REFERENCE('Property','Value',...) creates a new GAUSSIAN_REFERENCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GAUSSIAN_Reference_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GAUSSIAN_Reference_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GAUSSIAN_Reference

% Last Modified by GUIDE v2.5 19-Sep-2016 11:24:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GAUSSIAN_Reference_OpeningFcn, ...
                   'gui_OutputFcn',  @GAUSSIAN_Reference_OutputFcn, ...
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


% --- Executes just before GAUSSIAN_Reference is made visible.
function GAUSSIAN_Reference_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GAUSSIAN_Reference (see VARARGIN)

% Choose default command line output for GAUSSIAN_Reference
handles.output = hObject;
data = varargin{1};
atoms = data.atoms;
select = true(length(atoms), 1);
for i=1:length(select)
    if ~strcmp(atoms(i).Type, 'H')
        select(i) = false;
    end
end
atoms = atoms(select);
setappdata(0,'reference_shift', 0);
open_folder = data.open_folder;

Data = cell(length(atoms), 2);
for i=1:length(atoms)
    Data{i, 1} = atoms(i).Type;
    Data{i, 2} = atoms(i).CS;
end
set(handles.uitable1, 'Data', Data);
handles.open_folder = open_folder;
handles.atoms = atoms;
handles.orig_atoms = atoms;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GAUSSIAN_Reference wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GAUSSIAN_Reference_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function sheild_refernce_Callback(hObject, eventdata, handles)
% hObject    handle to sheild_refernce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sheild_refernce as text
%        str2double(get(hObject,'String')) returns contents of sheild_refernce as a double


% --- Executes during object creation, after setting all properties.
function sheild_refernce_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sheild_refernce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Apply_number.
function Apply_number_Callback(hObject, eventdata, handles)
atoms = handles.orig_atoms;
shift = str2double(get(handles.sheild_refernce, 'String'));
Data = cell(length(atoms), 2);
for i=1:length(atoms)
    atoms(i).CS = shift-atoms(i).CS;
    Data{i, 1} = atoms(i).Type;
    Data{i, 2} = atoms(i).CS;
end
handles.atoms = atoms;
set(handles.uitable1, 'Data', Data);
guidata(hObject, handles);


function Load_a_file_Callback(hObject, eventdata, handles)

[FileName,PathName,~] = uigetfile(sprintf('%s/*.*', handles.open_folder), 'open a file');
fpath = sprintf('%s%s', PathName, FileName);
fin = fopen(fpath, 'r');
shield_loop = 0;
atoms = [];
NAtoms=0;

tline = fgetl(fin);
while ischar(tline)
    if shield_loop == 1
        if ~isempty(strfind(tline, 'Isotropic ='))
            content = strsplit(tline);
            atoms(str2double(content{2})).Type = content{3};
            atoms(str2double(content{2})).CS = str2double(content{6});
        end
    end
    if length(atoms) == NAtoms && NAtoms ~= 0
        break
    end
    if ~isempty(strfind(tline, 'SCF GIAO Magnetic shielding tensor (ppm):'))
        shield_loop = 1;
    end
    if length(tline)>= 8 && strcmp(tline(1:8), ' NAtoms=')
        content = strsplit(tline);
        NAtoms = str2double(content{3});
    end
    tline = fgetl(fin);
end
fclose(fin);
Sum = 0;
counter = 0;
for i=1:length(atoms)
    if strcmpi(atoms(i).Type, 'H')
        counter = counter+1;
        Sum = Sum+atoms(i).CS;
    end
end
avg = Sum/counter;
set(handles.field_reference_shield, 'String', sprintf('%.04f', avg));
guidata(hObject, handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
atoms = handles.orig_atoms;
shift = str2double(get(handles.field_reference_shield, 'String'));
Data = cell(length(atoms), 2);
for i=1:length(atoms)
    atoms(i).CS = shift-atoms(i).CS;
    Data{i, 1} = atoms(i).Type;
    Data{i, 2} = atoms(i).CS;
end
handles.atoms = atoms;
set(handles.uitable1, 'Data', Data);
guidata(hObject, handles);


% --- Executes on button press in Done.
function Done_Callback(hObject, eventdata, handles)
data = get(handles.uitable1, 'Data');
orig_atoms = handles.orig_atoms;
for i=1:size(data, 1)
    atoms_out(i).Type = data{i, 1};
    atoms_out(i).CS = data{i, 2};
end
shift = orig_atoms(1).CS+atoms_out(1).CS;
setappdata(0,'reference_shift', shift);
cancel_Callback(hObject, eventdata, handles)

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);
function field_reference_shield_Callback(hObject, eventdata, handles)
% hObject    handle to field_reference_shield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of field_reference_shield as text
%        str2double(get(hObject,'String')) returns contents of field_reference_shield as a double


% --- Executes during object creation, after setting all properties.
function field_reference_shield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to field_reference_shield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

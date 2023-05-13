function varargout = Spin_Coeff(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Spin_Coeff_OpeningFcn, ...
                   'gui_OutputFcn',  @Spin_Coeff_OutputFcn, ...
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


% --- Executes just before Spin_Coeff is made visible.
function Spin_Coeff_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Spin_Coeff (see VARARGIN)

% Choose default command line output for Spin_Coeff
handles.output = hObject;
setappdata(0,'spin_coeff_name',[]);
setappdata(0,'spin_coeff_array',[]);
handles.spin_names = varargin{1};
% Update handles structure
guidata(hObject, handles);
init(hObject, eventdata, handles);
% UIWAIT makes Spin_Coeff wait for user response (see UIRESUME)
% uiwait(handles.figure1);




function init(hObject, eventdata, handles)
global spin_index spin_coeffs


spin_names = handles.spin_names;
columnformat = {'char', 'logical'};
data = cell(length(spin_names), 2);
for i=1:length(spin_names)
    data{i, 1} = spin_names{i};
    data{i, 2} = false;
end

if ~isempty(spin_index)
    for i=1:length(spin_index)
        data{spin_index(i), 2} = true;
    end
end
set(handles.uitable2, 'data', data, 'ColumnFormat', columnformat);

if ~isempty(spin_coeffs)
    set(handles.Num_Coeff, 'String', sprintf('%d', length(spin_coeffs)));
    
    STR = 'coefficients for spins';
    for i=1:length(spin_index)
        STR = sprintf('%s %s', STR, spin_names{spin_index(i)});
    end
    set(handles.text4, 'String', STR);
    set(handles.text4, 'Visible', 'On');
    data = zeros(length(spin_coeffs), 1);
    for i=1:length(data)
        data(i) = spin_coeffs(i);
    end
    set(handles.uitable1, 'Data', data);
    set(handles.uitable1, 'Visible', 'On');
end
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Spin_Coeff_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in apply.
function apply_Callback(hObject, eventdata, handles)
% hObject    handle to apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_spins = get(handles.uitable2, 'Data');
selected_spin = {};
for i=1:size(data_spins, 1)
    if data_spins{i, 2}
        selected_spin{end+1} = data_spins{i, 1};
    end
end
setappdata(0,'spin_coeff_name',selected_spin);

data = get(handles.uitable1, 'Data');
setappdata(0,'spin_coeff_array',data);
close(handles.figure1);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


function Num_Coeff_Callback(hObject, eventdata, handles)
% hObject    handle to Num_Coeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Num_Coeff as text
%        str2double(get(hObject,'String')) returns contents of Num_Coeff as a double


% --- Executes during object creation, after setting all properties.
function Num_Coeff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Num_Coeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in create.
function create_Callback(hObject, eventdata, handles)
% hObject    handle to create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Num_Coeff = str2num(get(handles.Num_Coeff, 'String'));
data = zeros(Num_Coeff, 1);
set(handles.uitable1, 'Data', data);
set(handles.uitable1, 'Visible', 'On');
handles.Num_Coeff = Num_Coeff;
data_spins = get(handles.uitable2, 'data');
selected_spin = {};
for i=1:size(data_spins, 1)
    if data_spins{i, 2}
        selected_spin{end+1} = data_spins{i, 1};
    end
end
    
%selected_spin = Strings{val};
%setappdata(0,'spin_coeff_name',selected_spin);
STR = 'coefficients for spins';
for i=1:length(selected_spin)
    STR = sprintf('%s, %s', STR, selected_spin{i});
end
set(handles.text4, 'String', STR);
set(handles.text4, 'Visible', 'On');
handles.selected_spin  = selected_spin;
guidata(hObject, handles);

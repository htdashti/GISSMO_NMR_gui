function varargout = View_parameters(varargin)
% VIEW_PARAMETERS MATLAB code for View_parameters.fig
%      VIEW_PARAMETERS, by itself, creates a new VIEW_PARAMETERS or raises the existing
%      singleton*.
%
%      H = VIEW_PARAMETERS returns the handle to a new VIEW_PARAMETERS or the handle to
%      the existing singleton*.
%
%      VIEW_PARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_PARAMETERS.M with the given input arguments.
%
%      VIEW_PARAMETERS('Property','Value',...) creates a new VIEW_PARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before View_parameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to View_parameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help View_parameters

% Last Modified by GUIDE v2.5 25-Sep-2018 12:28:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @View_parameters_OpeningFcn, ...
                   'gui_OutputFcn',  @View_parameters_OutputFcn, ...
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


% --- Executes just before View_parameters is made visible.
function View_parameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to View_parameters (see VARARGIN)

% Choose default command line output for View_parameters
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
init_params(hObject, eventdata, handles)
% UIWAIT makes View_parameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function pushbutton_save_params_Callback(hObject, eventdata, handles)
[FileName,PathName,FilterIndex] = uiputfile('*.xml','Save parameters','GISSMO_parameters.xml');
if isnumeric(FileName)
    return
end
file_path = sprintf('%s/%s', PathName, FileName);
fout = fopen(file_path, 'w');
if fout<1
    uiwait(errordlg('Could not create the parameter file'));
    return
end
fprintf(fout, '<GISSMO_parameters>\n');
fprintf(fout, '\t<Bothner_By angle="%s"></Bothner_By>\n', get(handles.bothnerby_angle_text, 'String'));
fprintf(fout, '\t<RMSD_CS_range range="%s"></RMSD_CS_range>\n', get(handles.CS_range_text, 'String'));
fprintf(fout, '\t<AB_parameters>\n');
fprintf(fout, '\t\t<Strong_coupleing from="%s" to="%s" steps="%s"></Strong_coupleing>\n', ...
                                     get(handles.AB_strong_coupling_min_text, 'String'), ...
                                     get(handles.AB_strong_coupling_max_text, 'String'), ...
                                     get(handles.AB_strong_coupling_steps_text, 'String'));
fprintf(fout, '\t\t<Chemical_shifts from="%s" to="%s" steps="%s"></Chemical_shifts>\n', ...
                                     get(handles.AB_strong_cs_min_text, 'String'), ...
                                     get(handles.AB_strong_cs_max_text, 'String'), ...
                                     get(handles.AB_strong_cs_steps_text, 'String')); 
fprintf(fout, '\t\t<Max_allowed_delta_cs range="%s"></Max_allowed_delta_cs>\n', get(handles.AB_strong_max_allowed_text, 'String')); 
fprintf(fout, '\t</AB_parameters>\n');
fprintf(fout, '</GISSMO_parameters>');
fclose(fout);
uiwait(msgbox({'parameters saved to ', file_path}));


function pushbutton_load_Callback(hObject, eventdata, handles)
[FileName,PathName,FilterIndex] = uigetfile('*.xml','Save parameters','GISSMO_parameters.xml');
if isnumeric(FileName)
    return
end
file_path = sprintf('%s/%s', PathName, FileName);
fin = fopen(file_path, 'r');
try
    tline = fgetl(fin);
    while ischar(tline)
        if contains(tline, '<Bothner_By angle=')
            content = strsplit(tline, '"');
            set(handles.bothnerby_angle_text, 'String', content{2});
        end
        if contains(tline, '<RMSD_CS_range range=')
            content = strsplit(tline, '"');
            set(handles.CS_range_text, 'String', content{2});
        end
        if contains(tline, '<Strong_coupleing from')
            content = strsplit(tline, '"');
            set(handles.AB_strong_coupling_min_text, 'String', content{2});
            set(handles.AB_strong_coupling_max_text, 'String', content{4});
            set(handles.AB_strong_coupling_steps_text, 'String', content{6});
        end
        if contains(tline, '<Chemical_shifts from')
            content = strsplit(tline, '"');
            set(handles.AB_strong_cs_min_text, 'String', content{2});
            set(handles.AB_strong_cs_max_text, 'String', content{4});
            set(handles.AB_strong_cs_steps_text, 'String', content{6});
        end
        if contains(tline, '<Max_allowed_delta_cs')
            content = strsplit(tline, '"');
            set(handles.AB_strong_max_allowed_text, 'String', content{2});
        end
        tline = fgetl(fin);
    end
catch
    uiwait(errordlg('File format does not match with the GISSMO parameter file format'));
    return
end
fclose(fin);
drawnow
update_global_varibales(hObject, eventdata, handles)

function pushbutton_set_default_Callback(hObject, eventdata, handles)
% AB
set(handles.AB_strong_coupling_min_text, 'String', sprintf('%.01f', -10));
set(handles.AB_strong_coupling_max_text, 'String', sprintf('%.01f', -20));
set(handles.AB_strong_coupling_steps_text, 'String', sprintf('%.01f', -1));
set(handles.AB_strong_cs_min_text, 'String', sprintf('%.01f', 0));
set(handles.AB_strong_cs_max_text, 'String', sprintf('%.01f', 2));
set(handles.AB_strong_cs_steps_text, 'String', sprintf('%.02f', 0.5));
set(handles.AB_strong_max_allowed_text, 'String', sprintf('%.02f', 0.05));

% CS range
set(handles.CS_range_text, 'String', sprintf('%.02f', .1));
% bothner-by
set(handles.bothnerby_angle_text, 'String', sprintf('%.01f', 60));
drawnow
update_global_varibales(hObject, eventdata, handles)

function update_global_varibales(hObject, eventdata, handles)
global parameters_bothner_by parameters_CS_range parameters_AB

val = str2double(get(handles.bothnerby_angle_text, 'String'));
parameters_bothner_by.angle = val;
val = str2double(get(handles.CS_range_text, 'String'));
parameters_CS_range = val;
temp_parameters_AB.strong_coupling.domain.min = str2double(get(handles.AB_strong_coupling_min_text, 'String'));
temp_parameters_AB.strong_coupling.domain.max = str2double(get(handles.AB_strong_coupling_max_text, 'String'));
temp_parameters_AB.strong_coupling.steps = str2double(get(handles.AB_strong_coupling_steps_text, 'String'));
temp_parameters_AB.cs_explore.domain.min = str2double(get(handles.AB_strong_cs_min_text, 'String'));
temp_parameters_AB.cs_explore.domain.max = str2double(get(handles.AB_strong_cs_max_text, 'String'));
temp_parameters_AB.cs_explore.steps = str2double(get(handles.AB_strong_cs_steps_text, 'String'));
temp_parameters_AB.max_allowed_cs_displacement = str2double(get(handles.AB_strong_max_allowed_text, 'String'));

if isnan(temp_parameters_AB.strong_coupling.domain.min) || isnan(temp_parameters_AB.strong_coupling.domain.max) || isnan(temp_parameters_AB.strong_coupling.steps) || ...
        isnan(temp_parameters_AB.cs_explore.domain.min) || isnan(temp_parameters_AB.cs_explore.domain.max) || isnan(temp_parameters_AB.cs_explore.steps) || isnan(temp_parameters_AB.max_allowed_cs_displacement)
    errordlg('incorrect input')
    return
end
parameters_AB.strong_coupling.domain = [temp_parameters_AB.strong_coupling.domain.min, temp_parameters_AB.strong_coupling.domain.max];
parameters_AB.strong_coupling.steps = temp_parameters_AB.strong_coupling.steps;
parameters_AB.cs_explore.domain = [temp_parameters_AB.cs_explore.domain.min, temp_parameters_AB.cs_explore.domain.max];
parameters_AB.cs_explore.steps = temp_parameters_AB.cs_explore.steps;
parameters_AB.max_allowed_cs_displacement =  temp_parameters_AB.max_allowed_cs_displacement;
init_params(hObject, eventdata, handles)



function init_params(hObject, eventdata, handles)
global parameters_AB parameters_CS_range parameters_bothner_by
% AB
set(handles.AB_strong_coupling_min_text, 'String', sprintf('%.01f', (parameters_AB.strong_coupling.domain(1))));
set(handles.AB_strong_coupling_max_text, 'String', sprintf('%.01f', (parameters_AB.strong_coupling.domain(2))));
set(handles.AB_strong_coupling_steps_text, 'String', sprintf('%.01f', parameters_AB.strong_coupling.steps));
set(handles.AB_strong_cs_min_text, 'String', sprintf('%.01f', (parameters_AB.cs_explore.domain(1))));
set(handles.AB_strong_cs_max_text, 'String', sprintf('%.01f', (parameters_AB.cs_explore.domain(2))));
set(handles.AB_strong_cs_steps_text, 'String', sprintf('%.02f', parameters_AB.cs_explore.steps));
set(handles.AB_strong_max_allowed_text, 'String', sprintf('%.02f', parameters_AB.max_allowed_cs_displacement));

% CS range
set(handles.CS_range_text, 'String', sprintf('%.02f', parameters_CS_range));
% bothner-by
set(handles.bothnerby_angle_text, 'String', sprintf('%.01f', parameters_bothner_by.angle));


function removed_button_Callback(hObject, eventdata, handles)
global parameters_bothner_by

val = str2double(get(handles.bothnerby_angle_text, 'String'));
parameters_bothner_by.angle = val;
init_params(hObject, eventdata, handles)

function bothnerby_reset_button_Callback(hObject, eventdata, handles)
global parameters_bothner_by

parameters_bothner_by.angle = 60;
init_params(hObject, eventdata, handles)



function reset_CS_range_button_Callback(hObject, eventdata, handles)
global parameters_CS_range
parameters_CS_range = .1;
init_params(hObject, eventdata, handles)

function AB_opt_reset_button_Callback(hObject, eventdata, handles)
global parameters_AB
parameters_AB.strong_coupling.domain = [-10, -20];
parameters_AB.strong_coupling.steps = -1;
parameters_AB.cs_explore.domain = [0, 2];
parameters_AB.cs_explore.steps = 0.5;
parameters_AB.max_allowed_cs_displacement =  0.05;
init_params(hObject, eventdata, handles)


function apply_all_and_close_Callback(hObject, eventdata, handles)
update_global_varibales(hObject, eventdata, handles)
close(handles.figure1)

function reset_and_close_Callback(hObject, eventdata, handles)
pushbutton_set_default_Callback(hObject, eventdata, handles)


function varargout = View_parameters_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
function AB_strong_coupling_min_text_Callback(hObject, eventdata, handles)
function AB_strong_coupling_min_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function AB_strong_coupling_max_text_Callback(hObject, eventdata, handles)
function AB_strong_coupling_max_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function AB_strong_coupling_steps_text_Callback(hObject, eventdata, handles)
function AB_strong_coupling_steps_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function AB_strong_cs_min_text_Callback(hObject, eventdata, handles)
function AB_strong_cs_min_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function AB_strong_cs_max_text_Callback(hObject, eventdata, handles)
function AB_strong_cs_max_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function AB_strong_cs_steps_text_Callback(hObject, eventdata, handles)
function AB_strong_cs_steps_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function AB_strong_max_allowed_text_Callback(hObject, eventdata, handles)
function AB_strong_max_allowed_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CS_range_text_Callback(hObject, eventdata, handles)
function CS_range_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function bothnerby_angle_text_Callback(hObject, eventdata, handles)
function bothnerby_angle_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

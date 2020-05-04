function varargout = get_offsets(varargin)
% GET_OFFSETS MATLAB code for get_offsets.fig
%      GET_OFFSETS, by itself, creates a new GET_OFFSETS or raises the existing
%      singleton*.
%
%      H = GET_OFFSETS returns the handle to a new GET_OFFSETS or the handle to
%      the existing singleton*.
%
%      GET_OFFSETS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GET_OFFSETS.M with the given input arguments.
%
%      GET_OFFSETS('Property','Value',...) creates a new GET_OFFSETS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before get_offsets_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to get_offsets_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help get_offsets

% Last Modified by GUIDE v2.5 05-Aug-2016 10:15:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @get_offsets_OpeningFcn, ...
                   'gui_OutputFcn',  @get_offsets_OutputFcn, ...
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


% --- Executes just before get_offsets is made visible.
function get_offsets_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to get_offsets (see VARARGIN)

% Choose default command line output for get_offsets
handles.output = hObject;
handles.data = varargin{1};

guidata(hObject, handles);
apply_Callback(hObject, eventdata, handles)
% UIWAIT makes get_offsets wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = get_offsets_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ppm_Callback(hObject, eventdata, handles)
% hObject    handle to ppm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ppm as text
%        str2double(get(hObject,'String')) returns contents of ppm as a double


% --- Executes during object creation, after setting all properties.
function ppm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp_Callback(hObject, eventdata, handles)
% hObject    handle to amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp as text
%        str2double(get(hObject,'String')) returns contents of amp as a double


% --- Executes during object creation, after setting all properties.
function amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in apply.
function apply_Callback(hObject, eventdata, handles)
% hObject    handle to apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


ppm_offset = str2double(get(handles.ppm, 'String'));
amp_offset = str2double(get(handles.amp, 'String'));

axes(handles.axes1);
hold off
plot(handles.data.exp_roi_domain, handles.data.exp_roi_fid, 'b'); hold on
plot(handles.data.sim_roi_ppm+ppm_offset, handles.data.sim_roi_fid+amp_offset, 'r')
Min = min([min(handles.data.exp_roi_fid), min(handles.data.sim_roi_fid+amp_offset)]);
Max = max([max(handles.data.exp_roi_fid), max(handles.data.sim_roi_fid+amp_offset)]);
Dist = Max-Min;
ylim([Min-.1*Dist Max+.1*Dist]);
MIN = min([min(handles.data.sim_roi_ppm+ppm_offset), min(handles.data.exp_roi_domain)]);
MAX = max([max(handles.data.sim_roi_ppm+ppm_offset), max(handles.data.exp_roi_domain)]);
xlim([MIN MAX])
set(gca, 'xdir', 'reverse');
set(gca, 'ytick', []);
title({sprintf('%s(%s)', strrep(handles.data.name, '_', '-'), strrep(handles.data.ID, '_', '-')), 'red: simulated, blue: experimental'});




% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ppm_offset = str2double(get(handles.ppm, 'String'));
amp_offset = str2double(get(handles.amp, 'String'));

figure();
plot(handles.data.exp_roi_domain, handles.data.exp_roi_fid, 'b'); hold on
plot(handles.data.sim_roi_ppm+ppm_offset, handles.data.sim_roi_fid+amp_offset, 'r')
MIN = min([min(handles.data.sim_roi_ppm+ppm_offset), min(handles.data.exp_roi_domain)]);
MAX = max([max(handles.data.sim_roi_ppm+ppm_offset), max(handles.data.exp_roi_domain)]);
xlim([MIN MAX])
set(gca, 'xdir', 'reverse');
title({sprintf('%s(%s)', strrep(handles.data.name, '_', '-'), strrep(handles.data.ID, '_', '-')), 'red: simulated, blue: experimental'});

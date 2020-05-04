function varargout = get_indices_for_copyPaste_sub_matrices(varargin)
% GET_INDICES_FOR_COPYPASTE_SUB_MATRICES MATLAB code for get_indices_for_copyPaste_sub_matrices.fig
%      GET_INDICES_FOR_COPYPASTE_SUB_MATRICES, by itself, creates a new GET_INDICES_FOR_COPYPASTE_SUB_MATRICES or raises the existing
%      singleton*.
%
%      H = GET_INDICES_FOR_COPYPASTE_SUB_MATRICES returns the handle to a new GET_INDICES_FOR_COPYPASTE_SUB_MATRICES or the handle to
%      the existing singleton*.
%
%      GET_INDICES_FOR_COPYPASTE_SUB_MATRICES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GET_INDICES_FOR_COPYPASTE_SUB_MATRICES.M with the given input arguments.
%
%      GET_INDICES_FOR_COPYPASTE_SUB_MATRICES('Property','Value',...) creates a new GET_INDICES_FOR_COPYPASTE_SUB_MATRICES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before get_indices_for_copyPaste_sub_matrices_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to get_indices_for_copyPaste_sub_matrices_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help get_indices_for_copyPaste_sub_matrices

% Last Modified by GUIDE v2.5 07-Apr-2017 10:24:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @get_indices_for_copyPaste_sub_matrices_OpeningFcn, ...
                   'gui_OutputFcn',  @get_indices_for_copyPaste_sub_matrices_OutputFcn, ...
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


% --- Executes just before get_indices_for_copyPaste_sub_matrices is made visible.
function get_indices_for_copyPaste_sub_matrices_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to get_indices_for_copyPaste_sub_matrices (see VARARGIN)

% Choose default command line output for get_indices_for_copyPaste_sub_matrices
handles.output = hObject;
sub_matrices_info = varargin{1};
setappdata(0, 'cpSubMatrixindices', []);
% Update handles structure
guidata(hObject, handles);
init(sub_matrices_info, hObject, handles)
% UIWAIT makes get_indices_for_copyPaste_sub_matrices wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function init(sub_matrices_info, hObject, handles)
data =cell(length(sub_matrices_info), 2);
for i=1:size(data, 1)
    data{i, 1} = sprintf('sub matrix(%d)', i);
    spin_names = sub_matrices_info{i};
    data{i, 2} = '';
    for j=1:length(spin_names)
        if j == length(spin_names)
            data{i, 2} = sprintf('%s%s', data{i, 2}, spin_names{j});
        else
            data{i, 2} = sprintf('%s%s,', data{i, 2}, spin_names{j});
        end
    end
end
set(handles.uitable1, 'data', data, 'ColumnName', {'sub matrix indices', 'spin names'});
set(handles.popupmenu1, 'String', data(:, 1));
set(handles.popupmenu2, 'String', data(:, 1));


% --- Outputs from this function are returned to the command line.
function varargout = get_indices_for_copyPaste_sub_matrices_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function done_Callback(hObject, eventdata, handles)
invert_tag = get(handles.checkbox1, 'Value');
index_1 = get(handles.popupmenu1, 'Value');
index_2 = get(handles.popupmenu2, 'Value');
out = [index_1+1, index_2+1, invert_tag];
setappdata(0, 'cpSubMatrixindices', out);
cancel_Callback(hObject, eventdata, handles)

function cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);

function popupmenu1_Callback(hObject, eventdata, handles)
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu2_Callback(hObject, eventdata, handles)
function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function checkbox1_Callback(hObject, eventdata, handles)

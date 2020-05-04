function varargout = Merge_submatrices(varargin)
% MERGE_SUBMATRICES MATLAB code for Merge_submatrices.fig
%      MERGE_SUBMATRICES, by itself, creates a new MERGE_SUBMATRICES or raises the existing
%      singleton*.
%
%      H = MERGE_SUBMATRICES returns the handle to a new MERGE_SUBMATRICES or the handle to
%      the existing singleton*.
%
%      MERGE_SUBMATRICES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MERGE_SUBMATRICES.M with the given input arguments.
%
%      MERGE_SUBMATRICES('Property','Value',...) creates a new MERGE_SUBMATRICES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Merge_submatrices_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Merge_submatrices_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Merge_submatrices

% Last Modified by GUIDE v2.5 20-Mar-2017 09:28:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Merge_submatrices_OpeningFcn, ...
                   'gui_OutputFcn',  @Merge_submatrices_OutputFcn, ...
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


% --- Executes just before Merge_submatrices is made visible.
function Merge_submatrices_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Merge_submatrices (see VARARGIN)

% Choose default command line output for Merge_submatrices
handles.output = hObject;
inputs = varargin{1};
% Update handles structure
guidata(hObject, handles);
init(hObject, eventdata, handles, inputs)

% UIWAIT makes Merge_submatrices wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function init(hObject, eventdata, handles, inputs)

Min_PPM = min(inputs.experimental_data.domain);
Max_PPM = max(inputs.experimental_data.domain);
Entry = inputs.Entry;
ppm = (Min_PPM:(Max_PPM-Min_PPM)/(Entry.num_points-1):Max_PPM)';
Vectors = cell(length(Entry.coupling_matrix)-1, 1);
for i=2:length(Entry.coupling_matrix)
    c_spec = Entry.coupling_matrix(i).spectrum;
    L = interp1(c_spec(:, 1),c_spec(:, 2),ppm);
    L(isnan(L)) = 0;
    if isempty(L) || nnz(L) == 0
        errordlg('There was an error while merging. Please notify the developers!');
        return
    end
    Vectors{i-1} = L;
end
handles.experimental_data = inputs.experimental_data;
handles.Vectors = Vectors;
handles.PPM = ppm;
data = cell(length(Entry.coupling_matrix)-1, 2);
for i=1:size(data, 1)
    data{i, 1} = sprintf('Sub-matrix(%d)', i);
    data{i, 2} = 1;
end
set(handles.uitable1, 'Data', data, 'ColumnEditable', [false, true], 'ColumnName', {'  Sub-matrix  ', 'Scale factor'});
guidata(hObject, handles);
%preview_Callback(hObject, eventdata, handles);
%guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Merge_submatrices_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in preview.
function preview_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
data = get(handles.uitable1, 'Data');
scales = cell2mat(data(:, 2));
Vectors = handles.Vectors;
PPM = handles.PPM;
fid = zeros(size(PPM));
for i=1:length(scales)
    %figure, plot(PPM, Vectors{i}, 'b');  hold on; plot(PPM, scales(i).*Vectors{i}, 'r')
    fid = fid+scales(i).*Vectors{i};
end
%fid = fid./max(fid);
fid = Mean_zero_spectrum(fid);
axes(handles.axes1);
plot(handles.experimental_data.domain, handles.experimental_data.spectrum, 'b'); hold on;
plot(PPM, fid, 'r');
hold off
set(gca, 'xdir', 'reverse')
set(gca, 'YTick', []);
title('blue: experimental spectrum, red: merged simulated spectrum')
output.ppm = PPM;
output.fid = fid;
setappdata(0, 'scaled_merged_data', output);

% --- Executes on button press in Done.
function Done_Callback(hObject, eventdata, handles)
preview_Callback(hObject, eventdata, handles)
close(handles.figure1);

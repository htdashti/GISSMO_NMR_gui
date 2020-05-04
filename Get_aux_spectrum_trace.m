function varargout = Get_aux_spectrum_trace(varargin)
% GET_AUX_SPECTRUM_TRACE MATLAB code for Get_aux_spectrum_trace.fig
%      GET_AUX_SPECTRUM_TRACE, by itself, creates a new GET_AUX_SPECTRUM_TRACE or raises the existing
%      singleton*.
%
%      H = GET_AUX_SPECTRUM_TRACE returns the handle to a new GET_AUX_SPECTRUM_TRACE or the handle to
%      the existing singleton*.
%
%      GET_AUX_SPECTRUM_TRACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GET_AUX_SPECTRUM_TRACE.M with the given input arguments.
%
%      GET_AUX_SPECTRUM_TRACE('Property','Value',...) creates a new GET_AUX_SPECTRUM_TRACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Get_aux_spectrum_trace_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Get_aux_spectrum_trace_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Get_aux_spectrum_trace

% Last Modified by GUIDE v2.5 28-Feb-2017 16:58:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Get_aux_spectrum_trace_OpeningFcn, ...
                   'gui_OutputFcn',  @Get_aux_spectrum_trace_OutputFcn, ...
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

function uipushtool1_ClickedCallback(hObject, eventdata, handles)
set(gcf,'pointer','arrow');
datacursormode off

function Get_aux_spectrum_trace_OpeningFcn(hObject, eventdata, handles, varargin)
global c_cs rect

handles.output = hObject;
input = varargin{1};
handles.aux_spectrum = input.aux_spectrum;
set(handles.contour_level, 'String', sprintf('%.01f', input.TwoD_contour));

        
% Update handles structure
c_cs = 0;
rect = [0 0 0 0];
aux_spectrum_out.assigned = 0;
aux_spectrum_out.TwoD_contour = input.TwoD_contour;
setappdata(0, 'aux_spectrum_out', aux_spectrum_out);
guidata(hObject, handles);
set(gcf,'pointer','watch');
draw(hObject, eventdata, handles)
draw_1d_trace_Callback(hObject, eventdata, handles)
set(gcf,'pointer','arrow');

function draw(hObject, eventdata, handles)
handles = guidata(hObject);
c_level = str2double(get(handles.contour_level, 'String'));
set(gcf,'pointer','watch');
try
    direct_sampling = str2double(get(handles.direct_sampling, 'String'));
    if direct_sampling> 100 || direct_sampling < 1
        direct_sampling = 100;
    end
    indirect_sampling = str2double(get(handles.indirect_sample, 'String'));
    if indirect_sampling> 100 || indirect_sampling < 1
        indirect_sampling = 100;
    end
catch
    direct_sampling = 100;
    indirect_sampling = 100;
end

xdomain = handles.aux_spectrum.domain_x;
ydomain = handles.aux_spectrum.domain_y;
fid = handles.aux_spectrum.fid;
curr_xdomain_len = ceil(direct_sampling*length(xdomain)/100);
curr_ydomain_len = ceil(indirect_sampling*length(ydomain)/100);
steps = floor(length(ydomain)/curr_ydomain_len);
curr_ydomain_indices = 1:steps:length(ydomain);
curr_ydomain = ydomain(curr_ydomain_indices);
steps = floor(length(xdomain)/curr_xdomain_len);
curr_xdomain_indices = 1:steps:length(xdomain);
curr_xdomain = xdomain(curr_xdomain_indices);
curr_fid = fid(curr_ydomain_indices, curr_xdomain_indices);
axes(handles.axes1);
contour(curr_xdomain, curr_ydomain, curr_fid, c_level);
set(gca, 'xdir', 'reverse');
set(gca, 'ydir', 'reverse', 'YAxisLocation', 'right');
xlabel('ppm');
ylabel('ppm');
%linkaxes([handles.axes2,handles.axes1],'x')
set(gcf,'pointer','arrow')


function Draw_Callback(hObject, eventdata, handles)
draw(hObject, eventdata, handles);

function Apply_traces_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

trace = get_1D_trace(hObject, eventdata, handles);
aux_spectrum_out.TwoD_contour = str2double(get(handles.contour_level, 'String'));
aux_spectrum_out.assigned = 1;
aux_spectrum_out.fid = trace;
aux_spectrum_out.ppm = handles.aux_spectrum.domain_x;
aux_spectrum_out.field = handles.aux_spectrum.field_x;
setappdata(0, 'aux_spectrum_out', aux_spectrum_out);
cancel_Callback(hObject, eventdata, handles)

function cancel_Callback(hObject, eventdata, handles)
close(handles.figure1)

function select_peak_Callback(hObject, eventdata, handles)
move_to_trace(hObject, eventdata, handles)
dcm_obj = datacursormode(handles.figure1);
set(dcm_obj,'DisplayStyle','datatip', 'UpdateFcn',@myupdatefcn, ...
    'SnapToDataVertex','off','Enable','on')

% function uitoggletool4_ClickedCallback(hObject, eventdata, handles)
% dcm_obj = datacursormode(handles.figure1);
% set(dcm_obj,'DisplayStyle','datatip', 'UpdateFcn',@myupdatefcn, ...
%     'SnapToDataVertex','off','Enable','on')

function txt = myupdatefcn(~, eventdata, ~)
% Customizes text of data tips
global c_cs
pos = get(eventdata,'Position');
txt = {['direct dim: ',sprintf('%.04f ppm', pos(1))],...
	      ['indirect dim: ',sprintf('%.03f ppm', pos(2))]};
c_cs = pos(2);

function trace = get_1D_trace(hObject, eventdata, handles)
trace = zeros(length(handles.aux_spectrum.domain_x), 1);
if get(handles.radio_trace, 'Value') == 1
    data = get(handles.uitable1, 'Data');
    for i=1:size(data, 1)
        if ~isempty(data{i, 1}) && data{i, 2}
            [~, index] = min(abs(data{i, 1}-handles.aux_spectrum.domain_y));
            trace = trace+(handles.aux_spectrum.fid(index, :))';
        end
    end
else
    data = get(handles.uitable2, 'Data');
    for i=1:size(data, 1)
        if ~isempty(data{i, 1}) && data{i, 3}(1)
            ppm1 = data{i, 1};
            content = strsplit(ppm1, ':');
            [~, ppm1_from_index] = min(abs(str2double(content{1})-handles.aux_spectrum.domain_x));
            [~, ppm1_to_index] = min(abs(str2double(content{2})-handles.aux_spectrum.domain_x));
            ppm2 = data{i, 2};
            content = strsplit(ppm2, ':');
            [~, ppm2_from_index] = min(abs(str2double(content{1})-handles.aux_spectrum.domain_y));
            [~, ppm2_to_index] = min(abs(str2double(content{2})-handles.aux_spectrum.domain_y));
            for j=ppm2_from_index:ppm2_to_index
                trace(ppm1_from_index:ppm1_to_index) = trace(ppm1_from_index:ppm1_to_index)+(handles.aux_spectrum.fid(j, ppm1_from_index:ppm1_to_index))';
            end
        end
    end
end

function full_spectra_Callback(hObject, eventdata, handles)
axes(handles.axes1)
xlim([min(handles.aux_spectrum.domain_x) max(handles.aux_spectrum.domain_x)])
ylim([min(handles.aux_spectrum.domain_y) max(handles.aux_spectrum.domain_y)])
draw_1d_trace_Callback(hObject, eventdata, handles)

function draw_1d_trace_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
axes(handles.axes2)
trace = get_1D_trace(hObject, eventdata, handles);
XLIM = xlim(handles.axes1);
indices = handles.aux_spectrum.domain_x >=min(XLIM) & handles.aux_spectrum.domain_x <= max(XLIM);
plot(handles.aux_spectrum.domain_x(indices), trace(indices));
xlim([min(handles.aux_spectrum.domain_x(indices)) max(handles.aux_spectrum.domain_x(indices))])
set(gca, 'xdir', 'reverse');
set(gca, 'ytick', []);


function add_trace_Callback(hObject, eventdata, handles)
global c_cs
move_to_trace(hObject, eventdata, handles)
if c_cs == 0
    msgbox('you need to select a peak')
    return
end
data = get(handles.uitable1, 'Data');
index = 0;
for i=1:size(data, 1)
    if ~isempty(data{i, 1})
        index = index+1;
    end
end
index = index+1;
data{index, 1} = c_cs;
data{index, 2} = true;
set(handles.uitable1, 'Data', data, 'ColumnEditable', [false true]);
guidata(hObject, handles);
draw_1d_trace_Callback(hObject, eventdata, handles)



function draw_box_Callback(hObject, eventdata, handles)
global rect
move_to_rect(hObject, eventdata, handles)
rect = getrect(handles.axes1);
axes(handles.axes1);
rectangle('position', rect)
guidata(hObject, handles);
use_region_Callback(hObject, eventdata, handles)

function use_region_Callback(hObject, eventdata, handles)
global rect
if sum(rect) == 0
    msgbox('you need to draw a box around a peak')
    return
end
data = get(handles.uitable2, 'data');
index = 0;
for i=1:size(data, 1)
    if ~isempty(data{i, 1})
        index = index+1;
    end
end
index = index+1;
data{index, 1} = sprintf('%.03f:%.03f', rect(1), rect(1)+rect(3));
data{index, 2} = sprintf('%.03f:%.03f', rect(2), rect(2)+rect(4));
data{index, 3} = true;
set(handles.uitable2, 'Data', data, 'ColumnEditable', [false false true]);
move_to_rect(hObject, eventdata, handles)
guidata(hObject, handles);
draw_1d_trace_Callback(hObject, eventdata, handles)

function move_to_trace(hObject, eventdata, handles)
set(handles.radio_trace, 'Value', 1);
set(handles.radio_region, 'Value', 0);

function move_to_rect(hObject, eventdata, handles)
set(handles.radio_trace, 'Value', 0);
set(handles.radio_region, 'Value', 1);

function radio_region_Callback(hObject, eventdata, handles)
set(handles.radio_trace, 'Value', 0);
function radio_trace_Callback(hObject, eventdata, handles)
set(handles.radio_region, 'Value', 0);

function varargout = Get_aux_spectrum_trace_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
function contour_level_Callback(hObject, eventdata, handles)
function contour_level_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function direct_sampling_Callback(hObject, eventdata, handles)
function direct_sampling_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function indirect_sample_Callback(hObject, eventdata, handles)
function indirect_sample_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

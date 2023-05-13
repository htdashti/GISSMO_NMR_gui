function varargout = create_spin_systems(varargin)
% CREATE_SPIN_SYSTEMS MATLAB code for create_spin_systems.fig
%      CREATE_SPIN_SYSTEMS, by itself, creates a new CREATE_SPIN_SYSTEMS or raises the existing
%      singleton*.
%
%      H = CREATE_SPIN_SYSTEMS returns the handle to a new CREATE_SPIN_SYSTEMS or the handle to
%      the existing singleton*.
%
%      CREATE_SPIN_SYSTEMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_SPIN_SYSTEMS.M with the given input arguments.
%
%      CREATE_SPIN_SYSTEMS('Property','Value',...) creates a new CREATE_SPIN_SYSTEMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_spin_systems_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_spin_systems_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_spin_systems

% Last Modified by GUIDE v2.5 06-Sep-2016 14:55:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_spin_systems_OpeningFcn, ...
                   'gui_OutputFcn',  @create_spin_systems_OutputFcn, ...
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


% --- Executes just before create_spin_systems is made visible.
function create_spin_systems_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_spin_systems (see VARARGIN)

% Choose default command line output for create_spin_systems
handles.output = hObject;
setappdata(0,'created_folder', '');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes create_spin_systems wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = create_spin_systems_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function compound_name_Callback(hObject, eventdata, handles)
% hObject    handle to compound_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of compound_name as text
%        str2double(get(hObject,'String')) returns contents of compound_name as a double


% --- Executes during object creation, after setting all properties.
function compound_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to compound_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in spin_matrix.
function spin_matrix_Callback(hObject, eventdata, handles)
% hObject    handle to spin_matrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Val = get(handles.popupmenu2, 'Value');
if Val == 1
    errordlg('please identify file type of the spin matrix file')
    return
end
if Val == 6
else
    if isfield(handles, 'open_folder')
        [FileName,PathName,~] = uigetfile(sprintf('%s/*.*', handles.open_folder), 'select a spin matrix file');
    else
        [FileName,PathName,~] = uigetfile('*.*', 'select a 2D mol file');
    end

    if isnumeric(FileName)
        return;
    end
    handles.open_folder = PathName;
    handles.spin_matrix_path = sprintf('%s%s', PathName, FileName);
    set(handles.text8, 'String', FileName);
    set(handles.text8, 'Visible', 'On');
end

handles.spin_matrix_type = Val;
guidata(hObject, handles);


% --- Executes on button press in Experimental_spectrum.
function Experimental_spectrum_Callback(hObject, eventdata, handles)
% hObject    handle to Experimental_spectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Val = get(handles.popupmenu1, 'Value');
if Val == 1
    errordlg('Please select type of your experimental data')
    return
end
if Val == 2 % bruker
    msgbox({'The selected folder should contain: ', sprintf('\t\t\t1)an "acqus" file,'), sprintf('\t\t\t2)a "pdata" folder that contains:'), sprintf('\t\t\t\t2.1)"/1/1r"'), sprintf('\t\t\t2.2)"/1/procs"')});
    uiwait(gcf);    
    if isfield(handles, 'open_folder')
        folder_name = uigetdir(sprintf('%s', handles.open_folder), 'select Bruker 1H folder');
    else
        folder_name = uigetdir('.', 'select Bruker 1H folder');
        handles.open_folder = folder_name;
    end
    if isnumeric(folder_name)
        return
    end
    handles.spectrum_path = folder_name;
    path = folder_name;
end
if Val == 3 % JCAMP
    if isfield(handles, 'open_folder')
        [FileName,PathName,~] = uigetfile(sprintf('%s/*.*', handles.open_folder), 'select experimental data');
    else
        [FileName,PathName,~] = uigetfile('*.*', 'select experimental data');
    end
    if isnumeric(FileName)
        return
    end
    handles.open_folder = PathName;
    handles.spectrum_path = sprintf('%s/%s', PathName, FileName);
    path = sprintf('%s/%s', PathName, FileName);
end
if Val == 4 % NMRPipe
    if isfield(handles, 'open_folder')
        [FileName,PathName,~] = uigetfile(sprintf('%s/*.*', handles.open_folder), 'select experimental data');
    else
        [FileName,PathName,~] = uigetfile('*.*', 'select experimental data');
    end
    if isnumeric(FileName)
        return
    end
    handles.open_folder = PathName;
    handles.spectrum_path = sprintf('%s/%s', PathName, FileName);
    path = sprintf('%s/%s', PathName, FileName);
end
if Val == 5 % csv
    if isfield(handles, 'open_folder')
        [FileName,PathName,~] = uigetfile(sprintf('%s/*.*', handles.open_folder), 'select experimental data');
    else
        [FileName,PathName,~] = uigetfile('*.*', 'select experimental data');
    end
    if isnumeric(FileName)
        return
    end
    handles.open_folder = PathName;
    handles.spectrum_path = sprintf('%s/%s', PathName, FileName);
    path = sprintf('%s/%s', PathName, FileName);
end
set(handles.text17, 'String', path);
set(handles.text17, 'Visible', 'On');
handles.spectrum_type = Val-1;
guidata(hObject, handles);


% --- Executes on button press in output_folder_button.
function output_folder_button_Callback(hObject, eventdata, handles)
% hObject    handle to output_folder_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'open_folder')
    folder_name = uigetdir(sprintf('%s', handles.open_folder), 'select output folder');
else
    folder_name = uigetdir('.', 'select output folder');
end

if isnumeric(folder_name)
    return
end
handles.open_folder = folder_name;
handles.output_folder_path = folder_name;
[~,name,~] = fileparts(folder_name); 
set(handles.text9, 'String', name);
set(handles.text9, 'Visible', 'On');
guidata(hObject, handles);


function [atom_names, matrix, positions] = convert_mol_to_detailed_graph(mol_path)
fin = fopen(mol_path, 'r');
tline = fgetl(fin);
loop_starts = 0;
while ischar(tline)
    if loop_starts == 1
        for iter = 1:num_atoms
            content = strsplit(tline);
            counter = counter+1;
            if isempty(content{1})
                atom_names{counter} = content{5}; %sprintf('%s%d', content{5}, counter);
                positions(counter).coord = [str2double(content{2}), str2double(content{3}), str2double(content{4})];
            else
                atom_names{counter} = content{4}; %sprintf('%s%d', content{4}, counter);
                positions(counter).coord = [str2double(content{1}), str2double(content{2}), str2double(content{3})];
            end
            if iter~= num_atoms
                tline= fgetl(fin);
            end
        end
        for iter =1:num_edges
            tline = fgetl(fin);
            from = str2double(tline(1:3));
            to = str2double(tline(4:6));
            matrix(from, to) = 1;
        end
    end
    if ~isempty(strfind(tline, 'V2000'))
        num_atoms = str2double(tline(1:3));
        num_edges = str2double(tline(4:6));
        matrix = zeros(num_atoms);
        atom_names = cell(num_atoms, 1);
        loop_starts = 1;
        counter = 0;
    end
    tline = fgetl(fin);
    if ~isempty(strfind(tline, 'M ')) ||(length(tline) >= 6 && strcmp(tline(4:6), 'END'))% ~isempty(strfind(tline, 'END'))
        break
    end
end
fclose(fin);

function h = draw_mol_2D_file(mol_2d_path)
h = 0;
try
    [atom_names, matrix, positions] = convert_mol_to_detailed_graph(mol_2d_path);
catch
    errordlg('could not process the mol file!')
    return
end
h = figure();
hold on
x_coor = zeros(length(atom_names), 1);
y_coor = zeros(length(atom_names), 1);
three_d = 0;
for i=1:size(matrix, 1)
    for j=1:size(matrix, 1)
        if matrix(i, j) == 1
            pos_1 = positions(i).coord;
            pos_2 = positions(j).coord;
            plot([pos_1(1);pos_2(1)], [pos_1(2);pos_2(2)], 'k', 'LineWidth', 2);
        end
    end
end

for i=1:length(atom_names)
    pos = positions(i).coord;
    name = atom_names{i};
    if pos(3) ~= 0
        three_d = 1;
    end
    x_coor(i) = pos(1);
    y_coor(i) = pos(2);
    if strcmp(name, 'C')
        out_name = sprintf('%d', i);
    else
        out_name = sprintf('%s%d', name, i);
    end
    switch name
        case 'C'
            color = 'k';
        case 'H'
            color = 'k';
        case 'O'
            color = 'r';
        case 'N'
            color = 'b';
        otherwise
            color = 'y';
    end
    text(pos(1), pos(2), out_name, 'Color',color,'FontSize',14);
end
set(gca, 'XTickLabel', [])
set(gca, 'YTickLabel', [])
set(gca, 'XTick', [])
set(gca, 'YTick', [])
xlim([min(x_coor)-1 max(x_coor)+1])
ylim([min(y_coor)-1 max(y_coor)+1])
if three_d == 1
    msgbox('3D mol file was loaded. Considering it as a 2D can affect the representation of the graph.')
end

% --- Executes on button press in Create.
function Create_Callback(hObject, eventdata, handles)
% hObject    handle to Create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out_folder_name = handles.output_folder_path;

Entry.version = '1';
Entry.name = get(handles.compound_name, 'String');
[~, ID_name, ~] = fileparts(out_folder_name);
Entry.ID = ID_name;
Entry.field_strength= 600;
Entry.field_strength_flag = 1;
Entry.num_points = 16384;
Entry.num_points_flag = 1;
Entry.num_split_matrices = 0;
Entry.roi_rmsd = 1000;
Entry.DB_link = {};
Entry.Src.DB = '';
Entry.Src.DB_id = ''; 


% processing inchi
inchi = get(handles.inchi, 'String');
Entry.InChI = inchi;
try
    BGobj = convert_inchi_to_graph(inchi);
    g = my_bggui(BGobj);
    f = get(g.biograph.hgAxes, 'Parent');
    print(f, '-djpeg', sprintf('%s/inchi.jpg',out_folder_name));
    Entry.Inchi_graph_image = './inchi.jpg';
    close(f);
catch
    h = figure();
    plot([0;0],[0,1], 'k')
    xlim([0 1])
    ylim([0 1])
    text(.5, .5, 'file not found!')
    saveas(h, sprintf('%s/inchi.jpg',out_folder_name), 'jpg')
    close(h);
    Entry.Inchi_graph_image = './inchi.jpg';
end
% processing mol_file
try
    copyfile(handles.mol_2d_path, sprintf('%s/mol_2D.mol',out_folder_name));
    Entry.mol_file_path = './mol_2D.mol';
    h = draw_mol_2D_file(handles.mol_2d_path);
    saveas(h, sprintf('%s/mol_2D.jpg',out_folder_name), 'jpg')
    close(h);
    Entry.path_2D_image = './mol_2D.jpg';
catch
    Entry.mol_file_path = '.';
    h = figure();
    plot([0;0],[0,1], 'k')
    xlim([0 1])
    ylim([0 1])
    text(.5, .5, 'file not found!')
    saveas(h, sprintf('%s/mol_2D.jpg',out_folder_name), 'jpg')
    close(h);
    Entry.path_2D_image = './mol_2D.jpg';
end

% if ~isfield(handles, 'spectrum_type') || ~isfield(handles, 'spectrum_path')
%     errordlg('"Experimental spectrum" is incomplete.')
%     return
% end
if isfield(handles, 'spectrum_type')
    if ~isfield(handles, 'spectrum_path')
        errordlg('"Experimental spectrum" is incomplete.')
        return
    end
    if handles.spectrum_type == 1 % bruker
        if ~strcmp(handles.spectrum_path, sprintf('%s/1H', out_folder_name))
            copyfile(handles.spectrum_path, sprintf('%s/1H', out_folder_name));
        end
        Entry.spectrum.type = 'Bruker';
        Entry.spectrum.path = './1H/';
    end
    if handles.spectrum_type == 2 % JCAMP
        if ~strcmp(handles.spectrum_path, sprintf('%s/spectrum.jcamp', out_folder_name))
            copyfile(handles.spectrum_path, sprintf('%s/spectrum.jcamp', out_folder_name));
        end
        Entry.spectrum.type = 'JCAMP';
        Entry.spectrum.path = './spectrum.jcamp';
    end
    if handles.spectrum_type == 3 % NMRPipe
        if ~strcmp(handles.spectrum_path, sprintf('%s/spectrum.ft1', out_folder_name))
            copyfile(handles.spectrum_path, sprintf('%s/spectrum.ft1', out_folder_name));
        end
        Entry.spectrum.type = 'Varian';
        Entry.spectrum.path = './spectrum.ft1';
    end
    if handles.spectrum_type == 4 % csv
        if ~strcmp(handles.spectrum_path, sprintf('%s/spectrum.csv', out_folder_name))
            copyfile(handles.spectrum_path, sprintf('%s/spectrum.csv', out_folder_name));
        end
        Entry.spectrum.type = 'csv';
        Entry.spectrum.path = './spectrum.csv';
    end
else
    Entry.spectrum.type = 'Empty';
    Entry.spectrum.path = './';
end

if ~isfield(handles, 'spin_matrix_type')
    handles.spin_matrix_type = get(handles.popupmenu2, 'Value');
end
if ~isfield(handles, 'spin_matrix_path') && handles.spin_matrix_type ~= 6
    errordlg('Please select a spin system file');
    return
end

coupling_matrix.label = 'spin_matrix';
coupling_matrix.index = 1;
coupling_matrix.lw = '0.3';
coupling_matrix.lorent = '0.8';
coupling_matrix.gauss = '0.2';
coupling_matrix.water.min = '4.6';
coupling_matrix.water.max = '5';
coupling_matrix.water.flag = '1';
coupling_matrix.DSS.min = '-0.1';
coupling_matrix.DSS.max = '0.1';
coupling_matrix.DSS.flag = '1';
coupling_matrix.additional_coupling = [];
coupling_matrix.peak_list = [];
coupling_matrix.spectrum = [];
        
switch handles.spin_matrix_type
    case 2 % CSV
        [names, matrix] = parse_csv(handles.spin_matrix_path);
        coupling_matrix.spin_names = names;
        coupling_matrix.coupling_matrix = matrix;
        coupling_matrix.CS = diag(matrix);
        
    case 3 % spin simulation xml
        coupling_matrix = parse_ss_xml(handles.spin_matrix_path);
    case 4 % nmrDB format
        [names, matrix] = parse_nmrdb_json(handles.spin_matrix_path);
        coupling_matrix.spin_names = names;
        coupling_matrix.coupling_matrix = matrix;
        coupling_matrix.CS = diag(matrix);
    case 5 % Gaussian
        [Matrix, atoms] = Parse_Gaussian_matrix(handles.spin_matrix_path);
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
    case 6 % create
        create_spin_matrix
        uiwait(gcf);
        names = getappdata(0,'create_spin_spin_names');
        matrix = getappdata(0,'create_spin_coupling_matrix');
        
        coupling_matrix.spin_names = names;
        coupling_matrix.coupling_matrix = matrix;
        coupling_matrix.CS = diag(matrix);
        
        
end
Entry.coupling_matrix = coupling_matrix;
Entry.output_file = sprintf('%s/spin_simulation.xml', out_folder_name);
handles.Entry = Entry;
guidata(hObject, handles);
save_content(hObject, eventdata, handles)
setappdata(0,'created_folder', out_folder_name);
Cancel_Callback(hObject, eventdata, handles)




function [Matrix, atoms] = Parse_Gaussian_matrix(spin_matrix_path)
fin = fopen(spin_matrix_path, 'r');
if fin<1
    errordlg('Could not open input spin matrix file')
    return
end
tline = fgetl(fin);
shield_loop = 0;
atoms = [];
Matrix = [];
NAtoms=0;
while ischar(tline)
    if shield_loop == 1
        if ~isempty(strfind(tline, 'Isotropic ='))
            content = strsplit(tline);
            atoms(str2double(content{2})).Type = content{3};
            atoms(str2double(content{2})).CS = str2double(content{6});
        end
    end
    if length(atoms) == NAtoms
        shield_loop = 0;
    end
    if ~isempty(strfind(tline, 'SCF GIAO Magnetic shielding tensor (ppm):'))
        shield_loop = 1;
    end
    if length(tline)>= 8 && strcmp(tline(1:8), ' NAtoms=')
        content = strsplit(tline);
        NAtoms = str2double(content{3});
        Matrix = zeros(NAtoms);
    end
    if ~isempty(strfind(tline, ' Total nuclear spin-spin coupling J (Hz): '))
        while 1
            tline = fgetl(fin);
            content = strsplit(tline);
            content = content(2:end-1);
            col = zeros(length(content), 1);
            for i=1:length(col)
                col(i) = str2double(content{i});
            end
            num_rows = length(col(1):NAtoms);
            for i=1:num_rows
                tline = fgetl(fin);
                content = strsplit(tline);
                content = content(2:end);
                for j=2:length(content)
                    Matrix(str2double(content{1}), col(j-1)) = str2double(strrep(content{j}, 'D', 'e'));
                end
            end
            if col(end) == NAtoms || ~ischar(tline)
                break
            end
        end
    end
    tline = fgetl(fin);
end
fclose(fin);
for i=1:NAtoms
    Matrix(i, i) = atoms(i).CS;
end




function save_content(hObject, eventdata, handles)
handles = guidata(hObject);
if ~isfield(handles, 'Entry')
    return;
end
Entry = handles.Entry;

fpath = sprintf('%s', Entry.output_file);
fout = fopen(fpath, 'w');
if fout < 1
    errordlg(sprintf('Could not open %s to save the workspace', fpath));
    return
end

fprintf(fout, '<spin_simulation>\n');
fprintf(fout, '\t<version>%s</version>\n', Entry.version);
fprintf(fout, '\t<name>%s</name>\n', Entry.name);
fprintf(fout, '\t<ID>%s</ID>\n', Entry.ID);
fprintf(fout, '\t<InChI>%s</InChI>\n', Entry.InChI);
fprintf(fout, '\t<mol_file_path>%s</mol_file_path>\n', Entry.mol_file_path);
fprintf(fout, '\t<experimental_spectrum>\n');
fprintf(fout, '\t\t<type>%s</type>\n', Entry.spectrum.type);
fprintf(fout, '\t\t<root_folder>%s</root_folder>\n', Entry.spectrum.path);
fprintf(fout, '\t</experimental_spectrum>\n');
%if Entry.field_strength_flag == 1
    %fprintf(fout, '\t<field_strength>%s</field_strength>\n', get(handles.field_sim_fid, 'String'));
    fprintf(fout, '\t<field_strength></field_strength>\n');
    fprintf(fout, '\t<field_strength_applied_flag>1</field_strength_applied_flag>\n');
%else
%    fprintf(fout, '\t<field_strength>%d</field_strength>\n', Entry.field_strength);
%    fprintf(fout, '\t<field_strength_applied_flag>0</field_strength_applied_flag>\n');
%end
%if Entry.num_points_flag == 1
    fprintf(fout, '\t<num_simulation_points></num_simulation_points>\n');
    fprintf(fout, '\t<num_simulation_points_applied_flag>1</num_simulation_points_applied_flag>\n');
%else
%    fprintf(fout, '\t<num_simulation_points>%d</num_simulation_points>\n', Entry.num_points);
%    fprintf(fout, '\t<num_simulation_points_applied_flag>0</num_simulation_points_applied_flag>\n');
%end
fprintf(fout, '\t<Inchi_graph_image>%s</Inchi_graph_image>\n', Entry.Inchi_graph_image);
fprintf(fout, '\t<path_2D_image>%s</path_2D_image>\n', Entry.path_2D_image);
fprintf(fout, '\t<num_split_matrices>%d</num_split_matrices>\n', Entry.num_split_matrices);
for i=1:length(Entry.coupling_matrix)
    save_content_coupling_matrices(fout, Entry, i);
end
fprintf(fout, '</spin_simulation>');
fclose(fout);

handles.status_changed = 0;
guidata(hObject, handles);
msgbox({'The spin matrix is saved to', Entry.output_file, 'You can open the project'});
uiwait(gcf);


function save_content_coupling_matrices(fout, Entry, index)
cmatrix = Entry.coupling_matrix(index);


fprintf(fout,'\t<coupling_matrix>\n');
fprintf(fout,'\t\t<label>%s</label>\n', cmatrix.label);
fprintf(fout,'\t\t<index>%d</index>\n', cmatrix.index);
fprintf(fout,'\t\t<lw>%s</lw>\n', cmatrix.lw);
fprintf(fout,'\t\t<peak_shape_coefficients>\n');
fprintf(fout,'\t\t\t<lorentzian>%s</lorentzian>\n', cmatrix.lorent);
fprintf(fout,'\t\t\t<gaussian>%s</gaussian>\n', cmatrix.gauss);
fprintf(fout,'\t\t</peak_shape_coefficients>\n');
fprintf(fout,'\t\t<water_region>\n');
fprintf(fout,'\t\t\t<min_ppm>%s</min_ppm>\n', cmatrix.water.min);
fprintf(fout,'\t\t\t<max_ppm>%s</max_ppm>\n', cmatrix.water.max);
fprintf(fout,'\t\t\t<remove_flag>%s</remove_flag>\n', cmatrix.water.flag);
fprintf(fout,'\t\t</water_region>\n');
fprintf(fout,'\t\t<DSS_region>\n');
fprintf(fout,'\t\t\t<min_ppm>%s</min_ppm>\n', cmatrix.DSS.min);
fprintf(fout,'\t\t\t<max_ppm>%s</max_ppm>\n', cmatrix.DSS.max);
fprintf(fout,'\t\t\t<remove_flag>%s</remove_flag>\n', cmatrix.DSS.flag);
fprintf(fout,'\t\t</DSS_region>\n');
fprintf(fout,'\t\t<additional_coupling_constants>\n');
for i=1:size(cmatrix.additional_coupling, 1)
    fprintf(fout, '\t\t\t<acc>spin="%d" coupling="%.03f"</acc>\n', cmatrix.additional_coupling(i, 1), cmatrix.additional_coupling(i, 2));
end
fprintf(fout,'\t\t</additional_coupling_constants>\n');
fprintf(fout,'\t\t<spin_names>\n');
for i=1:length(cmatrix.spin_names)
    fprintf(fout,'\t\t\t<spin>%s</spin>\n', cmatrix.spin_names{i});
end
fprintf(fout,'\t\t</spin_names>\n');
fprintf(fout,'\t\t<chemical_shifts_ppm>\n');
for i=1:length(cmatrix.CS)
    fprintf(fout,'\t\t\t<cs>%.05f</cs>\n', cmatrix.CS(i));
end
fprintf(fout,'\t\t</chemical_shifts_ppm>\n');
fprintf(fout,'\t\t<couplings_Hz>\n');
for i=1:size(cmatrix.coupling_matrix, 1)
    for j=i+1:size(cmatrix.coupling_matrix, 1)
        fprintf(fout,'\t\t\t<coupling>from_index="%d" to_index="%d" value="%.07f"</coupling>\n', i, j, cmatrix.coupling_matrix(i, j));
    end
end
fprintf(fout,'\t\t</couplings_Hz>\n');
fprintf(fout,'\t\t<peak_list>\n');
for i =1:size(cmatrix.peak_list, 1)
    fprintf(fout,'\t\t\t<peak>PPM="%.06f" Amp="%.04f"</peak>\n', cmatrix.peak_list(i, 1), cmatrix.peak_list(i, 2));
end
fprintf(fout,'\t\t</peak_list>\n');
fprintf(fout,'\t\t<spectrum>\n');
for i =1:size(cmatrix.spectrum, 1)
    fprintf(fout,'\t\t\t<points>PPM="%.06f" Amp="%.04f"</points>\n', cmatrix.spectrum(i, 1), cmatrix.spectrum(i, 2));
end
fprintf(fout,'\t\t</spectrum>\n');
fprintf(fout,'\t</coupling_matrix>\n');
    
    



function [names, matrix] = parse_nmrdb_json(spin_matrix_path)
fin = fopen(spin_matrix_path, 'r');
if fin < 1
    errordlg('coul not open the spin matrix');
end
tline = fgetl(fin);
content = strsplit(tline, '"');
spin_counter = 0;
for i=1:length(content)
    if strcmp(content{i}, 'atomIDs')
        spin_counter = spin_counter+1;
        spin(spin_counter).name = content{i+2};
        spin(spin_counter).CS = 0;
        J_counter = 0;
    end
    if strcmp(content{i}, 'assignmentTo')
        J_counter = J_counter+1;
        spin(spin_counter).coupling(J_counter).to = content{i+2};
    end
    if strcmp(content{i}, 'coupling')
        coupling = content{i+1}(2:end);
        spin(spin_counter).coupling(J_counter).value = str2double(coupling);
    end
    if strcmp(content{i}, 'startX')
        CS_val = strrep(content{i+1}, ':', '');
        CS_val = strrep(CS_val, ',', '');
        CS_val = str2double(CS_val );
        spin(spin_counter).CS = CS_val;
    end
end
fclose(fin);
names = cell(length(spin),1 );
for i=1:length(spin)
    names{i} = spin(i).name;
end
matrix = zeros(length(names));
for i=1:length(spin)
    matrix(i, i) = spin(i).CS;
    for j=1:length(spin(i).coupling)
        for k=1:length(names)
            if strcmp(names{k}, spin(i).coupling(j).to)
                col = k;
                break
            end
        end
        matrix(i, col) = spin(i).coupling(j).value;
        matrix(col, i) = spin(i).coupling(j).value;
    end
end


function coupling_matrix = parse_ss_xml(path)
%[pathstr,name,ext] = fileparts(path);
Entry = xml_parser(path);%xml_parser(pathstr, sprintf('%s%s', name, ext));
coupling_matrix = Entry.coupling_matrix;

function [names, matrix] = parse_csv(spin_matrix_path)
fin = fopen(spin_matrix_path, 'r');
if fin < 1
    errordlg('Could not open the spin matrix file!')
    return
end
tline = fgetl(fin);
if ~isempty(strfind(tline, ','))
    del = ',';
else
    del = '\t';
end
iter = 1;
while ischar(tline)
    content = strsplit(tline, del);
    if iter == 1 && ~strcmp(content{1}, '')
        errordlg('The spin system matrix is not formatted correctly');
        return
    end
    if iter == 1
        names = content(2: end);
        remove = false(length(names), 1);
        for i=1:length(names)
            if isempty(names{i})
                remove(i) = true;
            end
        end
        names(remove) = [];
        matrix = zeros(length(names));
        tline = fgetl(fin);
        iter = iter+1;
        continue
    end
    row = content(2:end);
    for i=1:size(matrix, 1)
        if isnan(str2double(row{i}))
            errordlg('could not convert/load the spin matrix. please verify it is formatted correctly');
            return
        end
        matrix(iter-1, i) = str2double(row{i});
    end
        
    tline = fgetl(fin);
    if isempty(tline)
        break
    end
    iter = iter+1;
end

fclose(fin);



% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes on button press in open_2d_mol_file.
function open_2d_mol_file_Callback(hObject, eventdata, handles)
if isfield(handles, 'open_folder')
    [FileName,PathName,~] = uigetfile(sprintf('%s/*.mol', handles.open_folder), 'select a 2D mol file');
else
    [FileName,PathName,~] = uigetfile('.mol', 'select a 2D mol file');
end
if isnumeric(FileName)
    return;
end
set(handles.text16, 'String', FileName);
set(handles.text16, 'Visible', 'On');
handles.open_folder = PathName;
handles.mol_2d_path = sprintf('%s/%s', PathName, FileName);

guidata(hObject, handles);




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, ~)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text4.
function text4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function inchi_Callback(hObject, eventdata, handles)
% hObject    handle to inchi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inchi as text
%        str2double(get(hObject,'String')) returns contents of inchi as a double


% --- Executes during object creation, after setting all properties.
function inchi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inchi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

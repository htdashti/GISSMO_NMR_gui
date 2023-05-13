function varargout = GISSMO(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GISSMO_OpeningFcn, ...
                   'gui_OutputFcn',  @GISSMO_OutputFcn, ...
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


% --- Executes just before GISSMO is made visible.
function GISSMO_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
axes(handles.axes1);
set(gca, 'XTickLabel', {});
set(gca, 'YTickLabel', {});
set(gca, 'XTick', [0 1]);
set(gca, 'YTick', [0 1]);
axes(handles.axes2);
set(gca, 'XTickLabel', {});
set(gca, 'YTickLabel', {});
set(gca, 'XTick', [0 1]);
set(gca, 'YTick', [0 1]);
% Update handles structure

guidata(hObject, handles);


function about_gissmo_tag_Callback(hObject, eventdata, handles)
uiwait(msgbox({'GISSMO v. 2.0 ', ...
            'Compiled on Feb. 25, 2019', ...
            'An NMRFAM software packge.', ...
            'For any question or concern, please contact us:', ...
            'milo@nmrfam.wisc.edu or dashti@nmrfam.wisc.edu', ...
            'For disclaimers please visit our website'}));

% --- Outputs from this function are returned to the command line.
function varargout = GISSMO_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function reset_parameters_CS_range
global parameters_CS_range
parameters_CS_range = .1;

function reset_parameters_AB
global parameters_AB
parameters_AB.strong_coupling.domain = [-10, -20];
parameters_AB.strong_coupling.steps = -1;
parameters_AB.cs_explore.domain = [0, 2];
parameters_AB.cs_explore.steps = 0.5;
parameters_AB.max_allowed_cs_displacement =  0.05;

function reset_parameters_bothner_by_angle
global parameters_bothner_by
parameters_bothner_by.angle = 60;

function handles = reset_workspace(hObject, eventdata, handles)
clearvars -global
zoom off
reset_parameters_AB
reset_parameters_CS_range
reset_parameters_bothner_by_angle
setappdata(0,'ABx_oprimization_var', [])
set(handles.ROI_max, 'String', '12');
set(handles.ROI_min, 'String', '-1');
set(handles.water_region_min, 'String', '4.6');
set(handles.water_region_max, 'String', '5');
set(handles.water_region_flag, 'Value', 1);
set(handles.DSS_region_min, 'String', '-0.1');
set(handles.DSS_region_max, 'String', '0.1');
set(handles.DSS_region_flag, 'Value', 1);
axes(handles.axes1); hold off
set(gca, 'XTickLabel', {});
set(gca, 'YTickLabel', {});
set(gca, 'XTick', [0 1]);
set(gca, 'YTick', [0 1]);
axes(handles.axes2); hold off
set(gca, 'XTickLabel', {});
set(gca, 'YTickLabel', {});
set(gca, 'XTick', [0 1]);
set(gca, 'YTick', [0 1]);
set(handles.RMSD, 'String', 'simulation info');
drawnow
set(handles.numpoints, 'String', '2^14');
set(handles.lw_value, 'String', '0.3');
set(handles.field_sim_fid, 'String', '500');
set(handles.field_as_exp_data, 'Value', 1);
set(handles.num_point_of_sim_fid_checkbox, 'Value', 1);
set(handles.lor_coeff, 'String', '0.8');
set(handles.gau_coeff, 'String', '0.2');
set(handles.uitable1, 'Data', cell(1));
handles.spin_matrix_changed = 1;
handles = remove_field(handles, 'current_whole_spectra');
drawnow;
handles = remove_field(handles, 'current_spectra');
handles = remove_field(handles, 'spin_space_index');
handles = remove_field(handles, 'Entry');
handles = remove_field(handles, 'folder_path');
handles = remove_field(handles, 'experimental_data');
handles = remove_field(handles, 'aux_spectrum');
handles = remove_field(handles, 'backup');
guidata(hObject, handles);
reset_integrals(hObject, eventdata, handles)
handles = guidata(hObject);
guidata(hObject, handles);

function handles = remove_field(handles, tag)
if isfield(handles, tag)
    handles = rmfield(handles, tag);
end

function Check_to_save(hObject, eventdata, handles)
if isfield(handles, 'Entry')
    choice = questdlg('Would you like to save the current workspace?', 'Save status', 'Yes', 'No', 'Yes');
    if strcmp(choice, 'Yes')
        Save_Callback(hObject, eventdata, handles)
    end
end

function Create_a_project_Callback(hObject, eventdata, handles)

try
    Check_to_save(hObject, eventdata, handles);
    handles = reset_workspace(hObject, eventdata, handles);
    guidata(hObject, handles)
    setappdata(0,'created_folder', '')
    Create_a_Project;
    uiwait(gcf);
catch ME
    Handle_error(handles, ME);
end
guidata(hObject, handles)

function Handle_error(handles, ME)
uiwait(msgbox('an error has occurred!'));

function Open_a_database_Callback(hObject, eventdata, handles)
try
    handles.processed_flag = false;
    DB_root_path = uigetdir('.','Select a directory containing all of your compounds');
    if isnumeric(DB_root_path)
        msgbox('invalid database folder')
        return
    end
    List = dir(DB_root_path);
    DB_Compound_List = [];
    coutner = 0;
    for i=3:length(List)
        folder_path = sprintf('%s/%s', DB_root_path, List(i).name);
        if isdir(folder_path)
            
            compound_name = '';
            status = '';
            inchi = '';
            xml_file_path = sprintf('%s/spin_simulation.xml', folder_path);
            if exist(xml_file_path, 'file')
                fin = fopen(xml_file_path, 'r');
                tline = fgetl(fin);
                while ischar(tline)
                    if ~isempty(strfind(tline, '<InChI>'))
                        tline = strrep(tline, '<InChI>', '');
                        tline = strrep(tline, '</InChI>', '');
                        tline = strrep(tline, ' ', '');
                        inchi = tline;
                        %break
                    end
                    if ~isempty(strfind(tline, '<name>'))
                        tline = strrep(tline, '<name>', '');
                        tline = strrep(tline, '</name>', '');
                        tline = strrep(tline, ' ', '');
                        compound_name = tline;
                        %break
                    end
                    if ~isempty(strfind(tline, '<status>'))
                        tline = strrep(tline, '<status>', '');
                        tline = strrep(tline, '</status>', '');
                        tline = strrep(tline, ' ', '');
                        status = tline;
                        break
                    end
                    tline = fgetl(fin);
                end
                fclose(fin);
            end
            coutner = coutner+1;
            DB_Compound_List{coutner, 1} = List(i).name;
            DB_Compound_List{coutner, 2} = compound_name;
            DB_Compound_List{coutner, 3} = status;
            DB_Compound_List{coutner, 4} = relax_inchi_similarity(inchi);
        end
    end
    data = cell(size(DB_Compound_List, 1), 1);
    for i=1:length(data)
        data{i} = sprintf('%s(%s)-%s', DB_Compound_List{i, 1}, DB_Compound_List{i, 2}, DB_Compound_List{i, 3});
    end
    set(handles.popupmenu1, 'String', data)
    set(handles.popupmenu1, 'Value', 1)
    set(handles.text12, 'Visible', 'On')
    set(handles.popupmenu1, 'Visible', 'On')
    set(handles.Load_an_entry_from_db, 'Visible', 'On')
    handles.DB.DB_root_path = DB_root_path;
    handles.DB.DB_Compound_List = DB_Compound_List;
    guidata(hObject, handles);
catch ME
    Handle_error(handles, ME);
end

function layers = relax_inchi_similarity(inchi)
layers = '';
content = strsplit(inchi, '/');
for i=1:length(content)
    if i>2 && strcmp(content{i}(1), 'p') % removing protonations (pH effects)
        continue
    end
    if i>2 && (strcmp(content{i}(1), 'm') || strcmp(content{i}(1), 's')) % removing mirror
        continue
    end
    if i>2 && strcmp(content{i}(1), 't') % removing one chiral center
        stereo_content = strsplit(content{i},',');
        if length(stereo_content) == 1
            continue
        end
    end
    layers = sprintf('%s/%s', layers, content{i});
end

function db_copy_matrices_pushbutton_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'processed_flag') || ~handles.processed_flag
    uiwait(msgbox('please process the spin matrix!'))
    return
end

index = get(handles.popupmenu1, 'Value');
val = get(handles.popupmenu_same_compounds, 'Value');
strs = get(handles.popupmenu_same_compounds, 'String');
other_name = strs{val};
DB_root_path = handles.DB.DB_root_path;
DB_Compound_List = handles.DB.DB_Compound_List;
for i=1:length(DB_Compound_List)
    if strcmp(DB_Compound_List{i, 1}, other_name)
        other_index = i;
        break
    end
end
input.current_ID = DB_Compound_List{index, 1};
input.current_name = DB_Compound_List{index, 2};
input.other_ID = DB_Compound_List{other_index, 1};
input.other_name = DB_Compound_List{other_index, 2};
uiwait(Copy_entries_in_a_db(input));
array = getappdata(0, 'from_to_copy_db_entries');
if isempty(array)
    return
end
if array(1) == 1
    from_index = index;
else
    from_index = other_index;
end
if array(2) == 1
    to_index = index;
else
    to_index = other_index;
end
from_folder_path = sprintf('%s/%s', DB_root_path, DB_Compound_List{from_index, 1});
to_folder_path = sprintf('%s/%s', DB_root_path, DB_Compound_List{to_index, 1});

from_Entry = load_an_entry_for_db_copy_matris('spin_simulation.xml', from_folder_path);
to_Entry = load_an_entry_for_db_copy_matris('spin_simulation.xml', to_folder_path);
to_Entry.coupling_matrix = from_Entry.coupling_matrix;
to_Entry.version = handles.gissmo_version;
output_file = sprintf('%s/spin_simulation.xml', to_folder_path);
save_an_entry_for_db_copy_matrix(output_file, to_Entry, DB_Compound_List{from_index, 1})

function save_an_entry_for_db_copy_matrix(output_file, Entry, from_ID)
try
    h = msgbox('please wait ...', 'saving spin matrix');

    fout = fopen(output_file, 'w');
    if fout < 1
        close(h);
        errordlg(sprintf('Could not create the output file!'));
        return
    end

    fprintf(fout, '<spin_simulation>\n');
    fprintf(fout, '\t<version>%s</version>\n', Entry.version);
    fprintf(fout, '\t<name>%s</name>\n', Entry.name);
    fprintf(fout, '\t<ID>%s</ID>\n', Entry.ID);
    if isempty(Entry.Src.DB)
        fprintf(fout, '\t<SRC name="%s" ID="%s"></SRC>\n', 'Empty', 'Empty');
    else
        fprintf(fout, '\t<SRC name="%s" ID="%s"></SRC>\n', Entry.Src.DB, Entry.Src.DB_id);
    end
    fprintf(fout, '\t<InChI>%s</InChI>\n', Entry.InChI);
    fprintf(fout, '\t<comp_db_link>\n');
    for i=1:size(Entry.DB_link, 1)
        fprintf(fout, '\t\t<db_link DBname="%s" Accession_code="%s"></db_link>\n', Entry.DB_link{i, 1}, Entry.DB_link{i, 2});
    end
    fprintf(fout, '\t</comp_db_link>\n');
    fprintf(fout, '\t<mol_file_path>%s</mol_file_path>\n', Entry.mol_file_path);
    fprintf(fout, '\t<experimental_spectrum>\n');
    fprintf(fout, '\t\t<type>%s</type>\n', Entry.spectrum.type);
    fprintf(fout, '\t\t<root_folder>%s</root_folder>\n', Entry.spectrum.path);
    fprintf(fout, '\t</experimental_spectrum>\n');
    fprintf(fout, '\t<field_strength>%d</field_strength>\n', Entry.field_strength);
    fprintf(fout, '\t<field_strength_applied_flag>%d</field_strength_applied_flag>\n', Entry.field_strength_flag);
    fprintf(fout, '\t<num_simulation_points>%d</num_simulation_points>\n', Entry.num_points);
    fprintf(fout, '\t<num_simulation_points_applied_flag>%d</num_simulation_points_applied_flag>\n', Entry.num_points_flag);
    fprintf(fout, '\t<path_2D_image>%s</path_2D_image>\n', Entry.path_2D_image);
    fprintf(fout, '\t<num_split_matrices>%d</num_split_matrices>\n', Entry.num_split_matrices);
    fprintf(fout, '\t<roi_rmsd>100</roi_rmsd>\n');
    fprintf(fout, '\t<notes>\n');
    fprintf(fout, '\t\t<status>Initial values</status>\n');
    fprintf(fout, '\t\t<note>Copied from spin matrix of %s</note>\n', from_ID);
    fprintf(fout, '\t</notes>\n');
    for i=1:length(Entry.coupling_matrix)
        save_content_coupling_matrices(fout, Entry, i);
    end
    fprintf(fout, '</spin_simulation>');
    fclose(fout);
    try
        close(h);
    catch
    end
    uiwait(msgbox({'The spin matrix is copied to', output_file}, 'Save completed!', 'You may reload the entry.'));
catch ME
    Handle_error(handles, ME);
end

function Entry = load_an_entry_for_db_copy_matris(FileName, PathName)
try
    h = msgbox('loading the input file.', 'please wait');
    set(h,'WindowStyle','modal');
    figure(h);
    if isnumeric(FileName)
        msgbox(sprintf('invalid file name'))
        close(h)
        return
    end
    xml_file_path = sprintf('%s/%s', PathName, FileName);
    Entry = xml_parser(xml_file_path);
    try
        close(h);
    catch
    end
catch ME
    Handle_error(handles, ME);
end


function Load_an_entry_from_db_Callback(hObject, eventdata, handles)
try
    index = get(handles.popupmenu1, 'Value');
    Check_to_save(hObject, eventdata, handles);
    handles = reset_workspace(hObject, eventdata, handles);
    DB_root_path = handles.DB.DB_root_path;
    DB_Compound_List = handles.DB.DB_Compound_List;
    similar_compounds = {};
    if ~isempty(DB_Compound_List{index, 4})
        for i=1:length(DB_Compound_List)
            if i ~= index && strcmp(DB_Compound_List{i, 4}, DB_Compound_List{index, 4})
                similar_compounds{end+1} = DB_Compound_List{i, 1};
            end
        end
    end
    folder_path = sprintf('%s/%s', DB_root_path, DB_Compound_List{index, 1});
    xml_counter = 0;
    f_name = {};
    List = dir(folder_path);
    for i=3:length(List)
        if ~isempty(strfind(List(i).name, '.xml'))
            xml_counter = xml_counter+1;
            f_name{xml_counter} = List(i).name;
        end
    end
    if isempty(f_name)
        uiwait(msgbox('No xml file was found!'));
        return
    end
    if length(f_name)  > 1% multiple xml files
        [FileName,PathName,~] = uigetfile(sprintf('%s/.xml', folder_path), 'Multiple xml files found. Choose one!');
    else
        FileName= f_name{1};
        PathName = folder_path;
    end
    if ~isempty(similar_compounds)
        set(handles.text13, 'Visible', 'On')
        set(handles.popupmenu_same_compounds, 'Visible', 'On', 'String', similar_compounds)
        set(handles.db_copy_matrices_pushbutton, 'Visible', 'On');
    else
        set(handles.text13, 'Visible', 'Off')
        set(handles.popupmenu_same_compounds, 'Visible', 'Off')
        set(handles.db_copy_matrices_pushbutton, 'Visible', 'Off');        
    end
    Open_load_a_file(FileName, PathName, hObject, eventdata, handles);
catch ME
    Handle_error(handles, ME);
end    


function Open_a_project_file_Callback(hObject, eventdata, handles)
% hObject    handle to Open_a_project_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    Check_to_save(hObject, eventdata, handles);
    handles = reset_workspace(hObject, eventdata, handles);
    guidata(hObject, handles)
    [FileName,PathName,~] = uigetfile('.xml', 'load a saved spin simulation xml file');
    Open_load_a_file(FileName, PathName, hObject, eventdata, handles);
    
    set(handles.text12, 'Visible', 'Off')
    set(handles.popupmenu1, 'Visible', 'Off')
    set(handles.Load_an_entry_from_db, 'Visible', 'Off')
    if isfield(handles, 'DB')
        handles = rmfield(handles, 'DB');
        set(handles.popupmenu1, 'Value', 1);
    end
catch ME
    errordlg('Error while opening the xml file')
    Handle_error(handles, ME);
end

function Open_load_a_file(FileName, PathName, hObject, eventdata, handles)
try
    handles.processed_flag = false;
    % set gissmo version
    handles.gissmo_version = '2';
    
    h = msgbox('loading the input file.', 'please wait');
    set(h,'WindowStyle','modal');
    figure(h);
    if isnumeric(FileName)
        msgbox(sprintf('invalid file name'))
        close(h)
        return
    end
    xml_file_path = sprintf('%s/%s', PathName, FileName);
    handles.out_path = xml_file_path;
    Entry = xml_parser(xml_file_path);
    %fprintf('reporting properties\n')
    %fprintf('loading experimenta; data\n')

    [spectrum, domain, field] = Load_experimental_data(Entry, PathName);
    %fprintf('adjustibng experimental info\n')
    if Entry.field_strength_flag == 1
        Entry.field_strength = field;
    end
    if Entry.num_points_flag == 1
        Entry.num_points = length(spectrum);
    end
    %fprintf('getting mean zero spec\n')
    spectrum= Mean_zero_spectrum(spectrum);

    %fprintf('adjusting handles')
    handles.experimental_data.spectrum = spectrum;
    handles.experimental_data.domain = domain;
    handles.experimental_data.field = field;
    handles.folder_path = PathName;
    handles.Entry = Entry;
    handles.spin_space_index = 1;
    handles.spin_matrix_changed = 1;
    %fprintf('updating\n')
    guidata(hObject, handles);
    close(h);
    Report_Entry_properties(Entry);
    %fprintf('populating work station\n')
    Populated_workspace(hObject, eventdata, handles);
    %fprintf('done\n')
catch ME
    Handle_error(handles, ME);
end

function Populated_workspace(hObject, eventdata, handles)
try
    handles = guidata(hObject);
    Entry = handles.Entry;
    set(handles.numpoints,'String', sprintf('%d', Entry.num_points));
    set(handles.num_point_of_sim_fid_checkbox, 'Value', Entry.num_points_flag);
    set(handles.lw_value, 'String', Entry.coupling_matrix(handles.spin_space_index).lw);
    set(handles.field_sim_fid, 'String', sprintf('%.02f', Entry.field_strength));
    set(handles.field_as_exp_data, 'Value', Entry.field_strength_flag);
    set(handles.lor_coeff, 'String', Entry.coupling_matrix(handles.spin_space_index).lorent);
    set(handles.gau_coeff, 'String', Entry.coupling_matrix(handles.spin_space_index).gauss);
    set(handles.water_region_min, 'String', Entry.coupling_matrix(handles.spin_space_index).water.min);
    set(handles.water_region_max, 'String', Entry.coupling_matrix(handles.spin_space_index).water.max);
    set(handles.water_region_flag, 'Value', str2double(Entry.coupling_matrix(handles.spin_space_index).water.flag));
    set(handles.DSS_region_min, 'String', Entry.coupling_matrix(handles.spin_space_index).DSS.min);
    set(handles.DSS_region_max, 'String', Entry.coupling_matrix(handles.spin_space_index).DSS.max);
    set(handles.DSS_region_flag, 'Value', str2double(Entry.coupling_matrix(handles.spin_space_index).DSS.flag));
    set(handles.compound_name, 'String', sprintf('%s(%s)', Entry.name, Entry.coupling_matrix(handles.spin_space_index).label));
    Fill_spin_matrix(hObject, eventdata, handles)
    Draw_experimental_spectrum_axes(hObject, eventdata, handles)
    axes(handles.axes2);
    plot([-2; 10], [0;0])
    set(gca, 'XDir', 'reverse');
    ylim([-.1, 1.1]);
    xlim([-2, 10])
catch ME
    Handle_error(handles, ME);
end

function Fill_spin_matrix(hObject, eventdata, handles)
try
    matrix = handles.Entry.coupling_matrix(handles.spin_space_index).coupling_matrix;
    names = handles.Entry.coupling_matrix(handles.spin_space_index).spin_names;
    set(handles.uitable1, 'Data', matrix);
    set(handles.uitable1, 'ColumnName', names);
    set(handles.uitable1, 'RowName', names);
    flags = true(1, size(matrix, 1));
    set(handles.uitable1, 'ColumnEditable', flags);
    guidata(hObject, handles);
catch ME
    Handle_error(handles, ME);
end
function Draw_full_exp_spectrum_Callback(hObject, eventdata, handles)
Draw_experimental_spectrum_axes(hObject, eventdata, handles)

function Draw_experimental_spectrum_axes(hObject, eventdata, handles)
try
    axes(handles.axes1);
    cla reset;
    zoom reset
    zoom off
    handles = guidata(hObject);
    if ~isfield(handles, 'experimental_data') || ~isfield(handles.experimental_data, 'domain') || ~isfield(handles, 'experimental_data') || ~isfield(handles.experimental_data, 'spectrum')
        return
    end
    axes(handles.axes1);
    
    handles.exp_plot = plot(handles.experimental_data.domain, handles.experimental_data.spectrum, 'b');
    set(gca, 'XDir', 'reverse')
    set(gca, 'ytick', []);
    xlim([min(handles.experimental_data.domain) max(handles.experimental_data.domain)])
    draw_integrals(hObject, eventdata, handles)
    set(gcf,'windowscrollWheelFcn', @scale_exp_spectrum);
    guidata(hObject, handles);
catch ME
    Handle_error(handles, ME);
end

function Draw_connectivity_graph_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry') || (isempty(handles.Entry.path_2D_image))
        errordlg('There are no images for this compound!')
        return;
    end
    %Paths{1} = sprintf('%s/%s', handles.folder_path, handles.Entry.Inchi_graph_image);
    Paths{1} = handles.Entry.InChI;
    Paths{2} = sprintf('%s/%s', handles.folder_path, handles.Entry.path_2D_image);
    Load_inchi_fig_gui(Paths)
catch ME
    Handle_error(handles, ME);
end

function [spectrum, domain, field] = Load_experimental_data(Entry, folder_path)
switch Entry.spectrum.type
    case 'Bruker'
        [spectrum, domain, field, ~] = Get_spectra_bruker(Entry, folder_path);
        spectrum = flipud(spectrum);
    case 'JCAMP'
        [spectrum, domain, field] = Get_spectra_JCAMP(Entry, folder_path);
        domain = fliplr(domain);
        spectrum = fliplr(spectrum);
    case 'Varian'
        [spectrum, domain, field] = Read_nmrPipe_1D_Spectrum(Entry, folder_path);
    case 'csv'
        [spectrum, domain, field] = Get_csv_spectrum(Entry, folder_path);
    case 'Empty'
        field = 500;
        domain = -1:13/(2^14+1):12;
        spectrum = zeros(length(domain), 1);
    otherwise
        errordlg('This version of spin simulation only supports Bruker or JCAMP file formats');
end

function View_properties_menu_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'Entry')
    return
end
uiwait(Report_Entry_properties(handles.Entry))

function Report_Entry_properties(Entry)
    Str = {sprintf('spin simulation verstion: %s', Entry.version), ...
            sprintf('Compound name: %s', Entry.name), ...
            sprintf('Compound ID: %s', Entry.ID), ...
            sprintf('2D graph path: %s', Entry.path_2D_image), ...
            sprintf('Num sub-matrices: %d', Entry.num_split_matrices), ...
            sprintf('Num spins: %d', length(Entry.coupling_matrix(1).spin_names)), ...
            sprintf('Num additional couplings: %d', size(Entry.coupling_matrix(1).additional_coupling, 1)), ...
            sprintf('Notes: '), ...
            Entry.Notes.status, ...
            Entry.Notes.txt, ...
        };
    Report_properties(Str);

function Save_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry') || ~isfield(handles, 'folder_path')
        msgbox('there is nothing to save!')
        return;
    end
    if ~isfield(handles, 'out_path')
       [FileName,PathName,~] = uiputfile(sprintf('%s/*.xml', handles.folder_path), 'Create output file');
       output_file = sprintf('%s/%s', PathName, FileName);
       handles.out_path = output_file;
       guidata(hObject, handles);
    else
        output_file = handles.out_path;
    end
    save_workspace(output_file, hObject, eventdata, handles)
catch ME
    Handle_error(handles, ME);
end

function save_workspace(output_file, hObject, eventdata, handles)
try
    h = msgbox('please wait ...', 'saving spin matrix');

    Entry = Update_Entry(hObject, eventdata, handles);

    fout = fopen(output_file, 'w');
    if fout < 1
        close(h);
        errordlg(sprintf('Could not create the output file!'));
        return
    end
    fprintf(fout, '<spin_simulation>\n');
    fprintf(fout, '\t<version>%s</version>\n', handles.gissmo_version);
    fprintf(fout, '\t<name>%s</name>\n', Entry.name);
    fprintf(fout, '\t<ID>%s</ID>\n', Entry.ID);
    if isempty(Entry.Src.DB)
        fprintf(fout, '\t<SRC name="%s" ID="%s"></SRC>\n', 'Empty', 'Empty');
    else
        fprintf(fout, '\t<SRC name="%s" ID="%s"></SRC>\n', Entry.Src.DB, Entry.Src.DB_id);
    end
    fprintf(fout, '\t<InChI>%s</InChI>\n', Entry.InChI);
    fprintf(fout, '\t<comp_db_link>\n');
    for i=1:size(Entry.DB_link, 1)
        fprintf(fout, '\t\t<db_link DBname="%s" Accession_code="%s"></db_link>\n', Entry.DB_link{i, 1}, Entry.DB_link{i, 2});
    end
    fprintf(fout, '\t</comp_db_link>\n');
    fprintf(fout, '\t<mol_file_path>%s</mol_file_path>\n', Entry.mol_file_path);
    fprintf(fout, '\t<experimental_spectrum>\n');
    fprintf(fout, '\t\t<type>%s</type>\n', Entry.spectrum.type);
    fprintf(fout, '\t\t<root_folder>%s</root_folder>\n', Entry.spectrum.path);
    fprintf(fout, '\t</experimental_spectrum>\n');
    if Entry.field_strength_flag == 1
        fprintf(fout, '\t<field_strength>%s</field_strength>\n', get(handles.field_sim_fid, 'String'));
        fprintf(fout, '\t<field_strength_applied_flag>1</field_strength_applied_flag>\n');
    else
        fprintf(fout, '\t<field_strength>%d</field_strength>\n', Entry.field_strength);
        fprintf(fout, '\t<field_strength_applied_flag>0</field_strength_applied_flag>\n');
    end
    if Entry.num_points_flag == 1
        fprintf(fout, '\t<num_simulation_points>%d</num_simulation_points>\n', str2double(get(handles.numpoints, 'String')));
        fprintf(fout, '\t<num_simulation_points_applied_flag>1</num_simulation_points_applied_flag>\n');
    else
        fprintf(fout, '\t<num_simulation_points>%d</num_simulation_points>\n', Entry.num_points);
        fprintf(fout, '\t<num_simulation_points_applied_flag>0</num_simulation_points_applied_flag>\n');
    end
    %fprintf(fout, '\t<Inchi_graph_image>%s</Inchi_graph_image>\n', Entry.Inchi_graph_image);
    fprintf(fout, '\t<path_2D_image>%s</path_2D_image>\n', Entry.path_2D_image);
    fprintf(fout, '\t<num_split_matrices>%d</num_split_matrices>\n', Entry.num_split_matrices);
    if isfield(handles, 'roi_rmsd_value')
        fprintf(fout, '\t<roi_rmsd>%.05f</roi_rmsd>\n', handles.roi_rmsd_value);
    end
    fprintf(fout, '\t<notes>\n');
    fprintf(fout, '\t\t<status>%s</status>\n', Entry.Notes.status);
    content = strsplit(Entry.Notes.txt, '\n');
    for i=1:length(content)
        fprintf(fout, '\t\t<note>%s</note>\n', content{i});
    end
    fprintf(fout, '\t</notes>\n');
    for i=1:length(Entry.coupling_matrix)
        save_content_coupling_matrices(fout, Entry, i);
    end
    fprintf(fout, '</spin_simulation>');
    fclose(fout);

    guidata(hObject, handles);
    close(h);
    msgbox({'The spin matrix is saved to', output_file, 'Paths to external files (experimental spectrum, mol and figure files) are relative to the spin matrix file.', 'Keep them all in the same direcoty'}, 'Save completed!');
    uiwait(gcf);
catch ME
    Handle_error(handles, ME);
end

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
    for i=1:size(cmatrix.additional_coupling_groups, 1)
        fprintf(fout, '\t\t\t<acc spin_index="%d" coupling="%.03f" spin_group_index="%d" coupling_group_index="%d"></acc>\n', ...
            cmatrix.additional_coupling_groups(i, 1), ...
            cmatrix.additional_coupling_groups(i, 2), ...
            cmatrix.additional_coupling_groups(i, 3), ...
            cmatrix.additional_coupling_groups(i, 4));
    end

    fprintf(fout,'\t\t</additional_coupling_constants>\n');
    fprintf(fout,'\t\t<spin_names>\n');
    for i=1:length(cmatrix.spin_names)
        fprintf(fout,'\t\t\t<spin index="%d" name="%s"></spin>\n', i, cmatrix.spin_names{i});
    end
    fprintf(fout,'\t\t</spin_names>\n');
    fprintf(fout,'\t\t<chemical_shifts_ppm>\n');
    for i=1:length(cmatrix.CS)
        fprintf(fout,'\t\t\t<cs index="%d" ppm="%.05f"></cs>\n', i, cmatrix.CS(i));
    end
    fprintf(fout,'\t\t</chemical_shifts_ppm>\n');
    fprintf(fout,'\t\t<couplings_Hz>\n');
    for i=1:size(cmatrix.coupling_matrix, 1)
        for j=i+1:size(cmatrix.coupling_matrix, 1)
            if cmatrix.coupling_matrix(i, j) ~= 0
                    fprintf(fout,'\t\t\t<coupling from_index="%d" to_index="%d" value="%.07f"></coupling>\n', i, j, cmatrix.coupling_matrix(i, j));
            end
        end
    end
    fprintf(fout,'\t\t</couplings_Hz>\n');
    fprintf(fout,'\t\t<peak_list>\n');
    for i =1:size(cmatrix.peak_list, 1)
        fprintf(fout,'\t\t\t<peak PPM="%.06f" Amp="%.04f"></peak>\n', cmatrix.peak_list(i, 1), cmatrix.peak_list(i, 2));
    end
    fprintf(fout,'\t\t</peak_list>\n');
    fprintf(fout,'\t\t<spectrum>\n');
    %if length(cmatrix.spin_names) >= 10
    if length(Entry.coupling_matrix) > 1   
        for i =1:size(cmatrix.spectrum, 1)
            fprintf(fout,'\t\t\t<points PPM="%.06f" Amp="%.04f"></points>\n', cmatrix.spectrum(i, 1), cmatrix.spectrum(i, 2));
        end
    end
    fprintf(fout,'\t\t</spectrum>\n');
    fprintf(fout,'\t</coupling_matrix>\n');

function Entry = Update_Entry(hObject, eventdata, handles)
try
    Entry = handles.Entry;
    Entry.num_points_flag = get(handles.num_point_of_sim_fid_checkbox, 'Value');
    Entry.num_points = str2double(get(handles.numpoints, 'String'));
    Entry.field_strength_flag = get(handles.field_as_exp_data, 'Value');
    Entry.field_strength = str2double(get(handles.field_sim_fid, 'String'));
    Entry.coupling_matrix(handles.spin_space_index).lw = get(handles.lw_value, 'String');
    Entry.coupling_matrix(handles.spin_space_index).lorent = get(handles.lor_coeff, 'String');
    Entry.coupling_matrix(handles.spin_space_index).gauss = get(handles.gau_coeff, 'String');
    Entry.coupling_matrix(handles.spin_space_index).water.min = get(handles.water_region_min, 'String');
    Entry.coupling_matrix(handles.spin_space_index).water.max = get(handles.water_region_max, 'String');
    Entry.coupling_matrix(handles.spin_space_index).water.flag = sprintf('%d', get(handles.water_region_flag, 'Value')); 
    Entry.coupling_matrix(handles.spin_space_index).DSS.min = get(handles.DSS_region_min, 'String');
    Entry.coupling_matrix(handles.spin_space_index).DSS.max = get(handles.DSS_region_max, 'String');
    Entry.coupling_matrix(handles.spin_space_index).DSS.flag = sprintf('%d', get(handles.DSS_region_flag, 'Value'));
catch ME
    Handle_error(handles, ME);
end

function Save_as_Callback(hObject, eventdata, handles)
try
    [FileName,PathName,~] = uiputfile(sprintf('%s/*.xml', handles.folder_path), 'Create output file');
    output_file = sprintf('%s/%s', PathName, FileName);
    save_workspace(output_file, hObject, eventdata, handles)
catch ME
    Handle_error(handles, ME);
end

function exit_Callback(hObject, eventdata, handles)
close(handles.figure1);

function export_simulated_spectrum_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'sim_ppm')
        msgbox('there is no information to export')
        return
    end
    axes(handles.axes2);
    XLIM = xlim;
    indices = handles.current_spectra.sim_ppm >= min(XLIM) & handles.current_spectra.sim_ppm <= max(XLIM);
    figure();
    plot(handles.current_spectra.sim_ppm(indices), handles.current_spectra.sim_fid(indices), 'r')
    set(gca, 'xdir', 'reverse');
    Min = min(handles.current_spectra.sim_fid);
    Max = max(handles.current_spectra.sim_fid);
    Dist = Max-Min;
    ylim([Min-.1*Dist Max+.1*Dist]);
    set(gca, 'ytick', []);
    Title = sprintf('%s(%s)', strrep(handles.Entry.name, '_', '-'), strrep(handles.Entry.coupling_matrix(handles.spin_space_index).label, '_', '-'));
    Title = strrep(Title, '(merged)', '');
    
    title({'GISSMO simulated spectrum for ', Title});
catch ME
    Handle_error(handles, ME);
end

function export_superimposed_spectra_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'sim_ppm')
        msgbox('there is no information to export')
        return
    end
    axes(handles.axes2);
    XLIM = xlim();
    indices = handles.current_spectra.exp_ppm > min(XLIM) & handles.current_spectra.exp_ppm < max(XLIM);
    data.exp_roi_domain = handles.current_spectra.exp_ppm(indices);
    data.exp_roi_fid = handles.current_spectra.exp_fid(indices);
    indices = handles.current_spectra.sim_ppm > min(XLIM) & handles.current_spectra.sim_ppm < max(XLIM);
    data.sim_roi_ppm = handles.current_spectra.sim_ppm(indices);
    data.sim_roi_fid = handles.current_spectra.sim_fid(indices);
    data.name = handles.Entry.name;
    data.ID = strrep(handles.Entry.coupling_matrix(handles.spin_space_index).label, '_', '-');
    get_offsets(data)
catch ME
    Handle_error(handles, ME);
end

function Process_button_Callback(hObject, eventdata, handles)
try
    process(hObject, eventdata, handles);
catch ME
    Handle_error(handles, ME);
end

function out = check_for_couplings_nan(processing_info)
out = true;
if isempty(processing_info.additional_couplings) || isempty(processing_info.additional_couplings_groups)
    return
end
if nnz(isnan(processing_info.additional_couplings)) ~= 0 || nnz(isnan(processing_info.additional_couplings_groups)) ~= 0
    out = false;
end

function uitable1_CellEditCallback(hObject, eventdata, handles)
indices = eventdata.Indices;
data = get(handles.uitable1, 'data');
data(indices(2), indices(1)) = eventdata.NewData;
set(handles.uitable1, 'data', data);

function try_to_close_a_figure(h)
try
    close(h)
catch
end

function process(hObject, eventdata, handles)

handles.processed_flag = true;
h = msgbox('please wait', 'Processing');

processing_info = get_processing_package(hObject, eventdata, handles);
% get spctra
if ~check_for_couplings_nan(processing_info)
    errordlg('There is a problem with the additional coupling values. Please consider removing and re-assigning additional couplings')
end

msg_spin_in_deleted_region = {};
for i=1:size(processing_info.spin_matrix, 1)
    if processing_info.spin_matrix(i, i) > processing_info.water_min && processing_info.spin_matrix(i, i) < processing_info.water_max
        msg_spin_in_deleted_region{end+1} = sprintf('Spin "%s" is located inside of water region and has been deleted!', processing_info.spin_names{i});
    end
    if processing_info.spin_matrix(i, i) > processing_info.DSS_min && processing_info.spin_matrix(i, i) < processing_info.DSS_max
        msg_spin_in_deleted_region{end+1} = sprintf('Spin "%s" is located inside of DSS region and has been deleted!', processing_info.spin_names{i});
    end
end
if ~isempty(msg_spin_in_deleted_region)
    uiwait(msgbox(msg_spin_in_deleted_region, 'Warning; spins have been discarded!'));
end

exp_ppm = handles.experimental_data.domain;
exp_fid = handles.experimental_data.spectrum;
%exp_fid = .1.*ones(size(exp_fid));

set(handles.uitable1, 'Data', update_lower_triangle(get(handles.uitable1, 'Data')))

% if there are sub-matrices
if length(handles.Entry.coupling_matrix) > 1 
    % if we are looking at the merged spin matrix
    if handles.spin_space_index == 1 
        % sub-matrices have not been merged
        if isempty(handles.Entry.coupling_matrix(1).spectrum)
            uiwait(msgbox({'There are sub-matrices, but have not been merged!', 'Please consider merging sub-matrices firt.', 'Aborting ...'}));
            try_to_close_a_figure(h)
            return
        else % sub-matrices have been merged
            temp = handles.Entry.coupling_matrix(1).spectrum;
            sim_ppm = temp(:, 1)';
            sim_fid = temp(:, 2);
            uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        end
    else % we are processing sub-matrices
        % the sub-matrix has more than 10 spins
        if size(processing_info.spin_matrix, 1) > 10 
            choice = questdlg('The spin matrix contains more than 10 spins, it will take too long to process it. Would like to continue?', 'Processing a large spin matrix', 'Yes', 'No', 'Yes');
            if strcmp(choice, 'No')
                try_to_close_a_figure(h)
                return
            end
        end
        % the sub-matrix is small enough:
        [sim_ppm, sim_fid] = Diagonalization(processing_info);
    end
else % only one spin matrix
    if size(processing_info.spin_matrix, 1) > 10
        choice = questdlg('The spin matrix contains more than 10 spins, it will take too long to process it. Would like to continue?', 'Processing a large spin matrix', 'Yes', 'No', 'Yes');
        if strcmp(choice, 'No')
            try_to_close_a_figure(h)
            return
        end
    end
    [sim_ppm, sim_fid] = Diagonalization(processing_info);
end
% 
% % if it is merged, do not recalculate
% if length(handles.Entry.coupling_matrix) > 1 
%     if isempty(handles.Entry.coupling_matrix(1).spectrum)
%         if size(processing_info.spin_matrix, 1) > 10
%             subMatrices_processed_before = 1;
%             for i=2:length(handles.Entry.coupling_matrix)
%                 if isempty(handles.Entry.coupling_matrix(i).spectrum)
%                     subMatrices_processed_before = 0;
%                 end
%             end
%             if subMatrices_processed_before == 1 % sub matrices have been processed 
%                 choice = questdlg({'The sub-matrices have been processed before, but have not been merged!', 'Would you like to merge them?'}, 'Processing a large spin matrix', 'Yes', 'No', 'Yes');
%                 switch choice
%                     case 'Yes'
%                         Merge_sub_matrices_Callback(hObject, eventdata, handles);
%                         return
%                     case 'No'
%                         choice = questdlg('The spin matrix contains more than 10 spins, it takes long to process it. Would like to continue?', 'Processing a large spin matrix', 'Yes', 'No', 'Yes');
%                         if strcmp(choice, 'Yes')
%                             [sim_ppm, sim_fid] = Diagonalization(processing_info);
%                         else
%                             return
%                         end
%                 end
%             else
%                 choice = questdlg('The spin matrix contains more than 10 spins, it takes long to process it. Would like to continue?', 'Processing a large spin matrix', 'Yes', 'No', 'Yes');
%                 if strcmp(choice, 'Yes')
%                     [sim_ppm, sim_fid] = Diagonalization(processing_info);
%                 else
%                     try
%                         close(h);
%                     catch
%                     end
%                     return
%                 end
%             end
%         else
%             [sim_ppm, sim_fid] = Diagonalization(processing_info);
%         end
%     else
%         temp = handles.Entry.coupling_matrix(1).spectrum;
%         sim_ppm = temp(:, 1)';
%         sim_fid = temp(:, 2);
%         % handles.spin_space_index == 1
%         uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
%     end
% else % only one spin matrix
%     if size(processing_info.spin_matrix, 1) > 10
%         choice = questdlg('The spin matrix contains more than 10 spins, it takes long to process it. Would like to continue?', 'Processing a large spin matrix', 'Yes', 'No', 'Yes');
%         if strcmp(choice, 'Yes')
%             [sim_ppm, sim_fid] = Diagonalization(processing_info);
%         else
%             return
%         end
%     else
%         [sim_ppm, sim_fid] = Diagonalization(processing_info);
%     end
% end
handles.data_to_export4web.exp_ppm = exp_ppm;
handles.data_to_export4web.exp_fid = apply_water_DSS_region(exp_ppm, exp_fid, processing_info);
handles.data_to_export4web.exp_fid = handles.data_to_export4web.exp_fid ./ max(handles.data_to_export4web.exp_fid );
handles.data_to_export4web.sim_ppm = sim_ppm;
handles.data_to_export4web.sim_fid = apply_water_DSS_region(sim_ppm, sim_fid, processing_info);
handles.data_to_export4web.sim_fid = handles.data_to_export4web.sim_fid./max(handles.data_to_export4web.sim_fid);

check_roi_vs_spin_CS(processing_info)
[sim_fid_2draw, sim_roi_ppm, exp_roi_ppm, exp_fid_2draw] = scale_apply_roi_dss_region(sim_ppm, sim_fid, exp_ppm, exp_fid, processing_info);

axes(handles.axes2);

plot(sim_roi_ppm, Mean_zero_spectrum(sim_fid_2draw), 'r'); hold on
plot(exp_roi_ppm, Mean_zero_spectrum(exp_fid_2draw), 'b');
Draw_zigZag_water_DSS(exp_roi_ppm, handles, processing_info);
xlim([min(sim_roi_ppm) max(sim_roi_ppm)])
set(gca, 'XDir', 'reverse');
hold off
guidata(hObject, handles);
calculate_rmsd(hObject, eventdata, sim_ppm, sim_fid);
%Write_spectra_for_web(hObject, sim_ppm, sim_fid);
[scaled_sim_fid, ~] = scale_dss_region(sim_ppm, sim_fid, exp_ppm, exp_fid, processing_info);
if length(handles.Entry.coupling_matrix) > 1 && ~isempty(handles.Entry.coupling_matrix(1).spectrum)
    % before 14 April 2017; it was sim_ppm, sim_fid (instead of the scaled)
    handles = incorporate_result_of_process(sim_ppm, scaled_sim_fid, exp_roi_ppm, exp_fid_2draw, processing_info, hObject);
else
    % we need to have entire simulated spectra to be stored in the Entry,
    % when we draw it, we adjust the roi, beside that there is no reason
    % (or I cant see any reason) to cut the spectrum based on ROI and then
    % store it. I did this on 14 April 2017, to keep entire sim_fid of the
    % sub matrices, so when we merge them we have the entire spectrum.
    %handles = incorporate_result_of_process(sim_roi_ppm, sim_fid_2draw, exp_roi_ppm, exp_fid_2draw, processing_info, hObject);
    handles = incorporate_result_of_process(sim_ppm, scaled_sim_fid, exp_roi_ppm, exp_fid_2draw, processing_info, hObject);
end
handles.spin_matrix_changed = 0;
guidata(hObject, handles);
if get(handles.checkbox5, 'Value') == 1
    index = handles.spin_space_index;
    if isfield(handles, 'backup') && isfield(handles.backup, 'couplings') && size(handles.backup.couplings.coupling_matrix, 1) > size(handles.Entry.coupling_matrix(index).coupling_matrix, 1)
       % update backup based on current entry
        init_backup = handles.backup.couplings;
        init_entry = handles.Entry.coupling_matrix(index);

        % replace entry with backup
        backup_spin_names = handles.backup.couplings.spin_names;
        entry_spin_names = handles.Entry.coupling_matrix(index).spin_names;
        Map = [];
        for i=1:length(entry_spin_names)
            corr_index = find(strcmp(backup_spin_names, entry_spin_names{i}));
            Map = [Map; [i, corr_index]];
        end
        handles.backup.couplings.coupling_matrix(Map(:, 2), Map(:, 2)) = handles.Entry.coupling_matrix(index).coupling_matrix;
        handles.backup.couplings.CS = diag(handles.backup.couplings.coupling_matrix);
        handles.backup.couplings.additional_coupling = [];
        handles.backup.couplings.additional_coupling_groups = [];
        if ~isempty(handles.Entry.coupling_matrix(index).additional_coupling)
            temp = handles.Entry.coupling_matrix(index).additional_coupling_groups;
            for i=1:size(temp)
                new_index = Map(temp(i, 1) == Map(:, 1), 2);
                temp(i, 1) = new_index;
            end
            handles.backup.couplings.additional_coupling_groups = temp;
            handles.backup.couplings.additional_coupling = temp(:, 1:2);
        end

        handles.Entry.coupling_matrix(index) = handles.backup.couplings;
        guidata(hObject, handles)
       % save 
        Auto_Save(hObject, eventdata, handles);
       % return back to init
        handles.backup.couplings = init_backup;
        handles.Entry.coupling_matrix(index) = init_entry;
        guidata(hObject, handles)
    else
        Auto_Save(hObject, eventdata, handles);
    end
end
close(h);

function [sim_fid_2draw, exp_fid_2draw] = scale_dss_region(sim_ppm, sim_fid, exp_ppm, exp_fid, processing_info)
% apply water and DSS 
sim_fid_2draw = apply_water_DSS_region(sim_ppm, sim_fid, processing_info);
exp_fid_2draw = apply_water_DSS_region(exp_ppm, exp_fid, processing_info);

if max(exp_fid_2draw) ~= 0
    % these are for the cases when the water peak is high and affected the
    % spectral height while loading the data
    exp_fid_2draw = exp_fid_2draw./max(exp_fid_2draw);
    exp_fid_2draw = Mean_zero_spectrum(exp_fid_2draw);
    % we need to scale the simulation too.
    sim_fid_2draw = scale_sim_acc_exp(sim_fid_2draw, sim_ppm, exp_ppm, exp_fid_2draw, processing_info);
end
sim_fid_2draw = Mean_zero_spectrum(sim_fid_2draw);

function [sim_fid_2draw, sim_roi_ppm, exp_roi_ppm, exp_fid_2draw] = scale_apply_roi_dss_region(sim_ppm, sim_fid, exp_ppm, exp_fid, processing_info)
[sim_fid_2draw, exp_fid_2draw] = scale_dss_region(sim_ppm, sim_fid, exp_ppm, exp_fid, processing_info);

[sim_roi_ppm, sim_fid_2draw] = apply_ROI_region(sim_ppm, sim_fid_2draw, processing_info, 'sim');
[exp_roi_ppm, exp_fid_2draw] = apply_ROI_region(exp_ppm, exp_fid_2draw, processing_info, 'exp');

function check_roi_vs_spin_CS(processing_info)
CS =  diag(processing_info.spin_matrix);
checks = zeros(size(CS));
for i=1:length(CS)
    if CS(i) >= processing_info.ROI_min && CS(i) <=processing_info.ROI_max
        checks(i) = 1;
    end
end

if sum(checks) == 0
    uiwait(warndlg('Simulated spectrum is empty; It seems the ROI does not contain the spins CS. You may need to reprocess.'));
end

function sim_fid_2draw = scale_sim_acc_exp(sim_fid_2draw, sim_roi_ppm, exp_roi_ppm, exp_fid_2draw, processing_info)
sim_domain = false(size(sim_roi_ppm));
for i=1:size(processing_info.spin_matrix, 1)
    indices = sim_roi_ppm > processing_info.spin_matrix(i, i)-.1 & sim_roi_ppm < processing_info.spin_matrix(i, i)+.1;
    sim_domain(indices) = true;
end

exp_domain = false(size(exp_roi_ppm));
for i=1:size(processing_info.spin_matrix, 1)
    indices = exp_roi_ppm > processing_info.spin_matrix(i, i)-.1 & exp_roi_ppm < processing_info.spin_matrix(i, i)+.1;
    exp_domain(indices) = true;
end

if nnz(sim_domain) == 0 % there is no simulated spectrum here
    % do nothing
else
    
    if nnz(exp_domain)==0 || ... % there is no exp data here
            max(exp_fid_2draw(exp_domain)) < 10^-2 % there is no exp_data
        sim_fid_2draw = sim_fid_2draw./max(sim_fid_2draw);
    else
        sim_fid_2draw = max(exp_fid_2draw(exp_domain)).*(sim_fid_2draw./max(sim_fid_2draw));
    end
end

function Write_spectra_for_web(hObject, sim_ppm, sim_fid)
handles = guidata(hObject);
fpath = sprintf('%s/sim_spectra.csv', handles.folder_path);
fout = fopen(fpath, 'w');
for i=1:length(sim_ppm)
    fprintf(fout, '%f\t%f\n', sim_ppm(i), sim_fid(i));
end
fclose(fout);

function Draw_zigZag_water_DSS(ppm, handles, processing_info)
try
    axes(handles.axes2);
    indeces = ppm >= processing_info.water_min & ppm <= processing_info.water_max;
    ppm_new = ppm(indeces);
    coef = 1;
    step = 50;
    y_len = .02;
    for i=1:step:length(ppm_new)-step
        plot([ppm_new(i); ppm_new(i+step)], [-coef*y_len; coef*y_len], 'c');
        coef = -1*coef;
    end
    indeces = ppm >= processing_info.DSS_min & ppm <= processing_info.DSS_max;
    ppm_new = ppm(indeces);
    coef = 1;
    step = 100;
    for i=1:step:length(ppm_new)-step
        plot([ppm_new(i); ppm_new(i+step)], [-coef*y_len; coef*y_len], 'c');
        coef = -1*coef;
    end
catch ME
    Handle_error(handles, ME);
end

function calculate_rmsd(hObject, eventdata, sim_ppm, sim_fid)
global parameters_CS_range
try
    handles = guidata(hObject);

    [spec_fid, spec_domain, processing_info] = get_experimental_spectrum(hObject, eventdata, handles);

    step = min(min(diff(sim_ppm)), min(diff(spec_domain)));
    Min = max([min(sim_ppm), min(spec_domain)]);
    Max = min([max(sim_ppm), max(spec_domain)]);
    new_domain = Min:step:Max;

    sim_fid = interp1(sim_ppm, sim_fid,new_domain);
    spec_fid = interp1(spec_domain, spec_fid,new_domain);

    sim_fid(isnan(sim_fid)) = 0;
    spec_fid(isnan(spec_fid)) = 0;
    sim_fid = sim_fid-min(sim_fid);
    spec_fid = spec_fid-min(spec_fid);

    cs = diag(processing_info.spin_matrix);
    roi = false(size(new_domain));
    for i=1:length(cs)
        roi(new_domain > cs(i)-parameters_CS_range & new_domain < cs(i)+parameters_CS_range) = true;
    end

    %
    counter = 0;
    flag = false;
    selected_domain = [];
    for i=1:length(roi)
        if flag && ~roi(i)
            flag = false;
            selected_domain(counter, 2) = new_domain(i);
        end
        if roi(i) && ~flag
            flag = true;
            counter= counter+1;
            selected_domain(counter, 1) = new_domain(i);
        end
    end
    if flag % roi was true until the end of its length
        selected_domain(counter, 2) = new_domain(end);
    end
    SUM = 0;
    if get(handles.draw_roi, 'Value')
        figure('units','normalized','outerposition',[0 0 1 1])
    end
    
    if ~isempty(selected_domain)
        Total_len = 0;
        for i=1:size(selected_domain, 1)
            region = new_domain >= selected_domain(i, 1) & new_domain <= selected_domain(i, 2);
            
            reg_sim_fid  = sim_fid(region) -min(sim_fid(region));
            reg_spec_fid = spec_fid(region)-min(spec_fid(region));
            reg_sim_fid  = reg_sim_fid./max(reg_sim_fid);
            reg_spec_fid = reg_spec_fid./max(reg_spec_fid);

            if max(sim_fid(region)) == 0 
                reg_sim_fid = zeros(size(reg_sim_fid));
            end
            if max(spec_fid(region)) == 0 
                reg_spec_fid= zeros(size(reg_spec_fid));
            end
            if max(sim_fid(region)) == 0 || max(spec_fid(region)) == 0
                local_rmsd = max([sum(reg_sim_fid), sum(reg_spec_fid)]);
            else
                local_rmsd = sqrt(sum((reg_sim_fid-reg_spec_fid).^2)/nnz(region));
            end
            if get(handles.draw_roi, 'Value')
                subplot(1, size(selected_domain, 1), i), plot(reg_sim_fid, 'r'); hold on; plot(reg_spec_fid); title(local_rmsd);
            end
            SUM = SUM+sum((reg_sim_fid-reg_spec_fid).^2);
            Total_len = Total_len+nnz(region);
        end
        rmsd = sqrt(SUM/Total_len);
        rmsd_100 = rmsd/(1+log(sqrt(Total_len/100)));
        dist = rmsd_100; %sqrt(SUM); %sqrt(sum((sim_fid(roi)-spec_fid(roi)).^2));
    else
        SUM = 10^4;
        dist = SUM;
    end
    set(handles.RMSD, 'String', sprintf('Normalized RMSD: %.05f', dist));
    handles.roi_rmsd_value = dist;
    guidata(hObject, handles);
catch ME
    Handle_error(handles, ME);
end

function Auto_Save(hObject, eventdata, handles)
handles = guidata(hObject);
try
    if ~isfield(handles, 'Entry') || ~isfield(handles, 'folder_path')
        msgbox('there is no information to auto-save')
        return;
    end
    if ~isfield(handles, 'out_path')
       [FileName,PathName,~] = uiputfile(sprintf('%s/*.xml', handles.folder_path), 'Create output file');
       output_file = sprintf('%s/%s', PathName, FileName);
       handles.out_path = output_file;
       guidata(hObject, handles);
    else
        output_file = handles.out_path;
    end
    autosave_workspace(output_file, hObject, eventdata, handles)
catch ME
    Handle_error(handles, ME);
end

function autosave_workspace(output_file, hObject, eventdata, handles)
Entry = Update_Entry(hObject, eventdata, handles);

fout = fopen(output_file, 'w');
if fout < 1
    close(h);
    errordlg(sprintf('Could not create the output file!'));
    return
end

fprintf(fout, '<spin_simulation>\n');
fprintf(fout, '\t<version>%s</version>\n', handles.gissmo_version);
fprintf(fout, '\t<name>%s</name>\n', Entry.name);
fprintf(fout, '\t<ID>%s</ID>\n', Entry.ID);
if isempty(Entry.Src.DB)
        fprintf(fout, '\t<SRC name="%s" ID="%s"></SRC>\n', 'Empty', 'Empty');
    else
        fprintf(fout, '\t<SRC name="%s" ID="%s"></SRC>\n', Entry.Src.DB, Entry.Src.DB_id);
end
fprintf(fout, '\t<InChI>%s</InChI>\n', Entry.InChI);
fprintf(fout, '\t<comp_db_link>\n');
for i=1:size(Entry.DB_link, 1)
    fprintf(fout, '\t\t<db_link DBname="%s" Accession_code="%s"></db_link>\n', Entry.DB_link{i, 1}, Entry.DB_link{i, 2});
end
fprintf(fout, '\t</comp_db_link>\n');
fprintf(fout, '\t<mol_file_path>%s</mol_file_path>\n', Entry.mol_file_path);
fprintf(fout, '\t<experimental_spectrum>\n');
fprintf(fout, '\t\t<type>%s</type>\n', Entry.spectrum.type);
fprintf(fout, '\t\t<root_folder>%s</root_folder>\n', Entry.spectrum.path);
fprintf(fout, '\t</experimental_spectrum>\n');
if Entry.field_strength_flag == 1
    fprintf(fout, '\t<field_strength>%s</field_strength>\n', get(handles.field_sim_fid, 'String'));
    fprintf(fout, '\t<field_strength_applied_flag>1</field_strength_applied_flag>\n');
else
    fprintf(fout, '\t<field_strength>%d</field_strength>\n', Entry.field_strength);
    fprintf(fout, '\t<field_strength_applied_flag>0</field_strength_applied_flag>\n');
end
if Entry.num_points_flag == 1
    fprintf(fout, '\t<num_simulation_points>%d</num_simulation_points>\n', str2double(get(handles.numpoints, 'String')));
    fprintf(fout, '\t<num_simulation_points_applied_flag>1</num_simulation_points_applied_flag>\n');
else
    fprintf(fout, '\t<num_simulation_points>%d</num_simulation_points>\n', Entry.num_points);
    fprintf(fout, '\t<num_simulation_points_applied_flag>0</num_simulation_points_applied_flag>\n');
end
%fprintf(fout, '\t<Inchi_graph_image>%s</Inchi_graph_image>\n', Entry.Inchi_graph_image);
fprintf(fout, '\t<path_2D_image>%s</path_2D_image>\n', Entry.path_2D_image);
fprintf(fout, '\t<num_split_matrices>%d</num_split_matrices>\n', Entry.num_split_matrices);
if isfield(handles, 'roi_rmsd_value')
    fprintf(fout, '\t<roi_rmsd>%.05f</roi_rmsd>\n', handles.roi_rmsd_value);
end
fprintf(fout, '\t<notes>\n');
fprintf(fout, '\t\t<status>%s</status>\n', Entry.Notes.status);
content = strsplit(Entry.Notes.txt, '\n');
for i=1:length(content)
    fprintf(fout, '\t\t<note>%s</note>\n', content{i});
end
fprintf(fout, '\t</notes>\n');
for i=1:length(Entry.coupling_matrix)
    save_content_coupling_matrices(fout, Entry, i);
end
fprintf(fout, '</spin_simulation>');
fclose(fout);

guidata(hObject, handles);

function handles = incorporate_result_of_process(sim_ppm, sim_fid, exp_ppm, exp_fid, processing_info, hObject)
try
    handles = guidata(hObject);
    spin_matrix_index = handles.spin_space_index;
    handles.Entry.field_strength = processing_info.field;
    handles.Entry.field_strength_flag = get(handles.field_as_exp_data, 'Value');
    handles.Entry.num_points_flag = get(handles.num_point_of_sim_fid_checkbox, 'Value');
    handles.Entry.num_points = processing_info.numpoints;
    handles.Entry.coupling_matrix(spin_matrix_index).lw = sprintf('%.04f', processing_info.line_width);
    handles.Entry.coupling_matrix(spin_matrix_index).lorent = sprintf('%.04f', processing_info.lor_coeff);
    handles.Entry.coupling_matrix(spin_matrix_index).gauss = sprintf('%.04f', processing_info.gau_coeff);
    handles.Entry.coupling_matrix(spin_matrix_index).water.min = sprintf('%.04f', processing_info.water_min);
    handles.Entry.coupling_matrix(spin_matrix_index).water.max = sprintf('%.04f', processing_info.water_max);
    handles.Entry.coupling_matrix(spin_matrix_index).water.flag = sprintf('%d', get(handles.water_region_flag, 'Value'));
    handles.Entry.coupling_matrix(spin_matrix_index).DSS.min = sprintf('%.04f', processing_info.DSS_min);
    handles.Entry.coupling_matrix(spin_matrix_index).DSS.max = sprintf('%.04f', processing_info.DSS_max);
    handles.Entry.coupling_matrix(spin_matrix_index).DSS.flag = sprintf('%d', get(handles.DSS_region_flag, 'Value'));
    handles.Entry.coupling_matrix(spin_matrix_index).spin_names = processing_info.spin_names;
    handles.Entry.coupling_matrix(spin_matrix_index).coupling_matrix = processing_info.spin_matrix;
    handles.Entry.coupling_matrix(spin_matrix_index).CS = diag(processing_info.spin_matrix);
    handles.Entry.coupling_matrix(spin_matrix_index).spectrum = [reshape(sim_ppm, length(sim_ppm), 1), reshape(sim_fid, length(sim_fid), 1)];
    handles.Entry.coupling_matrix(spin_matrix_index).additional_coupling = processing_info.additional_couplings;
    handles.current_spectra.exp_fid = exp_fid;
    handles.current_spectra.exp_ppm = exp_ppm;
    handles.current_spectra.sim_ppm = sim_ppm;
    handles.current_spectra.sim_fid = sim_fid;
    handles.current_whole_spectra.exp_fid = exp_fid;
    handles.current_whole_spectra.exp_ppm = exp_ppm;
    handles.current_whole_spectra.sim_ppm = sim_ppm;
    handles.current_whole_spectra.sim_fid = sim_fid;
catch ME
    Handle_error(handles, ME);
end

function fid_2draw = apply_water_DSS_region(ppm, fid, processing_info)
[counts,centers] = hist(fid, 1000);
[~, index] = max(counts);
Mean = centers(index);
indeces = ppm >= processing_info.water_min & ppm <= processing_info.water_max;
fid(indeces) = Mean;
indeces = ppm >= processing_info.DSS_min & ppm <= processing_info.DSS_max;
fid(indeces) = Mean;
fid_2draw = fid;

function [roi_ppm, roi_fid] = apply_ROI_region(ppm, fid, processing_info, keyword)
roi_index = ppm > processing_info.ROI_min & ppm < processing_info.ROI_max;
if strcmp(keyword, 'sim') && isempty(roi_index)
    warndlg('It seems the ROI does not contain the spins CS. You may need to reprocess');
end
roi_ppm = ppm(roi_index);
roi_fid = fid(roi_index);

function processing_info = get_processing_package(hObject, eventdata, handles)
try
    handles = guidata(hObject);
    if ~isfield(handles, 'Entry')
        uiwait(errordlg('No Entry has been loaded to the workspace!'));
        return
    end
    if get(handles.num_point_of_sim_fid_checkbox, 'Value') % same as exp
        if isfield(handles, 'experimental_data') && isfield(handles.experimental_data, 'domain')
            numpoints = length(handles.experimental_data.domain);
        else
            uiwait(msgbox({'the number of points for the simulation is set to experimental data.', 'However, experimental data does not exist.', 'Moving on with the default value 2^15'}))
            numpoints = 2^15;
        end
    else
        numpoints =  str2double(get(handles.numpoints, 'String'));
    end
    if get(handles.field_as_exp_data, 'Value')
        if isfield(handles, 'experimental_data') && isfield(handles.experimental_data, 'field')
            field = handles.experimental_data.field;
        else
            uiwait(msgbox({'the number of points for the simulation is set to experimental data.', 'However, experimental data does not exist.', 'Moving on with the default value 500'}))
            field = 500;
        end
    else
        field = str2double(get(handles.field_sim_fid, 'String'));
    end
    
    if isfield(handles, 'experimental_data') && isfield(handles.experimental_data, 'domain')
        ppm = handles.experimental_data.domain;
        Max_domain = max(ppm);
        Min_domain = min(ppm);
        sw=(Max_domain-Min_domain)*field;
        dw= 2/sw;
    else
        sw=13*field;
        ppm = -1:.03:12;
        dw= 2/sw;
    end

    spin_matrix = get(handles.uitable1, 'Data');
    spin_names  = get(handles.uitable1, 'ColumnName');
    line_width = str2double(get(handles.lw_value, 'String'));
    lor_coeff = str2double(get(handles.lor_coeff, 'String'));
    gau_coeff = str2double(get(handles.gau_coeff, 'String'));
    if get(handles.water_region_flag, 'Value')
        water_min = str2double(get(handles.water_region_min, 'String'));
        water_max = str2double(get(handles.water_region_max, 'String'));
    else
        water_min = 0; 
        water_max = 0; 
    end
    if get(handles.DSS_region_flag, 'Value')
        DSS_min = str2double(get(handles.DSS_region_min, 'String'));
        DSS_max = str2double(get(handles.DSS_region_max, 'String'));
    else
        DSS_min = 0; 
        DSS_max = 0; 
    end
    ROI_min = str2double(get(handles.ROI_min, 'String'));
    ROI_max = str2double(get(handles.ROI_max, 'String'));

    processing_info.dw = dw;
    processing_info.ppm = ppm;
    processing_info.spin_matrix = spin_matrix ;
    processing_info.spin_names  = spin_names;
    processing_info.line_width = line_width;
    processing_info.numpoints =  numpoints;
    processing_info.field = field;
    processing_info.lor_coeff = lor_coeff;
    processing_info.gau_coeff = gau_coeff;
    processing_info.water_min = water_min; 
    processing_info.water_max = water_max; 
    processing_info.DSS_min = DSS_min; 
    processing_info.DSS_max = DSS_max; 
    processing_info.ROI_min = ROI_min;
    processing_info.ROI_max = ROI_max;
    processing_info.additional_couplings = handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling;
    processing_info.additional_couplings_groups = handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling_groups;
    processing_info.spin_matrix_changed = handles.spin_matrix_changed;
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix)> 1
        processing_info.spin_matrix_changed = 1;
    end
catch ME
    Handle_error(handles, ME);
end

function uitable1_CellSelectionCallback(hObject, eventdata, handles)
set(handles.uitable1,'UserData',eventdata);
guidata(hObject, handles);

function copy_select_cells_from_spin_matrix_Callback(hObject, eventdata, handles)
Indices = handles.uitable1.UserData.Indices;
if isempty(Indices) || size(Indices, 1) < 2
    errordlg('You need to select at least two cells from the table', 'It is not clear which cells to copy!');
    return
end
handles.gui_table_copy_indices = Indices;
guidata(hObject, handles)
uiwait(msgbox(sprintf('%d cells have been copied', size(Indices, 1))));

function paste_selected_cells_from_spin_matrix_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'gui_table_copy_indices')
    errordlg('You need to copy cells first!');
    return
end
try
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end
catch
    return
end
Indices = handles.uitable1.UserData.Indices;
if size(handles.gui_table_copy_indices, 1) ~= size(Indices, 1)
    errordlg({'You need to select cells that you want to paste to.', sprintf('You copied %d cells. select the same number of cells to paste', size(handles.gui_table_copy_indices, 1))});
    return
end
matrix = handles.Entry.coupling_matrix(handles.spin_space_index).coupling_matrix;
for i=1:size(Indices, 1)
    matrix(Indices(i, 1), Indices(i, 2)) = matrix(handles.gui_table_copy_indices(i, 1), handles.gui_table_copy_indices(i, 2));
end
handles.Entry.coupling_matrix(handles.spin_space_index).coupling_matrix = matrix;
handles.Entry.coupling_matrix(handles.spin_space_index).CS = diag(matrix);
handles = rmfield(handles, 'gui_table_copy_indices');
guidata(hObject, handles);
Populated_workspace(hObject, eventdata, handles);

function Swap_two_entries_Callback(hObject, eventdata, handles)
Indices = handles.uitable1.UserData.Indices;
if isempty(Indices) || size(Indices, 1) ~= 2
    errordlg('You need to select two entries from the table', 'It is not clear which entries to swap!');
    return
end
try
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end
catch
    return
end
data = get(handles.uitable1, 'Data');
temp = data(Indices(1, 1), Indices(1, 2));
data(Indices(1, 1), Indices(1, 2)) = data(Indices(2, 1), Indices(2, 2));
data(Indices(2, 1), Indices(2, 2)) = temp;
data = update_lower_triangle(data);
set(handles.uitable1, 'data', data);
guidata(hObject, handles);

function data = update_lower_triangle(data)
L = size(data, 1);
for i=1:L
    for j=i+1:L
        data(j, i) = data(i, j);
    end
end

function get_ROI_Callback(hObject, eventdata, handles)
try
    XLIM = xlim(handles.axes1);
    set(handles.ROI_min, 'String', sprintf('%.03f', XLIM(1)));
    set(handles.ROI_max, 'String', sprintf('%.03f', XLIM(2)));

    if ~isfield(handles, 'current_whole_spectra') || ~isfield(handles.current_whole_spectra, 'exp_fid') || ~isfield(handles.current_whole_spectra, 'sim_ppm')
        guidata(hObject, handles);
        return
    end
    exp_fid = handles.current_whole_spectra.exp_fid;
    exp_ppm = handles.current_whole_spectra.exp_ppm;
    sim_ppm = handles.current_whole_spectra.sim_ppm;
    sim_fid = handles.current_whole_spectra.sim_fid;


    exp_domain_indices = exp_ppm >= XLIM(1) & exp_ppm <= XLIM(2);
    handles.current_spectra.exp_ppm = exp_ppm(exp_domain_indices);
    handles.current_spectra.exp_fid = exp_fid(exp_domain_indices);

    sim_domain_indices = sim_ppm>=XLIM(1) & sim_ppm <= XLIM(2);
    handles.current_spectra.sim_ppm = sim_ppm(sim_domain_indices);
    handles.current_spectra.sim_fid = sim_fid(sim_domain_indices);
    guidata(hObject, handles);
    Show_overlay(hObject, eventdata, handles);
catch ME
    Handle_error(handles, ME);
end

function get_spec_info_Callback(hObject, eventdata, handles)
%Get_Spec_Info_Called(hObject, eventdata, handles)

function Export_as_html_Callback(hObject, eventdata, handles)
try
    xml2html(hObject, eventdata, handles)
catch ME
    Handle_error(handles, ME);
end

function xml2html(hObject, eventdata, handles)

[FileName,PathName,~] = uiputfile('.html');
out_path = sprintf('%s/%s', PathName, FileName);
fout = fopen(out_path, 'w');
Entry = handles.Entry;
if isfield(handles, 'gissmo_version')
	fprintf(fout, '<html><head><title>GISSMO @ NMRFAM</title></head>\n<body><b>Spin Simulation @ NMRFAM v. %s</b><br><br>\n', handles.gissmo_version);
else
	fprintf(fout, '<html><head><title>GISSMO @ NMRFAM</title></head>\n<body><b>Spin Simulation @ NMRFAM v. 2.0</b><br><br>\n');
end
fprintf(fout, '<b>%s(%s)</b><br>\n', Entry.name, Entry.ID);
fprintf(fout, '<b>Status:</b>%s<br>\n', Entry.Notes.status);
content = strsplit(Entry.Notes.txt, '\n');
if ~isempty(content)
    fprintf(fout, '<b>Notes: </b><br>');
    for i=1:length(content)
        fprintf(fout, '&nbsp;&nbsp;&nbsp;%s<br>\n', content{i});
    end
end
fprintf(fout, '<b>Field strength:</b> %f<br>\n', Entry.field_strength);
fprintf(fout, '<b>InChI: </b>%s<br>\n', Entry.InChI);
fprintf(fout, '<b>Num. sub-matrices: </b>%d<br>\n', Entry.num_split_matrices);

fprintf(fout, '<table border="2">\n');
for i=1:length(Entry.coupling_matrix)
    fprintf(fout, '<tr><td>\n');
    if i == 1
        fprintf(fout, '<b>Main spin matrix</b><br>');
    else
        fprintf(fout, '<b>Sub-matrix(%d)</b><br>', i);
    end
    fprintf(fout, 'Line width: %s<br>\n', Entry.coupling_matrix(i).lw);
    fprintf(fout, 'Gaussian coefficience: %s<br>\n', Entry.coupling_matrix(i).gauss);
    fprintf(fout, 'Lorentzian coefficience: %s<br>\n', Entry.coupling_matrix(i).lorent);
    additional_couplins = Entry.coupling_matrix(i).additional_coupling_groups;
    if ~isempty(additional_couplins)
        fprintf(fout, '<table border="1">\n');
        fprintf(fout, '<tr><td>spin name</td><td>additional coupling</td></tr>\n');
        for j=1:size(additional_couplins)
            fprintf(fout, '<tr><td>%s</td><td>%.03f</td></tr>\n', Entry.coupling_matrix(i).spin_names{additional_couplins(j, 1)}, additional_couplins(j, 2));
        end
        fprintf(fout, '</table>\n');
    end
    table = Entry.coupling_matrix(i).coupling_matrix;
    names = Entry.coupling_matrix(i).spin_names;
    fprintf(fout, '<table border="1">\n');
    fprintf(fout, '<tr><td></td>');
    for j=1:length(names)
        fprintf(fout, '<td>%s</td>', names{j});
    end
    fprintf(fout, '</tr>\n');
    for k=1:length(names)
        fprintf(fout, '<tr><td>%s</td>', names{k});
        for j=1:size(table, 2)
            fprintf(fout, '<td>%.04f</td>', table(k, j));
        end
        fprintf(fout, '</tr>\n');
    end
    fprintf(fout, '</table>\n');
    fprintf(fout, '</td></tr>\n');
end
fprintf(fout, '</table>\n');
fprintf(fout, '</body>\n</html>\n');
fclose(fout);
web(out_path,'-new')

function Get_Spectral_Info_Callback(hObject, eventdata, handles)
Get_Spec_Info_Called(hObject, eventdata, handles)

function Get_Spec_Info_Called(hObject, eventdata, handles)
try
    msgbox({'draw a box around a region of the experimental spctrum', 'the program will wait for you to draw a box'}, 'Hint: get spectral info')
    uiwait(gcf);
    rect = getrect(handles.axes1);
    xmin = rect(1);
    width = rect(3);
    spectrum = handles.experimental_data.spectrum;
    spectrum = Mean_zero_spectrum(spectrum);
    spectrum = spectrum./max(spectrum);
    processing_info = get_processing_package(hObject, eventdata, handles);
    integral_coeff = length(processing_info.spin_names)/sum(spectrum);
    domain = handles.experimental_data.domain;
    region = domain > xmin & domain < xmin+width;
    selected_spectrum = spectrum(region);
    selected_domain = domain(region);
    spectralInfo(selected_domain, selected_spectrum, processing_info.field, integral_coeff);
catch ME
    Handle_error(handles, ME);
end

function Entry = clear_submatrices(Entry)
Entry.num_split_matrices = 0;
remove = false(length(Entry.coupling_matrix), 1);
remove(2:end) = true;

function split_spin_matrix_Callback(hObject, eventdata, handles)
try
    choice = questdlg({'After spliting the matrix you will not be able to change the atoms names while processing a sub-matrix', 'Would you like to proceed?'}, ...
    'Spliting a compound', 'Yes', 'No','Yes');
    switch choice
        case 'No'
            return;
    end
    Entry = handles.Entry;
    if Entry.num_split_matrices ~= 0
        choice = questdlg({'There are sub matrices for this compound.', 'Whould you like to overwrite them?'}, 'Overwriting current sub matrices', 'Yes', 'No', 'No');
        switch choice
            case 'Yes'
                Entry = clear_submatrices(Entry);
                if get(handles.checkbox5, 'Value')
                    Auto_Save(hObject, eventdata, handles);
                end

            case 'No'
                return
        end
    end
    % cleaning the merged spectrum
    Entry.coupling_matrix(1).spectrum = [];

    handles.Entry.coupling_matrix(1).spectrum = [];
    handles.current_spectra.sim_ppm = [];
    handles.current_spectra.sim_fid = [];

    handles.current_whole_spectra.sim_ppm = [];
    handles.current_whole_spectra.sim_fid = [];
    
    setappdata(0,'number_of_subMatrices', 0);
    Number_of_subMatrices();
    uiwait(gcf); 
    number_of_subMatrices = getappdata(0,'number_of_subMatrices');
    if number_of_subMatrices == 0
        return
    end
    processing_info = get_processing_package(hObject, eventdata, handles);
    setappdata(0,'submatrices', []);
    Split_matrix(number_of_subMatrices, processing_info.spin_names)
    uiwait(gcf);
    submatrices = getappdata(0,'submatrices');
    if isempty(submatrices)
        return
    end

    % filling entry
    Entry.num_split_matrices = size(submatrices, 1);
    Entry = Fill_created_submatrices(Entry, submatrices);

    Show_subGroups(Entry);
    handles.Entry = Entry;
    handles.spin_space_index = 1;
    guidata(hObject, handles);
catch ME
    Handle_error(handles, ME);
end

if get(handles.checkbox5, 'Value')
    Auto_Save(hObject, eventdata, handles);
end

function Entry = Fill_created_submatrices(Entry, submatrices)

    for i=1:length(submatrices)
        index = i+1;
        indices = submatrices{i};
        Entry.coupling_matrix(index).label = sprintf('sub_matrix_%d', i);
        Entry.coupling_matrix(index).index = index;
        Entry.coupling_matrix(index).lw = Entry.coupling_matrix(1).lw;
        Entry.coupling_matrix(index).lorent = Entry.coupling_matrix(1).lorent;
        Entry.coupling_matrix(index).gauss = Entry.coupling_matrix(1).gauss;
        Entry.coupling_matrix(index).water = Entry.coupling_matrix(1).water;
        Entry.coupling_matrix(index).DSS = Entry.coupling_matrix(1).DSS;
        Entry.coupling_matrix(index).additional_coupling = [];
        Entry.coupling_matrix(index).additional_coupling_groups = {};
        Entry.coupling_matrix(index).CS = Entry.coupling_matrix(1).CS(indices);
        Entry.coupling_matrix(index).coupling_matrix = Entry.coupling_matrix(1).coupling_matrix;
        Entry.coupling_matrix(index).spin_names = Entry.coupling_matrix(1).spin_names;
        remove = true(size(Entry.coupling_matrix(index).coupling_matrix, 1), 1);
        remove(indices) = false;
        Entry.coupling_matrix(index).coupling_matrix(:, remove) = [];
        Entry.coupling_matrix(index).coupling_matrix(remove, :) = [];
        Entry.coupling_matrix(index).spin_names(remove) = [];
        Entry.coupling_matrix(index).peak_list = [];
        Entry.coupling_matrix(index).spectrum = [];
    end

function Show_sub_matrices_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'Entry') || ~isfield(handles.Entry, 'num_split_matrices')
    msgbox('There is no information on sub-matrices')
    uiwait(gcf);
    return
end
if handles.Entry.num_split_matrices == 0
    msgbox('Number of submatrices equals zeros. There are no sub-matrices');
    uiwait(gcf);
    return
end
Show_subGroups(handles.Entry);

function Process_a_sub_matrix_Callback(hObject, eventdata, handles)
try 
    if ~isfield(handles, 'Entry')
        return;
    end
    Entry = handles.Entry;

    % cleaning the merged spectrum
    Entry.coupling_matrix(1).spectrum = [];

    % to remove backup of a disable/enable feature
    index = handles.spin_space_index;
    if isfield(handles, 'backup') && isfield(handles.backup, 'couplings') && size(handles.backup.couplings.coupling_matrix, 1) > size(handles.Entry.coupling_matrix(index).coupling_matrix, 1)
        uiwait(msgbox({'There are disabled spins in the current spin matrix', 'You will be asked to enable all of the spins'}))
        uiwait(disable_enable_spins_Callback(hObject, eventdata, handles))
        handles = guidata(hObject);
    end

    if ~isfield(Entry, 'num_split_matrices') || Entry.num_split_matrices == 0
        errordlg('You need to split the matrix first, then process a sub-matrix');
        return
    end
    setappdata(0,'chosen_subMatrix_index', 0);
    Choose_submatrix_to_process(Entry.num_split_matrices)
    uiwait(gcf);
    submatrix_index = getappdata(0,'chosen_subMatrix_index');
    if submatrix_index < 2 
        errordlg('Please choose a sub matrix to process');
        return
    end

    set(handles.compound_name, 'String', sprintf('%s(%s)',Entry.ID, Entry.coupling_matrix(submatrix_index).label));
    Entry.coupling_matrix(submatrix_index).spectrum = [];
    handles.Entry = Entry;
    handles.spin_matrix_changed = 1;
    handles.spin_space_index = submatrix_index;
    
    
    guidata(hObject, handles);
    Populated_workspace(hObject, eventdata, handles);
catch ME
    Handle_error(handles, ME);
end

function copy_paste_sub_matrices_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if ~isfield(handles, 'Entry') || length(handles.Entry.coupling_matrix) <3
    uiwait(msgbox('There should be at least two sub matrices'));
    return;
end
sub_matrices_info = cell(length(handles.Entry.coupling_matrix)-1, 1);
for i=1:length(sub_matrices_info)
    sub_matrices_info{i} = handles.Entry.coupling_matrix(i+1).spin_names;
end
get_indices_for_copyPaste_sub_matrices(sub_matrices_info);
uiwait(gcf);
indices = getappdata(0, 'cpSubMatrixindices');
if isempty(indices)
    return
end
if length(handles.Entry.coupling_matrix(indices(1)).CS) ~= length(handles.Entry.coupling_matrix(indices(2)).CS)
    uiwait(msgbox('sub matrices should have the same size'));
    return
end

source_matrix = handles.Entry.coupling_matrix(indices(1)).coupling_matrix;
source_CS = handles.Entry.coupling_matrix(indices(1)).CS;
source_add_coupling = handles.Entry.coupling_matrix(indices(1)).additional_coupling;
source_add_coupling_group = handles.Entry.coupling_matrix(indices(1)).additional_coupling_groups;
if indices(3) == 1
    source_matrix = (flip(fliplr(source_matrix)))';
    source_CS = diag(source_matrix);
    map = (size(source_matrix, 1):-1:1);
    for i=1:size(source_add_coupling, 1)
        source_add_coupling(i, 1) = map(source_add_coupling(i, 1));
    end
    for i=1:size(source_add_coupling_group, 1)
        source_add_coupling_group(i, 1) = map(source_add_coupling_group(i, 1));
    end
end
handles.Entry.coupling_matrix(indices(2)).coupling_matrix = source_matrix;
handles.Entry.coupling_matrix(indices(2)).CS = source_CS;
handles.Entry.coupling_matrix(indices(2)).additional_coupling = source_add_coupling;
handles.Entry.coupling_matrix(indices(2)).additional_coupling_groups = source_add_coupling_group;

guidata(hObject, handles);
uiwait(msgbox('Completed!'));
Populated_workspace(hObject, eventdata, handles);

function Merge_sub_matrices_Callback(hObject, eventdata, handles)
try
    handles = guidata(hObject);
    if ~isfield(handles, 'Entry') || length(handles.Entry.coupling_matrix) <2
        return;
    end
    for i=2:length(handles.Entry.coupling_matrix)
        if isempty(handles.Entry.coupling_matrix(i).spectrum)
            errordlg(sprintf('The sub-matrix(%s) was not processed! Please consider processing all sub-matrices before merging them.', handles.Entry.coupling_matrix(i).label));
            return
        end
    end
    
    
    inputs.experimental_data = handles.experimental_data;
    inputs.Entry = handles.Entry;
    Merge_submatrices(inputs);
    uiwait(gcf);
    output = getappdata(0, 'scaled_merged_data');
    ppm = output.ppm;
    fid = output.fid;
    
    InterfaceObj=findobj(handles.figure1,'Enable','on');
    set(InterfaceObj,'Enable','off');
    h = msgbox('please wait', 'Merging sub matrices');
    handles.Entry.coupling_matrix(1).spectrum = [ppm, fid];
    handles.Entry.coupling_matrix(1).coupling_matrix = zeros(size(handles.Entry.coupling_matrix(1).coupling_matrix));
    for i=2:length(handles.Entry.coupling_matrix)
        c_names = handles.Entry.coupling_matrix(i).spin_names;
        indices = [];
        for j=1:length(c_names)
            index = find(strcmp(c_names{j}, handles.Entry.coupling_matrix(1).spin_names));
            indices = [indices, index];
        end
        handles.Entry.coupling_matrix(1).CS(indices) = handles.Entry.coupling_matrix(i).CS;
        handles.Entry.coupling_matrix(1).coupling_matrix(indices, indices) = handles.Entry.coupling_matrix(i).coupling_matrix;
    end
    to_be_merged_additional_couplints = [];
    to_be_merged_ac_counter = 0;
    for i=2:length(handles.Entry.coupling_matrix)
        if ~isempty(handles.Entry.coupling_matrix(i).additional_coupling_groups)
            to_be_merged_ac_counter = to_be_merged_ac_counter+1;
            to_be_merged_additional_couplints(to_be_merged_ac_counter).grouped = handles.Entry.coupling_matrix(i).additional_coupling_groups;
            to_be_merged_additional_couplints(to_be_merged_ac_counter).spin_names = handles.Entry.coupling_matrix(i).spin_names;
        end
    end
    if ~isempty(to_be_merged_additional_couplints)
        choice = questdlg({'There are additional couplings in the sub-matrices.', 'Would you like to add them to the merged spin matrix?'}, 'Merging additional couplings', 'Yes', 'No', 'Yes');
        if strcmp(choice, 'Yes')
            input.merged_spin_names = handles.Entry.coupling_matrix(1).spin_names;
            input.to_be_merged_additional_couplints = to_be_merged_additional_couplints;
            Merge_additional_couplings(input);
            uiwait(gcf);
            output_addComp = getappdata(0, 'bring_additional_coupling_2merged');
            table_out = output_addComp.table_out;
            for i=1:size(table_out, 1)
                if table_out(i, 1) ~= 0 && table_out(i, 2) ~= 0
                    handles.Entry.coupling_matrix(1).coupling_matrix(table_out(i, 1), table_out(i, 2)) = table_out(i, 3);
                end
            end
            if ~isempty(output_addComp.note)
                for i=1:length(output_addComp.note)
                    handles.Entry.Notes.txt = sprintf('%s\n%s', handles.Entry.Notes.txt, output_addComp.note{i});
                end
            end
        end
    end
    set(InterfaceObj,'Enable','on');
    close(h);
    handles.spin_space_index = 1;
    handles.spin_matrix_changed = 1;
    guidata(hObject, handles);
    Populated_workspace(hObject, eventdata, handles);
catch ME
    if exist('InterfaceObj', 'var')
        set(InterfaceObj,'Enable','on');
    end
    Handle_error(handles, ME);
end

function Label_additional_couplings_Callback(hObject, eventdata, handles)
try
    handles = guidata(hObject);
    if handles.spin_space_index ~= 1
        uiwait(msgbox('You will be able to assign/label additional couplings while merging the split matrices. Abroting ...'))
        return
    end
    if ~isfield(handles, 'Entry') || ~isfield(handles.Entry, 'coupling_matrix') || ...
            ~isfield(handles.Entry.coupling_matrix(handles.spin_space_index), 'additional_coupling_groups') || ...
            isempty(handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling_groups)
        uiwait(msgbox('There is no additional coupling to be labeled!'))
        return;
    end

    index = handles.spin_space_index;
    to_be_merged_additional_couplints(1).grouped = handles.Entry.coupling_matrix(index).additional_coupling_groups;
    to_be_merged_additional_couplints(1).spin_names = handles.Entry.coupling_matrix(index).spin_names;
    
    input.merged_spin_names = handles.Entry.coupling_matrix(1).spin_names;
    input.to_be_merged_additional_couplints = to_be_merged_additional_couplints;
    Merge_additional_couplings(input);
    uiwait(gcf);
    output_addComp = getappdata(0, 'bring_additional_coupling_2merged');
    table_out = output_addComp.table_out;
    for i=1:size(table_out, 1)
        if table_out(i, 1) ~= 0 && table_out(i, 2) ~= 0
            handles.Entry.coupling_matrix(1).coupling_matrix(table_out(i, 1), table_out(i, 2)) = table_out(i, 3);
        end
    end
    if ~isempty(output_addComp.note)
        for i=1:length(output_addComp.note)
            handles.Entry.Notes.txt = sprintf('%s\n%s', handles.Entry.Notes.txt, output_addComp.note{i});
        end
    end
    guidata(hObject, handles);
    uiwait(msgbox('The additional couplings have been labeled!'))
catch ME
    Handle_error(handles, ME);
end

function Adjust_peak_amplitude_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'current_spectra') ||~isfield(handles.current_spectra, 'exp_fid')
    return
end
data.exp_fid = handles.current_spectra.exp_fid;
data.exp_ppm = handles.current_spectra.exp_ppm;
data.sim_fid = handles.current_spectra.sim_fid;
data.sim_ppm = handles.current_spectra.sim_ppm;
setappdata(0, 'adjusted_peak_scale', 1);
Adjust_peak_amp(data);
uiwait(gcf);
scale = getappdata(0, 'adjusted_peak_scale');
handles.Entry.coupling_matrix(handles.spin_space_index).spectrum(:, 2) = scale.*handles.current_spectra.sim_fid;
handles.current_spectra.sim_fid = scale.*handles.current_spectra.sim_fid;
guidata(hObject, handles);
Show_overlay(hObject, eventdata, handles)

function Show_overlay(hObject, eventdata, handles)
handles = guidata(hObject);
axes(handles.axes2);
hold off;plot([0;1], [0;0]);hold off;
MIN = -2;
MAX = 12;
if ~isempty(handles.current_spectra.sim_fid)
    plot(handles.current_spectra.sim_ppm, handles.current_spectra.sim_fid, 'r'); hold on
    MIN = min(handles.current_spectra.sim_ppm);
    MAX = max(handles.current_spectra.sim_ppm);
end
plot(handles.current_spectra.exp_ppm, handles.current_spectra.exp_fid, 'b');
MIN = min([MIN, min(handles.current_spectra.exp_ppm)]);
MAX = max([MAX, max(handles.current_spectra.exp_ppm)]);
xlim([MIN MAX])
set(gca, 'XDir', 'reverse');
set(gca, 'ytick', []);
hold off

function delete_submatrices_Callback(hObject, eventdata, handles)
choices = questdlg('You are about to delete sub-matrices. Do you want to continue?', 'Deleting sub-matrices', 'Yes', 'No', 'No');
if strcmp(choices, 'Yes')
    handles.Entry.num_split_matrices = 0;
    for i=length(handles.Entry.coupling_matrix):-1:2
        handles.Entry.coupling_matrix(i) = [];
        
    end
end
handles.spin_space_index = 1;
handles.spin_matrix_changed = 1;
guidata(hObject, handles);
Populated_workspace(hObject, eventdata, handles);
if get(handles.checkbox5, 'Value')
    Auto_Save(hObject, eventdata, handles);
end

function rename_atoms_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry') 
        return
    end

    Prev_names = handles.Entry.coupling_matrix(1).spin_names;
    Adjust_atom_names(Prev_names);
    uiwait(gcf); 
    varargout = getappdata(0,'evalue');
    atom_names = varargout;
    handles.Entry.coupling_matrix(1).spin_names = atom_names;
    set(handles.uitable1, 'ColumnName', atom_names);
    set(handles.uitable1, 'RowName', atom_names);
    for i=2:length(handles.Entry.coupling_matrix)
        old_names = handles.Entry.coupling_matrix(i).spin_names;
        new_names = cell(size(old_names));
        for j=1:length(old_names)
            bool_vect = strcmp(old_names{j}, Prev_names);
            new_names{j} = atom_names{bool_vect};
        end
        handles.Entry.coupling_matrix(i).spin_names = new_names;
    end
    drawnow
    guidata(hObject, handles);
catch ME
    Handle_error(handles, ME);
end

if get(handles.checkbox5, 'Value')
    Auto_Save(hObject, eventdata, handles);
end

function Optimize_additional_couplings_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'current_whole_spectra')
        msgbox('you need to process the spin matrix')
        return
    end
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end
    % in_spectrum = handles.current_whole_spectra.exp_fid;
    % in_domain   = handles.current_whole_spectra.exp_ppm;
    % in_processing_info = get_processing_package(hObject, eventdata, handles);

    guidata(hObject, handles);
    [in_spectrum, in_domain, in_processing_info] = get_experimental_spectrum(hObject, eventdata, handles);

    if ~isfield(in_processing_info, 'additional_couplings') || isempty(in_processing_info.additional_couplings)
        msgbox('no additional coupling found!')
        return;
    end

    choose_additional_coupling_for_optimization(in_processing_info);
    uiwait(gcf);
    selected_groups = getappdata(0, 'selected_add_coupling_groups');
    if isempty(selected_groups)
        return;
    end

    [new_coupling_matrix, msg] = optimize_additional_couplings(in_processing_info, in_domain, in_spectrum, selected_groups);

    handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling_groups = new_coupling_matrix;
    handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling = new_coupling_matrix(:, 1:2);
    handles.spin_matrix_changed = 1;
    guidata(hObject, handles);
    msgbox({'optimization completed with the following message:', msg, 'The spin matrix has been updated. You may process!'}, 'Optimization report:')
    uiwait(gcf);
    drawnow
catch ME
    Handle_error(handles, ME);
end

function Optimiza_lineShape_Callback(hObject, eventdata, handles)
try
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end
catch
    return
end
try
    Choose_lw_optimization_region
    uiwait(gcf);
    val = getappdata(0,'lw_optimization_region');
    if val == 0
        return
    end

    spectrum = handles.current_whole_spectra.exp_fid;
    domain   = handles.current_whole_spectra.exp_ppm;

    processing_info = get_processing_package(hObject, eventdata, handles);

    if val == 1 % entire spectrum
        processing_info.ROI_min = min(domain);
        processing_info.ROI_max = max(domain);
    else % ROI
        roi = xlim(handles.axes2);
        processing_info.ROI_min = roi(1);
        processing_info.ROI_max = roi(2);
    end

    vector_out = optimize_lw_and_coeffs(processing_info, domain, spectrum);
    set(handles.lw_value, 'String', sprintf('%.03f', vector_out(1)));
    set(handles.lor_coeff, 'String', sprintf('%.03f', vector_out(2)));
    set(handles.gau_coeff, 'String', sprintf('%.03f', vector_out(3)));
    guidata(hObject, handles);
    msgbox({'optimization completed.', 'You may "Process".'}, 'Optimization report:')
    uiwait(gcf);
    drawnow
catch ME
    Handle_error(handles, ME);
end

function Optimization_butt_on_main_gui_Callback(hObject, eventdata, handles)
try
    Optimization_over_selected_cells_Callback(hObject, eventdata, handles)
catch ME
    Handle_error(handles, ME);
end

function Optimization_over_selected_cells_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'exp_fid')
    return
end
if isempty(handles.uitable1.UserData)
    errordlg('You need to select at least one variable from the table', 'It is not clear which variable to optimize!');
    return
end
Indices = handles.uitable1.UserData.Indices;
if isempty(Indices)
    errordlg('You need to select at least one variable from the table', 'It is not clear which variable to optimize!');
    return
end
[err, Indices] = Check_lower_triangle(Indices);
if err
    return
end
if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
    uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
    return
end

% spectrum = handles.current_spectra.exp_fid;
% domain = handles.current_spectra.exp_ppm;
% processing_info = get_processing_package(hObject, eventdata, handles);

guidata(hObject, handles);
[spectrum, domain, processing_info] = get_experimental_spectrum(hObject, eventdata, handles);


[matrix_out, msg] = local_optimization(Indices, processing_info, domain, spectrum);

matrix_out = update_lower_triangle(matrix_out);
set(handles.uitable1, 'Data', matrix_out);
guidata(hObject, handles);
msgbox({'optimization completed with the following message:', msg}, 'Optimization report:')
uiwait(gcf);
drawnow

function AB_optimization_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'Entry') || ~isfield(handles.Entry, 'coupling_matrix') || ~isfield(handles, 'spin_space_index')
    uiwait(msgbox('Need to process the spin matrix'));
    return
end
if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'exp_fid')
    uiwait(msgbox('Need to process the spin matrix first!'))
    return
end
try
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end
catch
    return
end
input.atom_names = handles.Entry.coupling_matrix(handles.spin_space_index).spin_names;
Get_AB_spins(input);
uiwait(gcf);
AB_spins_indices = getappdata(0, 'AB_spins_flag');
if isempty(AB_spins_indices)
    return
end
guidata(hObject, handles);
[spectrum, domain, processing_info] = get_experimental_spectrum(hObject, eventdata, handles);
[matrix_out, msg] = AB_optimization(AB_spins_indices, processing_info, domain, spectrum);
matrix_out = update_lower_triangle(matrix_out);
set(handles.uitable1, 'Data', matrix_out);
guidata(hObject, handles);
msgbox({'optimization completed with the following message:', msg}, 'Optimization report:')
uiwait(gcf);
drawnow

function ABx_optimization_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry') || ~isfield(handles.Entry, 'coupling_matrix') || ~isfield(handles, 'spin_space_index')
        uiwait(msgbox('Need to process the spin matrix'));
        return
    end
    if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'exp_fid')
        uiwait(msgbox('Need to process the spin matrix'));
        return
    end
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end
    % msgbox({'Optimization on a ABx system:', 'This option assumes you approximately adjusted the chemical shifts values'});
    % uiwait(gcf);
    atom_names = handles.Entry.coupling_matrix(handles.spin_space_index).spin_names;
    Guided_optimization(atom_names);
    uiwait(gcf);
    ABx_oprimization_var = getappdata(0,'ABx_oprimization_var');
    if isempty(ABx_oprimization_var)
        return
    end

    guidata(hObject, handles);
    [spectrum, domain, processing_info] = get_experimental_spectrum(hObject, eventdata, handles);

    %processing_info = get_processing_package(hObject, eventdata, handles);

    [matrix_out, msg] = ABx_optimization(ABx_oprimization_var, processing_info, domain, spectrum);

    matrix_out = update_lower_triangle(matrix_out);
    set(handles.uitable1, 'Data', matrix_out);
    guidata(hObject, handles);
    msgbox({'optimization completed with the following message:', msg}, 'Optimization report:')
    uiwait(gcf);
    drawnow
catch ME
    Handle_error(handles, ME);
end

function optimize_quick_BB_AB_XY_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry') || ~isfield(handles.Entry, 'coupling_matrix') || ~isfield(handles, 'spin_space_index')
        uiwait(msgbox('Need to process the spin matrix'));
        return
    end
    if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'exp_fid')
        uiwait(msgbox('Need to process the spin matrix'));
        return
    end
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end
    Indices = handles.uitable1.UserData.Indices;
    AB_indices = unique(Indices(:, 1));
    XY_indices = unique(Indices(:, 2));
    if size(Indices, 1) ~= 4
        uiwait(msgbox('Need to select 4 cells from the spin matrix'));
        return
    end
    if length(AB_indices) ~= 2 || length(XY_indices) ~= 2
        uiwait(msgbox('More than 2 AB or XY spins have been selected'));
        return
    end
    ABx_oprimization_var.strong = AB_indices;
    ABx_oprimization_var.weak = XY_indices;
    guidata(hObject, handles);
    [spectrum, domain, processing_info] = get_experimental_spectrum(hObject, eventdata, handles);
    [matrix_out, msg] = AB_XY_quick_optimization(ABx_oprimization_var, processing_info, domain, spectrum);

    matrix_out = update_lower_triangle(matrix_out);
    set(handles.uitable1, 'Data', matrix_out);
    guidata(hObject, handles);
    uiwait(msgbox({'optimization completed with the following message:', msg}, 'Optimization report:'));
    drawnow
catch ME
    Handle_error(handles, ME);
end
% in_ABx_oprimization_var
% 
% in_ABx_oprimization_var = 
% 
%   struct with fields:
% 
%          strong: [2×1 double]
%            weak: [2×1 double]
%     strong_flag: 0
%       weak_flag: 1
%           angle: 30
% 
% in_ABx_oprimization_var.strong
% 
% ans =
% 
%      1
%      2
% 
% in_ABx_oprimization_var.weak
% 
% ans =
% 
%      3
%      4


function [spectrum, domain, processing_info] = get_experimental_spectrum(hObject, eventdata, handles)
handles = guidata(hObject);

%spectrum = handles.current_spectra.exp_fid;
%domain = handles.current_spectra.exp_ppm;
processing_info = get_processing_package(hObject, eventdata, handles);
domain = handles.experimental_data.domain;
spectrum = handles.experimental_data.spectrum;

spectrum = apply_water_DSS_region(domain, spectrum, processing_info);

function [err, Indices] = Check_lower_triangle(Indices)
err = 0;
for i=1:size(Indices, 1)
    if Indices(i, 1) > Indices(i, 2)
        temp = Indices(i, 2);
        Indices(i, 2) = Indices(i, 1);
        Indices(i, 1) = temp;
    end
end

function Optimze_chemical_shifts_grained_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'exp_fid')
        return
    end
    if isempty(handles.uitable1.UserData)
        errordlg('You need to select at least one variable from the table', 'It is not clear which variable to optimize!');
        return
    end
    Indices = handles.uitable1.UserData.Indices;
    if isempty(Indices)
        errordlg('You need to select at least one variable from the table', 'It is not clear which variable to optimize!');
        return
    end
    [err, Indices] = Check_lower_triangle(Indices);
    if err
        return
    end
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end
    spectrum = handles.current_spectra.exp_fid;
    domain = handles.current_spectra.exp_ppm;

    processing_info = get_processing_package(hObject, eventdata, handles);
    array = zeros(size(Indices, 1), 1);
    for i=1:length(array)
        array(i) = handles.Entry.coupling_matrix(handles.spin_space_index).coupling_matrix(Indices(i, 1), Indices(i, 2)); 
    end
    Min = min(array)-.03;
    Max = max(array)+.03;
    Get_grained_optimization_domain(Min, Max);
    uiwait(gcf);
    array = getappdata(0,'grained_cs_domain');

    if array(1) == 0
        return
    end

    Min = array(2);
    Max = array(3);

    matrix_out = local_grained_optimization_on_cs(Indices, processing_info, domain, spectrum, Min, Max);
    matrix_out = update_lower_triangle(matrix_out);
    set(handles.uitable1, 'Data', matrix_out);
    handles.status_changed = 1;
    guidata(hObject, handles);
    msgbox({'optimization completed.'}, 'Optimization report:')
    uiwait(gcf);
    drawnow
catch ME
    Handle_error(handles, ME);
end

function pushbutton11_Optimization_groups_cells_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'exp_fid')
        errordlg('Need to process the spin matrix before optimizing the spin matrix');
        return
    end
    if isempty(handles.uitable1.UserData)
        errordlg('You need to select at least one variable from the table', 'It is not clear which variable to optimize!');
        return
    end
    Indices = handles.uitable1.UserData.Indices;
    if isempty(Indices)
        errordlg('You need to select at least one variable from the table', 'It is not clear which variable to optimize!');
        return
    end
    [err, Indices] = Check_lower_triangle(Indices);
    if err
        return
    end
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end

    grouped_indices = ones(length(Indices), 1);
    guidata(hObject, handles);
    [spectrum, domain, processing_info] = get_experimental_spectrum(hObject, eventdata, handles);


    [matrix_out, msg] = local_optimization_on_groups(Indices, grouped_indices, processing_info, domain, spectrum);
    matrix_out = update_lower_triangle(matrix_out);
    set(handles.uitable1, 'Data', matrix_out);
    handles.status_changed = 1;
    guidata(hObject, handles);
    msgbox({'optimization completed with the following message:', msg}, 'Optimization report:')
    uiwait(gcf);
    drawnow
catch ME
    Handle_error(handles, ME);
end

function Optimization_over_groups_of_cells_Callback(hObject, eventdata, handles)

try
    if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'exp_fid')
        errordlg('Need to process the spin matrix before optimizing the spin matrix');
        return
    end
    if isempty(handles.uitable1.UserData)
        errordlg('You need to select at least one variable from the table', 'It is not clear which variable to optimize!');
        return
    end
    Indices = handles.uitable1.UserData.Indices;
    if isempty(Indices)
        errordlg('You need to select at least one variable from the table', 'It is not clear which variable to optimize!');
        return
    end
    [err, Indices] = Check_lower_triangle(Indices);
    if err
        return
    end
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end

    Group_cells_for_optimization(Indices, handles.Entry.coupling_matrix(handles.spin_space_index).spin_names);
    uiwait(gcf);
    grouped_indices = getappdata(0,'optimization_grouped_indices');
    if isempty(grouped_indices)
        return
    end

    %spectrum = handles.current_spectra.exp_fid;
    %domain = handles.current_spectra.exp_ppm;
    %processing_info = get_processing_package(hObject, eventdata, handles);

    guidata(hObject, handles);
    [spectrum, domain, processing_info] = get_experimental_spectrum(hObject, eventdata, handles);


    [matrix_out, msg] = local_optimization_on_groups(Indices, grouped_indices, processing_info, domain, spectrum);
    matrix_out = update_lower_triangle(matrix_out);
    set(handles.uitable1, 'Data', matrix_out);
    handles.status_changed = 1;
    guidata(hObject, handles);
    msgbox({'optimization completed with the following message:', msg}, 'Optimization report:')
    uiwait(gcf);
    drawnow
catch ME
    Handle_error(handles, ME);
end

function View_additional_coupling_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry') || ~isfield(handles.Entry, 'coupling_matrix') || ~isfield(handles, 'spin_space_index') || ~isfield(handles.Entry.coupling_matrix(handles.spin_space_index), 'spin_names') || ...
            ~isfield(handles.Entry.coupling_matrix(handles.spin_space_index), 'additional_coupling') || isempty(handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling)
        uiwait(msgbox('There is no additional coupling available!'));
        return
    end
    atom_names = handles.Entry.coupling_matrix(handles.spin_space_index).spin_names;
    additional_coupling_groups = handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling_groups;

    input.atom_names = atom_names;
    input.additional_coupling = additional_coupling_groups;
    View_additional_couplings(input)
catch ME
    Handle_error(handles, ME);
end

function Edit_additional_coupling_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry') || ~isfield(handles.Entry, 'coupling_matrix') || ~isfield(handles, 'spin_space_index') || ~isfield(handles.Entry.coupling_matrix(handles.spin_space_index), 'spin_names') || ...
            ~isfield(handles.Entry.coupling_matrix(handles.spin_space_index), 'additional_coupling') || isempty(handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling)
        return
    end
    % choice = questdlg({'If you have used the "grouped additional couplings" feature, using "Edit" will modify the coupling constants.', 'Would you like to continue?'}, 'Edit additional coupling constants', 'Yes', 'No', 'No');
    % if strcmp(choice, 'No')
    %     return;
    % end

    atom_names = handles.Entry.coupling_matrix(handles.spin_space_index).spin_names;
    additional_coupling = handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling_groups;
    input.atom_names = atom_names;
    input.additional_coupling = additional_coupling;
    Edit_additional_couplings(input);
    uiwait(gcf);
    updated_additional_coupling = getappdata(0,'edited_additional_coeff');

    handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling_groups = updated_additional_coupling;
    handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling = updated_additional_coupling(:, 1:2);
    handles.spin_matrix_changed = 1;
    guidata(hObject, handles);
    msgbox('The spin matrix has been updated. You may process!', 'Additional coupling constants');
    uiwait(gcf);
catch ME
    Handle_error(handles, ME);
end
if get(handles.checkbox5, 'Value')
    Auto_Save(hObject, eventdata, handles);
end

function Apply_different_constant_to_different_spins_Callback(hObject, eventdata, handles)
try
    Additional_coupling_new_grouped(hObject, eventdata, handles)
catch ME
    Handle_error(handles, ME);
end

function Additional_coupling_new_grouped(hObject, eventdata, handles)
try
    if handles.spin_space_index == 1 && length(handles.Entry.coupling_matrix) > 1 
        uiwait(msgbox({'This is a merged spin system matrix and contains sub-matrices', 'No Change will be applied on the merged spin system matrix', 'To apply changes, please reprocess sub-matrices'}))
        return
    end
catch
    return
end
atom_names = handles.Entry.coupling_matrix(handles.spin_space_index).spin_names;
Spin_coeff_different_couplings(atom_names);
uiwait(gcf);
Additional_coupling_table = getappdata(0,'Additional_coupling_table');
%additional_coupling = getappdata(0,'different_spin_different_coeff');
%additional_coupling_groups = getappdata(0, 'additional_coupling_groups');

if isempty(Additional_coupling_table)
    return
end
handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling = Additional_coupling_table(:, 1:2); %additional_coupling;
handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling_groups = Additional_coupling_table; %additional_coupling_groups;
handles.spin_matrix_changed = 1;
guidata(hObject, handles);
msgbox('The spin matrix has been updated. You may process!', 'Additional coupling constants');
uiwait(gcf);
if get(handles.checkbox5, 'Value')
    Auto_Save(hObject, eventdata, handles);
end

function Apply_additional_coupling_constants_Callback(hObject, eventdata, handles)
try
    Additional_coupling_new_grouped(hObject, eventdata, handles)
catch ME
    Handle_error(handles, ME);
end

function Remove_additional_coupling_constants_Callback(hObject, eventdata, handles)
try
    handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling = [];
    handles.Entry.coupling_matrix(handles.spin_space_index).additional_coupling_groups = [];
    handles.spin_matrix_changed = 1;
    guidata(hObject, handles);
    msgbox('The spin matrix has been updated. You may process!', 'Additional coupling constants');
    uiwait(gcf);
catch ME
    Handle_error(handles, ME);
end

if get(handles.checkbox5, 'Value')
    Auto_Save(hObject, eventdata, handles);
end

function Draw_InChI_string_graph_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'Entry') || ~isfield(handles.Entry, 'InChI')
    InChI = '';
else
    InChI = handles.Entry.InChI;
end
input.InChI = InChI;
DrawInchi_Gui(input)

function Plot_a_molecule_Callback(hObject, eventdata, handles)
plot_a_mol_file

function Simulated_spectrum_csv_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'current_spectra') || ~isfield(handles.current_spectra, 'sim_ppm') || ~isfield(handles, 'folder_path')
        return
    end
    [FileName,PathName,~] = uiputfile(sprintf('%s/*.csv', handles.folder_path), 'Save simulated spectra in csv');
    if isnumeric(FileName)
        return
    end
    fpath = sprintf('%s/%s', PathName, FileName);
    fout = fopen(fpath, 'w');
    if fout < 1
        errordlg('Could not open the output file')
        return
    end
    sim_ppm = handles.current_spectra.sim_ppm;
    sim_fid = handles.current_spectra.sim_fid;
    for i=1:length(sim_ppm)
        fprintf(fout, '%.04f,%.04f\n', sim_ppm(i), sim_fid(i));
    end
    fclose(fout);
    msgbox(sprintf('The spectrum is saved to %s', fpath));
    uiwait(gcf);
catch ME
    Handle_error(handles, ME);
end

function view_inchi_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'Entry')
    return
end
View_InChi(handles.Entry)

function uitoggletool4_ClickedCallback(hObject, eventdata, handles)
dcm_obj = datacursormode(handles.figure1);
set(dcm_obj,'DisplayStyle','datatip', 'UpdateFcn',@myupdatefcn, ...
    'SnapToDataVertex','off','Enable','on')

function txt = myupdatefcn(empt,event_obj)
pos = get(event_obj,'Position');
txt = {['PPM: ',sprintf('%.04f', pos(1))],...
	      ['Amp: ',sprintf('%.03f', pos(2))],...
          'PPM is copied to clipboard'};
clipboard('copy',sprintf('%.04f', pos(1)));

function add_Notes_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry')
        return
    end

    input.note = handles.Entry.Notes.txt;
    input.status = handles.Entry.Notes.status;
    Note_Gui(input)
    uiwait(gcf);
    note = getappdata(0,'entry_note_text');
    status = getappdata(0,'entry_note_status');
    handles.Entry.Notes.txt = note;
    handles.Entry.Notes.status = status;
    if strcmpi(get(handles.popupmenu1, 'Visible'), 'on')
        data = get(handles.popupmenu1, 'String');
        index = get(handles.popupmenu1, 'Value');
        data{index} = sprintf('%s(%s)-%s', handles.Entry.ID, handles.Entry.name, status);
        set(handles.popupmenu1, 'String', data);
        set(handles.popupmenu1, 'Value', index);
    end
    
    guidata(hObject, handles);
 catch ME
    Handle_error(handles, ME);
end

function open_aux_spectrum_Callback(hObject, eventdata, handles)
try
    uiwait(Create_project_explore_experimental_data);

    output = getappdata(0, 'load_exp_data');
    index_type  = output.index_type;
    index_dimension = output.index_dimension;
    folder_path = output.folder_path;
    fpath = output.fpath;

    if index_type == 0 && index_dimension == 0
        return
    end
    exp_data.index_type = index_type;
    exp_data.index_dimension = index_dimension;
    exp_data.folder_path = folder_path;
    exp_data.fpath = fpath;
    guidata(hObject, handles);
    
    InterfaceObj=findobj(handles.figure1,'Enable','on');
    set(InterfaceObj,'Enable','off');
    h_wait = msgbox('Loading the 2D spectra', 'Please wait');
    
    if index_type == 2 % bruker
        if index_dimension == 1 % 1d
            errordlg('You cannot use 1D spectra as auxiliary spectra');
            try
                close(h_wait);
                set(InterfaceObj,'Enable','on');
            catch
            end
            
            return
        else % 2d
            folder_name = exp_data.folder_path;
            input_file = sprintf('%s/pdata/1/2rr', folder_name);
            Acqus_2D_H_File_Path = sprintf('%s/acqus', folder_name);
            Procs_2D_H_File_Path = sprintf('%s/pdata/1/procs', folder_name);
            Acqus_2D_C_File_Path = sprintf('%s/acqu2s', folder_name);
            Procs_2D_C_File_Path = sprintf('%s/pdata/1/proc2s', folder_name);
            if ~exist(input_file, 'file')|| ~exist(Acqus_2D_H_File_Path, 'file') || ~exist(Procs_2D_H_File_Path, 'file') || ~exist(Acqus_2D_C_File_Path, 'file') || ~exist(Procs_2D_C_File_Path, 'file')
                errordlg('the selected folder should contain:\n%s\n%s\n%s\n%s\n%s', input_file, Acqus_2D_H_File_Path, Procs_2D_H_File_Path, Acqus_2D_C_File_Path, Procs_2D_C_File_Path);
                try
                    close(h_wait);
                    set(InterfaceObj,'Enable','on');
                catch
                end
                return
            end
            [spectrum, Params] = Read_Bruker_2D(input_file, Acqus_2D_H_File_Path, Procs_2D_H_File_Path, Acqus_2D_C_File_Path, Procs_2D_C_File_Path);
            %spectrum = spectrum./max(max(spectrum));
            freq_max = (.5-(0/Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
            freq_min = (.5-((Params.xT-1)/Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
            domain_x = freq_min:(freq_max-freq_min)/(Params.xT-1):freq_max;
            OFFSET = (Params.xOFFSET-freq_max);
            domain_x = domain_x+ OFFSET;

            freq_max = (.5-(0/Params.yT))/(Params.yOBS/Params.ySW)+Params.yCAR;
            freq_min = (.5-((Params.yT-1)/Params.yT))/(Params.yOBS/Params.ySW)+Params.yCAR;
            domain_y = freq_min:(freq_max-freq_min)/(Params.yT-1):freq_max;
            OFFSET = (Params.yOFFSET-freq_max);
            domain_y = domain_y+ OFFSET;
            spectrum = rot90(spectrum,2);
        end
    end
    if index_type == 3 % jcamp
        if index_dimension == 1 % 1d
            errordlg('You cannot use 1D spectra as auxiliary spectra');
            try
                close(h_wait);
                set(InterfaceObj,'Enable','on');
            catch
            end
            return
        else
            errordlg('This version of GISSMO does not accept 2D JCAMP files');
            try
                close(h_wait);
                set(InterfaceObj,'Enable','on');
            catch
            end
            return
        end
    end
    if index_type == 4 % pipe
        if index_dimension == 1 % 1d
            errordlg('You cannot use 1D spectra as auxiliary spectra');
            try
                close(h_wait);
                set(InterfaceObj,'Enable','on');
            catch
            end
            return
        else
            [spectrum, Params, domain_x, field_x, domain_y, field_y] = load_nmrPipe_2D(exp_data.fpath);
            Params.xfield = field_x;
            Params.yfield = field_y;
        end
    end

    if index_type == 5 % csv
        if index_dimension == 1 % 1d
            errordlg('You cannot use 1D spectra as auxiliary spectra');
            try
                close(h_wait);
                set(InterfaceObj,'Enable','on');
            catch
            end
            return
        else
            [x_ppm, y_ppm, matrix] = load_csv_2D(exp_data.fpath);
            spectrum = matrix;
            domain_x = x_ppm;
            domain_y = y_ppm;
            Params.xfield = 1;
            Params.yfield = 1;
        end
    end

    if index_type == 6 % empty
        if index_dimension == 1 % 1d
            errordlg('You cannot use 1D spectra as auxiliary spectra');
            set(InterfaceObj,'Enable','on');
            return
        else
            errordlg('Empty 2D spectra is useless as auxiliary spectrum. Aborting the process ... ');
            try
                close(h_wait);
                set(InterfaceObj,'Enable','on');
            catch
            end
            return
        end
    end
    try
        
        handles.aux_spectrum.fid = spectrum;
        handles.aux_spectrum.domain_x = domain_x;
        handles.aux_spectrum.domain_y = domain_y;
        handles.aux_spectrum.field_x = Params.xfield;    
        handles.aux_spectrum.field_y = Params.yfield;
        msgbox('The aux. spectrum has been loaded!');
        guidata(hObject, handles);
    catch
        error('an error has occured while loading the 2D Bruker file!');
    end
    try
        close(h_wait);
        set(InterfaceObj,'Enable','on');
    catch
    end
catch ME
    Handle_error(handles, ME);
end

function aux_load_trace_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry') || ~isfield(handles, 'aux_spectrum')
        return
    end
    if isfield(handles, 'aux_spectrum_out') && isfield(handles.aux_spectrum_out, 'backup')
        handles.experimental_data.spectrum = handles.aux_spectrum_out.backup.experimental_data.spectrum;
        handles.experimental_data.domain = handles.aux_spectrum_out.backup.experimental_data.domain;
        handles.experimental_data.field = handles.aux_spectrum_out.backup.experimental_data.field;    
    end
    input.aux_spectrum = handles.aux_spectrum;
    if ~isfield(handles, 'TwoD_contour')
        input.TwoD_contour = 25;
    else
        input.TwoD_contour = handles.TwoD_contour;
    end
    Get_aux_spectrum_trace(input);
    uiwait(gcf);
    set(handles.figure1,'pointer','arrow')
    aux_spectrum_out = getappdata(0, 'aux_spectrum_out');
    if aux_spectrum_out.assigned == 0
        return
    end
    
    handles.aux_spectrum_out.backup.experimental_data.spectrum = handles.experimental_data.spectrum;
    handles.aux_spectrum_out.backup.experimental_data.domain = handles.experimental_data.domain;
    handles.aux_spectrum_out.backup.experimental_data.field = handles.experimental_data.field;

    handles.TwoD_contour = aux_spectrum_out.TwoD_contour;
    handles.experimental_data.spectrum = aux_spectrum_out.fid;
    handles.experimental_data.domain = aux_spectrum_out.ppm;
    handles.experimental_data.field = aux_spectrum_out.field;

    if get(handles.field_as_exp_data, 'Value') == 1
        set(handles.numpoints, 'String', sprintf('%d', length(aux_spectrum_out.fid)));
    end

    if get(handles.num_point_of_sim_fid_checkbox, 'Value') == 1
        set(handles.field_sim_fid, 'String', sprintf('%.03f', aux_spectrum_out.field));
    end


    guidata(hObject, handles);
    msgbox({'Experimental spectrum has been updated.', 'You may "process"'})
    uiwait(gcf);
    Draw_experimental_spectrum_axes(hObject, eventdata, handles)
catch ME
    Handle_error(handles, ME);
end

function aux_replace_to_original_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'aux_spectrum_out') || ~isfield(handles.aux_spectrum_out, 'backup')
        return
    end

    handles.experimental_data.spectrum = handles.aux_spectrum_out.backup.experimental_data.spectrum;
    handles.experimental_data.domain = handles.aux_spectrum_out.backup.experimental_data.domain;
    handles.experimental_data.field = handles.aux_spectrum_out.backup.experimental_data.field;
    guidata(hObject, handles);
    msgbox({'Experimental spectrum has been updated.', 'You may "process"'})
    uiwait(gcf);
    Draw_experimental_spectrum_axes(hObject, eventdata, handles)


    if get(handles.field_as_exp_data, 'Value') == 1
        set(handles.numpoints, 'String', sprintf('%d', length(handles.aux_spectrum_out.backup.experimental_data.spectrum)));
    end

    if get(handles.num_point_of_sim_fid_checkbox, 'Value') == 1
        set(handles.field_sim_fid, 'String', sprintf('%.03f', handles.aux_spectrum_out.backup.experimental_data.field));
    end
catch ME
    Handle_error(handles, ME);
end

function disable_enable_spins_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'Entry')
        return
    end
    index = handles.spin_space_index;

    if index == 1 && length(handles.Entry.coupling_matrix) > 1
        msgbox('You cannot apply enable/disable on a merged spin matrix. This option is available for the corresponding sub-matrices.')
    end

    if isfield(handles, 'backup') && isfield(handles.backup, 'couplings')
        % need to update the coupling_matrix from Entry using the backup
        if size(handles.backup.couplings.coupling_matrix, 1) > size(handles.Entry.coupling_matrix(index).coupling_matrix, 1)
            backup_spin_names = handles.backup.couplings.spin_names;
            entry_spin_names = handles.Entry.coupling_matrix(index).spin_names;
            Map = [];
            for i=1:length(entry_spin_names)
                corr_index = find(strcmp(backup_spin_names, entry_spin_names{i}));
                Map = [Map; [i, corr_index]];
            end
            handles.backup.couplings.coupling_matrix(Map(:, 2), Map(:, 2)) = handles.Entry.coupling_matrix(index).coupling_matrix;
            handles.backup.couplings.CS = diag(handles.backup.couplings.coupling_matrix);
            handles.backup.couplings.additional_coupling = [];
            handles.backup.couplings.additional_coupling_groups = [];
            if ~isempty(handles.Entry.coupling_matrix(index).additional_coupling)
                temp = handles.Entry.coupling_matrix(index).additional_coupling_groups;
                for i=1:size(temp)
                    new_index = Map(temp(i, 1) == Map(:, 1), 2);
                    temp(i, 1) = new_index;
                end
                handles.backup.couplings.additional_coupling_groups = temp;
                handles.backup.couplings.additional_coupling = temp(:, 1:2);
            end
            
        end
        handles.Entry.coupling_matrix(index) = handles.backup.couplings;
    end

    handles.backup.couplings = handles.Entry.coupling_matrix(index);

    input.spin_names = handles.Entry.coupling_matrix(index).spin_names;
    Disable_Enable_Spins(input);
    uiwait(gcf);
    selected = getappdata(0, 'selectedSpins');
    if nnz(selected) == 0
        msgbox('you cannot disable all of the spin. Discarding the request.')
        return;
    end
    if nnz(selected) == length(selected)
        handles = rmfield(handles, 'backup');
    end
    handles.Entry.coupling_matrix(index).spin_names(~selected) = [];
    handles.Entry.coupling_matrix(index).CS(~selected) = [];
    handles.Entry.coupling_matrix(index).coupling_matrix(~selected, :) = [];
    handles.Entry.coupling_matrix(index).coupling_matrix(:, ~selected) = [];
    handles.spin_matrix_changed = 1;
    guidata(hObject, handles);
    Populated_workspace(hObject, eventdata, handles)
catch ME
    Handle_error(handles, ME);
end

function Parameters_view_edit_Callback(hObject, eventdata, handles)
View_parameters

function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

function Export_for_webserver_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'Entry')
    return
end
handles = guidata(hObject);
if ~isfield(handles, 'data_to_export4web')
    uiwait(msgbox('You need to process the spin matrix before exporting the workspace'));
    return
end

if isfield(handles, 'folder_path') && ~isempty(handles.folder_path)
    curr_path = handles.folder_path;
else
    curr_path = '.';
end

folder_name = uigetdir(curr_path, 'Create a folder to save the workspace');
if isnumeric(folder_name)
    return
end
List = dir(folder_name);
if length(List) > 2
    choice = questdlg('The folder is not empty. This action will over-write all of the files. Would you like to continue?', 'over-writting a foder', 'Yes', 'No', 'No');
    if strcmp(choice, 'No')
        return
    else
        system(sprintf('rm -rf %s/*', folder_name));
    end
end
xml_fpath = sprintf('%s/spin_simulation.xml', folder_name);
save_workspace(xml_fpath, hObject, eventdata, handles);
try
    system(sprintf('cp %s/%s %s/2D_mol_file.jpg', handles.folder_path, handles.Entry.path_2D_image, folder_name));
catch
    h = figure;
    plot([0; 0], [1; 1], '--k'); hold on
    plot([0; 1], [1; 0], '--k');
    ylim([0 1])
    xlim([0 1])
    set(gca, 'xtick', [])
    set(gca, 'ytick', [])
    saveas(h, sprintf('%s/2D_mol_file.jpg', folder_name), 'jpg');
    close(h);
end

fout = fopen(sprintf('%s/exp_0', folder_name), 'w');
fprintf(fout, 'ppm,val\n');
for i=1:length(handles.data_to_export4web.exp_ppm)
    if i == length(handles.data_to_export4web.exp_ppm)
        fprintf(fout, '%f,%f', handles.data_to_export4web.exp_ppm(i), handles.data_to_export4web.exp_fid(i));
    else
        fprintf(fout, '%f,%f\n', handles.data_to_export4web.exp_ppm(i), handles.data_to_export4web.exp_fid(i));
    end
end
fclose(fout);
fout = fopen(sprintf('%s/sim_0', folder_name), 'w');
fprintf(fout, 'ppm,val\n');
for i=1:length(handles.data_to_export4web.sim_ppm)
    if i == length(handles.data_to_export4web.sim_ppm)
        fprintf(fout, '%f,%f', handles.data_to_export4web.sim_ppm(i), handles.data_to_export4web.sim_fid(i));
    else
        fprintf(fout, '%f,%f\n', handles.data_to_export4web.sim_ppm(i), handles.data_to_export4web.sim_fid(i));
    end
end
fclose(fout);

system(sprintf('cp -r %s/%s %s/', handles.folder_path, handles.Entry.spectrum.path, folder_name));

function edit_cmp_prop_add_2d_fig_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'Entry')
    return
end
current_path = '.';
if isfield(handles, 'folder_path') && ~isempty(handles.folder_path)
    current_path = handles.folder_path;
end
[FileName,PathName,~] = uigetfile(sprintf('%s.jpg', current_path),'Select a static jpg file');
if isnumeric(FileName)
    return;
end
new_path = sprintf('%s/%s', PathName, FileName);
msg_copied = '';
if ~strcmp(PathName, handles.folder_path)
    [~, ~] = system(sprintf('cp %s %s', new_path, handles.folder_path));
    msg_copied = sprintf('We copied the file into %s', handles.folder_path);
end
handles.Entry.path_2D_image = sprintf('./%s', FileName);
guidata(hObject, handles);
uiwait(msgbox({msg_copied, 'workspace has been updated.', 'save the workspace.'}))

function add_new_spins_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'Entry')
    return
end
if length(handles.Entry.coupling_matrix) > 1
    choice = questdlg('This action will remove sub-matrices. Would you like to continue?', 'Adding new spin', 'Yes', 'No', 'No');
    if strcmp(choice, 'No')
        return
    end
end
if length(handles.Entry.coupling_matrix) > 1
    handles.Entry.coupling_matrix = handles.Entry.coupling_matrix(1);
    handles.Entry.coupling_matrix.additional_coupling = [];
    handles.Entry.coupling_matrix.additional_coupling_groups = [];
    handles.spin_space_index = 1;
    handles.spin_matrix_changed = 1;
    
end

input.cs = handles.Entry.coupling_matrix.CS;
input.spin_names = handles.Entry.coupling_matrix.spin_names;
uiwait(add_spins(input));
output = getappdata(0, 'new_spins');
if isempty(output.spin_names)
    return
end
num_new_spins = length(output.spin_names);

handles.Entry.coupling_matrix.CS = [handles.Entry.coupling_matrix.CS;output.cs];
for i=1:num_new_spins
    handles.Entry.coupling_matrix.spin_names{end+1} = output.spin_names{i};
end
curr_matrix_len = size(handles.Entry.coupling_matrix.coupling_matrix, 1);
new_matrix = zeros(curr_matrix_len+num_new_spins);
new_matrix(1:curr_matrix_len, 1:curr_matrix_len) = handles.Entry.coupling_matrix.coupling_matrix;
for i=1:num_new_spins
    new_matrix(curr_matrix_len+i,curr_matrix_len+i) = output.cs(i);
end
handles.Entry.coupling_matrix.coupling_matrix = new_matrix;
handles.spin_matrix_changed = 1;
guidata(hObject, handles);
Populated_workspace(hObject, eventdata, handles)

function delete_spins_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'Entry')
    return
end
if length(handles.Entry.coupling_matrix) > 1
    choice = questdlg('This action will remove sub-matrices. Would you like to continue?', 'Adding new spin', 'Yes', 'No', 'No');
    if strcmp(choice, 'No')
        return
    end
end
if length(handles.Entry.coupling_matrix) > 1
    handles.Entry.coupling_matrix = handles.Entry.coupling_matrix(1);
    handles.Entry.coupling_matrix.additional_coupling = [];
    handles.Entry.coupling_matrix.additional_coupling_groups = [];
    handles.spin_space_index = 1;
    handles.spin_matrix_changed = 1;
    
end
input.cs = handles.Entry.coupling_matrix.CS;
input.spin_names = handles.Entry.coupling_matrix.spin_names;
uiwait(delete_spins(input));
removed = getappdata(0, 'delete_spins');
if nnz(removed) == 0
    return
end

handles.Entry.coupling_matrix.coupling_matrix(removed, :) = [];
handles.Entry.coupling_matrix.coupling_matrix(:, removed) = [];
handles.Entry.coupling_matrix.CS(removed) = [];
handles.Entry.coupling_matrix.spin_names(removed) = [];
handles.spin_matrix_changed = 1;
guidata(hObject, handles);
Populated_workspace(hObject, eventdata, handles)

function pushbutton_Reset_integral_Callback(hObject, eventdata, handles)
reset_integrals(hObject, eventdata, handles)
Draw_full_exp_spectrum_Callback(hObject, eventdata, handles)

function reset_integrals(hObject, eventdata, handles)
if isfield(handles, 'integral_sets')
    handles = rmfield(handles, 'integral_sets');
end

if isfield(handles, 'integral_text')
    handles = rmfield(handles, 'integral_text');
end
guidata(hObject, handles);


function get_integral_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'experimental_data') || ~isfield(handles.experimental_data, 'domain')
    return
end
rect = getrect(handles.axes1);
domain = [rect(1), rect(1)+rect(3)];
indices = handles.experimental_data.domain >= min(domain) & handles.experimental_data.domain <= max(domain);
Sum = sum(handles.experimental_data.spectrum(indices));
list = find(indices);
[pos_y, idx] = max(handles.experimental_data.spectrum(list));
pos_x = handles.experimental_data.domain(list(idx));
added = false;
if isfield(handles, 'integral_sets')
    for i=1:size(handles.integral_sets, 1)
        if (rect(1) >= handles.integral_sets(i, 1) && rect(1) <= handles.integral_sets(i, 2)) || ...
                (rect(1)+rect(3) >= handles.integral_sets(i, 1) && rect(1)+rect(3) <= handles.integral_sets(i, 2)) || ...
            (rect(1) <= handles.integral_sets(i, 1) && handles.integral_sets(i, 1) <= rect(1)+rect(3)) || ...
            (rect(1) <= handles.integral_sets(i, 2) && handles.integral_sets(i, 2) <= rect(1)+rect(3))
            handles.integral_sets(i, 1) = pos_x;
            handles.integral_sets(i, 2) = pos_y;
            handles.integral_sets(i, 3) = Sum;
            handles.integral_sets(i, 4) = domain(1);
            handles.integral_sets(i, 5) = domain(2);
            added = true;
            break
        end
    end
    if ~added
        index = size(handles.integral_sets, 1)+1;
        handles.integral_sets(index, 1) = pos_x;
        handles.integral_sets(index, 2) = pos_y;
        handles.integral_sets(index, 3) = Sum;
        handles.integral_sets(index, 4) = domain(1);
        handles.integral_sets(index, 5) = domain(2);
    end
else
    handles.integral_sets(1, 1) = pos_x;
    handles.integral_sets(1, 2) = pos_y;
    handles.integral_sets(1, 3) = Sum;
    handles.integral_sets(1, 4) = domain(1);
    handles.integral_sets(1, 5) = domain(2);
end
guidata(hObject, handles);
draw_integrals(hObject, eventdata, handles)

function draw_integrals(hObject, eventdata, handles)
handles = guidata(hObject);
axes(handles.axes1)
hold on
XLIM = xlim;
YLIM = ylim;
DIST = (max(YLIM)-min(YLIM));
if isfield(handles, 'integral_text')
    for i=1:length(handles.integral_text)
        try
            delete(handles.integral_text(i));
        end
    end
    handles = rmfield(handles, 'integral_text');
end
handles.integral_text = [];
if isfield(handles, 'integral_sets')
    for i=1:size(handles.integral_sets, 1)
        pos_x = handles.integral_sets(i, 1);
        pos_y = handles.integral_sets(i, 2);
        integral = sprintf('(%.01f)', handles.integral_sets(i, 3));
        domain_x1 = handles.integral_sets(i, 4);
        domain_x2 = handles.integral_sets(i, 5);
        handles.integral_text(end+1) = plot([domain_x1; domain_x2], [.015*DIST+pos_y; .02*DIST+pos_y], '--k');
        handles.integral_text(end+1) = text(pos_x, .04*DIST+pos_y, integral, 'Color', 'k', 'FontWeight', 'Bold');
    end

end
hold off
guidata(hObject, handles);

function manual_tag_Callback(hObject, eventdata, handles)
web('http://gissmo.nmrfam.wisc.edu/','-browser', '-new')

function menu_export_nmredata_Callback(hObject, eventdata, handles)
write_nmredata(hObject, eventdata, handles);














function ROI_min_Callback(hObject, eventdata, handles)
function ROI_min_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ROI_max_Callback(hObject, eventdata, handles)
function ROI_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function water_region_min_Callback(hObject, eventdata, handles)
function water_region_min_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function water_region_max_Callback(hObject, eventdata, handles)
function water_region_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function water_region_flag_Callback(hObject, eventdata, handles)
function DSS_region_min_Callback(hObject, eventdata, handles)
function DSS_region_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function DSS_region_max_Callback(hObject, eventdata, handles)
function DSS_region_max_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function DSS_region_flag_Callback(hObject, eventdata, handles)
function numpoints_Callback(hObject, eventdata, handles)
function numpoints_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function lw_value_Callback(hObject, eventdata, handles)
function lw_value_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function field_sim_fid_Callback(hObject, eventdata, handles)
function field_sim_fid_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function lor_coeff_Callback(hObject, eventdata, handles)
function lor_coeff_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function gau_coeff_Callback(hObject, eventdata, handles)
function gau_coeff_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function num_point_of_sim_fid_checkbox_Callback(hObject, eventdata, handles)
function field_as_exp_data_Callback(hObject, eventdata, handles)
function Tools_Callback(hObject, eventdata, handles)
function Splitting_spin_matrix_Callback(hObject, eventdata, handles)
function Optimization_Callback(hObject, eventdata, handles)
function Optimize_spin_matrix_Callback(hObject, eventdata, handles)
function Additional_coupling_constant_Callback(hObject, eventdata, handles)
function Drawing_tools_Callback(hObject, eventdata, handles)
function Export_Callback(hObject, eventdata, handles)
function File_Callback(hObject, eventdata, handles)
function Save_workspace_Callback(hObject, eventdata, handles)
function popupmenu1_Callback(hObject, eventdata, handles)
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function compound_name_Callback(hObject, eventdata, handles)
function compound_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function checkbox5_Callback(hObject, eventdata, handles)
if get(handles.checkbox5, 'Value') == 1
    set(handles.checkbox5, 'ForegroundColor', 'g');
else
    set(handles.checkbox5, 'ForegroundColor', 'r');
end
function draw_roi_Callback(hObject, eventdata, handles)
function uitable1_ButtonDownFcn(hObject, eventdata, handles)
function uitable1_KeyPressFcn(hObject, eventdata, handles)
function Untitled_auxiliary_menu_Callback(hObject, eventdata, handles)
function Help_menu_tag_Callback(hObject, eventdata, handles)
function guided_optimiation_tag_Callback(hObject, eventdata, handles)
function Auxiliary_tools_tag_Callback(hObject, eventdata, handles)
function Untitled_1_Callback(hObject, eventdata, handles)
function popupmenu_same_compounds_Callback(hObject, eventdata, handles)
function popupmenu_same_compounds_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Untitled_2_Callback(hObject, eventdata, handles)
function paste_cells_Callback(hObject, eventdata, handles)

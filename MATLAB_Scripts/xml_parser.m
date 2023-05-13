function Entry = xml_parser(xml_path)

fin = fopen(xml_path, 'r');
if fin < 1
    errordlg('Could not open the xml file!')
    return
end
h = msgbox('please wait', 'loading spin matrix');

ex_spectrum_flag = 0;
coupling_matrix_flag = 0;
peak_shape_coef_flag = 0;
water_region_flag = 0;
DSS_region_flag = 0;
spin_names_flag = 0;
acc_flag = 0;
cs_flag = 0;
couplings_flag = 0;
peak_list_flag = 0;
spectrum_flag = 0;
notes_flag = 0;
coupling_matrix_counter = 0;
db_link_flag = 0;
tline = fgetl(fin);
xml_version = 0;
while ischar(tline)
    
    if ~isempty(strfind(tline, '<name>'))
        Entry.name = parse_xml_line(tline, 'name');
    end
    if ~isempty(strfind(tline, '<version>'))
        Entry.version = parse_xml_line(tline, 'version');
        xml_version = str2double(parse_xml_line(tline, 'version'));
    end
    if ~isempty(strfind(tline, '<SRC name'))
        [db_name, db_id] = parse_xml_dublets(tline);
        Entry.Src.DB = db_name;
        Entry.Src.DB_id = db_id; 
    end
    if ~isempty(strfind(tline, '<InChI>'))
        Entry.InChI = parse_xml_line(tline, 'InChI');
    end
    if ~isempty(strfind(tline, '</comp_db_link>'))
        db_link_flag = 0;
    end
    if db_link_flag == 1
        [db_type, db_accession] = parse_xml_dublets(tline);
        index = size(Entry.DB_link, 1)+1;
        Entry.DB_link{index, 1} = db_type;
        Entry.DB_link{index, 2} = db_accession;
    end
    if ~isempty(strfind(tline, '<comp_db_link>'))
        db_link_flag = 1;
        Entry.DB_link = {};
    end
    if ~isempty(strfind(tline, '<ID>'))
        Entry.ID = parse_xml_line(tline, 'ID');
    end
    if ~isempty(strfind(tline, '<mol_file_path>'))
        Entry.mol_file_path = parse_xml_line(tline, 'mol_file_path');
    end
    if ~isempty(strfind(tline, '<roi_rmsd>'))
        Entry.roi_rmsd = str2double(parse_xml_line(tline, 'roi_rmsd'));
    end
    if ~isempty(strfind(tline, '</notes>'))
        notes_flag = 0;
        Entry.Notes.txt = Notes_txt;
        Entry.Notes.status = Notes_status;
    end
    if notes_flag == 1 && ~isempty(strfind(tline, '<status>'))
        Notes_status = parse_xml_line(tline, 'status');
    end
    if notes_flag == 1 && ~isempty(strfind(tline, '<note>'))
        if isempty(Notes_txt)
            Notes_txt = parse_xml_line(tline, 'note');
        else
            Notes_txt = sprintf('%s\n%s', Notes_txt, parse_xml_line(tline, 'note'));
        end
    end
    if ~isempty(strfind(tline, '<notes>'))
        notes_flag = 1;
        Notes_txt = '';
        Notes_status = '';
    end
    
    if ~isempty(strfind(tline, '</experimental_spectrum>'))
        ex_spectrum_flag = 0;
    end
    if ex_spectrum_flag == 1
        if ~isempty(strfind(tline, '<type>'))
            Entry.spectrum.type = parse_xml_line(tline, 'type');
        end
        if ~isempty(strfind(tline, '<root_folder>'))
            Entry.spectrum.path= parse_xml_line(tline, 'root_folder');
        end
    end
    if ~isempty(strfind(tline, '<experimental_spectrum>'))
        ex_spectrum_flag = 1;
    end
    if ~isempty(strfind(tline, '<field_strength>'))
        Entry.field_strength = str2double(parse_xml_line(tline, 'field_strength'));
    end
    if ~isempty(strfind(tline, '<field_strength_applied_flag>'))
        Entry.field_strength_flag = str2double(parse_xml_line(tline, 'field_strength_applied_flag'));
    end
    if ~isempty(strfind(tline, '<num_simulation_points>'))
        Entry.num_points = str2double(parse_xml_line(tline, 'num_simulation_points'));
    end
    if ~isempty(strfind(tline, '<num_simulation_points_applied_flag>'))
        Entry.num_points_flag = str2double(parse_xml_line(tline, 'num_simulation_points_applied_flag'));
    end
    if ~isempty(strfind(tline, '<path_2D_image>'))
        Entry.path_2D_image = parse_xml_line(tline, 'path_2D_image');
    end
    if ~isempty(strfind(tline, '<num_split_matrices>'))
        Entry.num_split_matrices = str2double(parse_xml_line(tline, 'num_split_matrices'));
        Entry.coupling_matrix = struct('label', cell(Entry.num_split_matrices+1, 1));
    end
    if ~isempty(strfind(tline, '</coupling_matrix>'))
        coupling_matrix_flag = 0;
        for i=1:length(Entry.coupling_matrix(coupling_matrix_counter).CS)
            Entry.coupling_matrix(coupling_matrix_counter).coupling_matrix(i, i) = Entry.coupling_matrix(coupling_matrix_counter).CS(i);
        end
    end
    if coupling_matrix_flag == 1
        if ~isempty(strfind(tline, '<label>'))
            coupling_matrix_counter = coupling_matrix_counter+1;
            Entry.coupling_matrix(coupling_matrix_counter).label =  parse_xml_line(tline, 'label');
        end
        if ~isempty(strfind(tline, '<index>'))
            Entry.coupling_matrix(coupling_matrix_counter).index =  str2double(parse_xml_line(tline, 'index'));
        end
        if ~isempty(strfind(tline, '<lw>'))
            lw_str = parse_xml_line(tline, 'lw');
            if str2double(lw_str) ==  0.3
                new_entry = 1;
                Entry.coupling_matrix(coupling_matrix_counter).lw = '1';
            else
                new_entry = 0;
                Entry.coupling_matrix(coupling_matrix_counter).lw = lw_str;
            end
        end
        if ~isempty(strfind(tline, '</peak_shape_coefficients>'))
            peak_shape_coef_flag = 0;
        end
        if peak_shape_coef_flag == 1
            if ~isempty(strfind(tline, '<lorentzian>'))
                Entry.coupling_matrix(coupling_matrix_counter).lorent = parse_xml_line(tline, 'lorentzian');
            end
            if ~isempty(strfind(tline, '<gaussian>'))
                Entry.coupling_matrix(coupling_matrix_counter).gauss = parse_xml_line(tline, 'gaussian');
            end
        end
        if ~isempty(strfind(tline, '<peak_shape_coefficients>'))
            peak_shape_coef_flag = 1;
        end
        if ~isempty(strfind(tline, '</water_region>'))
            water_region_flag = 0;
        end
        if water_region_flag == 1
            if ~isempty(strfind(tline, '<min_ppm>'))
                Entry.coupling_matrix(coupling_matrix_counter).water.min = parse_xml_line(tline, 'min_ppm');
            end
            if ~isempty(strfind(tline, '<max_ppm>'))
                Entry.coupling_matrix(coupling_matrix_counter).water.max = parse_xml_line(tline, 'max_ppm');
            end
            if ~isempty(strfind(tline, '<remove_flag>'))
                Entry.coupling_matrix(coupling_matrix_counter).water.flag = parse_xml_line(tline, 'remove_flag');
            end
        end
        if ~isempty(strfind(tline, '<water_region>'))
            water_region_flag = 1;
        end
        if ~isempty(strfind(tline, '</DSS_region>'))
            DSS_region_flag = 0;
        end
        if DSS_region_flag == 1
            if ~isempty(strfind(tline, '<min_ppm>'))
                Entry.coupling_matrix(coupling_matrix_counter).DSS.min = parse_xml_line(tline, 'min_ppm');
            end
            if ~isempty(strfind(tline, '<max_ppm>'))
                Entry.coupling_matrix(coupling_matrix_counter).DSS.max = parse_xml_line(tline, 'max_ppm');
            end
            if ~isempty(strfind(tline, '<remove_flag>'))
                Entry.coupling_matrix(coupling_matrix_counter).DSS.flag = parse_xml_line(tline, 'remove_flag');
            end
        end
        if ~isempty(strfind(tline, '<DSS_region>'))
            DSS_region_flag = 1;
        end
        
        if ~isempty(strfind(tline, '</additional_coupling_constants>'))
            acc_flag = 0;
            
            if ~isempty(additional_coupling) && size(additional_coupling, 2) == 2 %old version
                acc_matrix = [];
                u_list = unique(additional_coupling(:, 2));
                for u_list_iter=1:length(u_list)
                    indices = additional_coupling(:, 2) == u_list(u_list_iter);
                    spins_indices = additional_coupling(indices, 1);
                    coupling_group_index = u_list_iter;
                    coupling = u_list(u_list_iter);
                    spins_group_index = u_list_iter;
                    acc_matrix = [acc_matrix; [spins_indices, coupling.*ones(size(spins_indices)), spins_group_index.*ones(size(spins_indices)), coupling_group_index.*ones(size(spins_indices))]];
                end
                Entry.coupling_matrix(coupling_matrix_counter).additional_coupling_groups = acc_matrix;
                Entry.coupling_matrix(coupling_matrix_counter).additional_coupling = acc_matrix(:, 1:2);
            end
            if ~isempty(additional_coupling) && size(additional_coupling, 2) == 4 %new version
                Entry.coupling_matrix(coupling_matrix_counter).additional_coupling = additional_coupling(:, 1:2);
                Entry.coupling_matrix(coupling_matrix_counter).additional_coupling_groups = additional_coupling;
            end
            if isempty(additional_coupling)
                Entry.coupling_matrix(coupling_matrix_counter).additional_coupling = [];
                Entry.coupling_matrix(coupling_matrix_counter).additional_coupling_groups = [];                
            end
        end
        if acc_flag == 1
            %[index, value] = parse_xml_dublets(tline);
            vector = parse_xml_multiplets(tline);
            additional_coupling = [additional_coupling;vector];
        end
        if ~isempty(strfind(tline, '<additional_coupling_constants>'))
            additional_coupling = [];
            acc_flag = 1;
        end
        
        if ~isempty(strfind(tline, '</spin_names>'))
            spin_names_flag = 0;
            Entry.coupling_matrix(coupling_matrix_counter).spin_names = spin_names;
        end
        if spin_names_flag == 1
            if xml_version == 1
                spin = parse_xml_line(tline, 'spin');
                spin_names{end+1} = spin;
            end
            if xml_version == 2
                %'<spin index="1" name="26"></spin>'
                [t_spin_index, t_spin_name] = parse_xml_dublets(tline);
                spin_names{str2double(t_spin_index)} = t_spin_name;
            end
        end
        if ~isempty(strfind(tline, '<spin_names>'))
            spin_names = {};
            spin_names_flag = 1;
        end
        
        
        if ~isempty(strfind(tline, '</chemical_shifts_ppm>'))
            cs_flag = 0;
            Entry.coupling_matrix(coupling_matrix_counter).CS = CS;
        end
        if cs_flag == 1
            if xml_version == 1
                cs = parse_xml_line(tline, 'cs');
                CS = [CS; str2double(cs)];
            end
            if xml_version == 2
                %<cs index="1" ppm="8.11198"></cs>
                [t_cs_index, t_cs_ppm] = parse_xml_dublets(tline);
                CS(str2double(t_cs_index)) = str2double(t_cs_ppm);
            end
        end
        if ~isempty(strfind(tline, '<chemical_shifts_ppm>'))
            if xml_version == 1
                CS = [];
            end
            if xml_version == 2
                CS = zeros(length(spin_names), 1);
            end
            cs_flag = 1;
        end
        
        if ~isempty(strfind(tline, '</couplings_Hz>'))
            couplings_flag = 0;
            Entry.coupling_matrix(coupling_matrix_counter).coupling_matrix = matrix;
        end
        if couplings_flag == 1
            [from, to, value] = parse_xml_triplets(tline);
            matrix(from, to) = value;
            matrix(to, from) = value;
        end
        if ~isempty(strfind(tline, '<couplings_Hz>'))
            matrix = zeros(length(Entry.coupling_matrix(coupling_matrix_counter).CS));
            couplings_flag = 1;
        end
        
        
        if ~isempty(strfind(tline, '</peak_list>'))
            peak_list_flag = 0;
            Entry.coupling_matrix(coupling_matrix_counter).peak_list = peak_list;
        end
        if peak_list_flag == 1
             [index, value] = parse_xml_dublets(tline);
             peak_list = [peak_list;[str2double(index), str2double(value)]];
        end
        if ~isempty(strfind(tline, '<peak_list>'))
            peak_list = [];
            peak_list_flag = 1;
        end

        if ~isempty(strfind(tline, '</spectrum>'))
            spectrum_flag = 0;
            Entry.coupling_matrix(coupling_matrix_counter).spectrum = spectrum_numbers;
        end
        if spectrum_flag == 1
             [index, value] = parse_xml_dublets(tline);
             spectrum_numbers = [spectrum_numbers;[str2double(index), str2double(value)]];
        end
        if ~isempty(strfind(tline, '<spectrum>'))
            spectrum_numbers = [];
            spectrum_flag = 1;
        end        
    end
    if ~isempty(strfind(tline, '<coupling_matrix>'))
        coupling_matrix_flag = 1;
    end 
    tline = fgetl(fin);
end
fclose(fin);
close(h);

if ~isfield(Entry, 'roi_rmsd')
    Entry.roi_rmsd = 1000;
end

if ~isfield(Entry, 'DB_link')
    Entry.DB_link = {};
end
if ~isfield(Entry, 'Src')
    Entry.Src.DB = 'Empty';
    Entry.Src.DB_id = 'Empty'; 
end

if ~isfield(Entry, 'mol_file_path')
    Entry.mol_file_path = '';
end

if ~isfield(Entry, 'Inchi_graph_image')
    Entry.Inchi_graph_image = '';
end
if ~isfield(Entry, 'Notes') || ~isfield(Entry.Notes, 'txt')
    Entry.Notes.txt = '';
end
if ~isfield(Entry, 'Notes') || ~isfield(Entry.Notes, 'status')
    if new_entry == 1
        Entry.Notes.status = 'Initial values';
    else
        Entry.Notes.status = 'Active';
    end
end
if isfield(Entry, 'Notes') && isfield(Entry.Notes, 'status') && isempty(Entry.Notes.status)
    Entry.Notes.status = 'Initial values';
end


function [from, to, value] = parse_xml_triplets(tline)
content = strsplit(tline, '"');
from = str2double(content{2});
to = str2double(content{4});
value = str2double(content{6});

function vector = parse_xml_multiplets(tline)
content = strsplit(tline, '"');
iter_index = 2;
vector = [];
while iter_index < length(content)
    vector = [vector, str2double(content{iter_index})];
    iter_index = iter_index+2;
end


function [index, value] = parse_xml_dublets(tline)
content = strsplit(tline, '"');
if length(content) < 4
    index = 'Empty';
    value = 'Empty';
else
    index = content{2};
    value = content{4};
end

function out = parse_xml_line(tline, keyword)
try
content = strsplit(tline, sprintf('<%s>', keyword));
content = strsplit(content{2}, sprintf('</%s>', keyword));
out = content{1};
catch
    out = '';
end

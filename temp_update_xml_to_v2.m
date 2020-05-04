function temp_update_xml_to_v2
root = '/home/hesam/Desktop/GISSMO_folder/generate_initial_spin_matrices/Fragments/Fragments_library_Aug_2018/';
system(sprintf('rm -f list_of_xmls; find %s -wholename "*/spin_simulation.xml" > list_of_xmls', root))
fin = fopen('list_of_xmls', 'r');
tline = fgetl(fin);
while ischar(tline)
    Entry = xml_parser(tline);
    if ~strcmp(Entry.Notes.status, 'Initial values')
        fprintf('%s updated \n', Entry.ID);
        Entry.version = '2';
        save_entry(Entry, tline)
    else
        fprintf('%s skipped \n', Entry.ID);
    end
    tline = fgetl(fin);
end
fclose(fin);




function save_entry(Entry, output_file)
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
fprintf(fout, '\t<SRC name="%s" ID="%s"></SRC>\n', Entry.Src.DB, Entry.Src.DB_id);
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
    
%fprintf(fout, '\t<Inchi_graph_image>%s</Inchi_graph_image>\n', Entry.Inchi_graph_image);
fprintf(fout, '\t<path_2D_image>%s</path_2D_image>\n', Entry.path_2D_image);
fprintf(fout, '\t<num_split_matrices>%d</num_split_matrices>\n', Entry.num_split_matrices);
fprintf(fout, '\t<roi_rmsd>%.05f</roi_rmsd>\n', Entry.roi_rmsd);
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

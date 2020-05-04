function [names, matrix] = Load_spin_matrix_nmrdb_json(spin_matrix_path)
fin = fopen(spin_matrix_path, 'r');
if fin < 1
    errordlg('could not open the spin matrix');
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

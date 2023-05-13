function [Matrix, atoms] = Load_spin_matrix_gaussian(spin_matrix_path)
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


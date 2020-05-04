function [names, matrix] = Load_spin_matrix_csv(spin_matrix_path)
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

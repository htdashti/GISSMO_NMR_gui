function BGobj = convert_inchi_to_graph(inchi)

%[atom_names, matrix] = convert_inchi_heavy_atoms_to_graph(inchi);
[atom_names, matrix] = convert_inchi_to_full_graph(inchi);

for i=1:length(atom_names)
    atom_names{i} = sprintf('%s%d', atom_names{i}, i);
end
BGobj = biograph(matrix, atom_names, 'ShowArrows', 'off');
for i=1:size(matrix, 1)
    if ~isempty(strfind(atom_names{i}, 'C'))
        BGobj.Nodes(i).Shape = 'circle';
        BGobj.Nodes(i).LineColor= [0 0 0];
        BGobj.Nodes(i).LineWidth = 2;
        BGobj.Nodes(i).Color = [1 1 1];
        BGobj.Nodes(i).FontSize = 12;
        BGobj.Nodes(i).TextColor = [0 0 0];
    end
    if ~isempty(strfind(atom_names{i}, 'N'))
        BGobj.Nodes(i).Shape = 'circle';
        BGobj.Nodes(i).LineColor= [0 0 1];
        BGobj.Nodes(i).TextColor= [0 0 1];
        BGobj.Nodes(i).LineWidth = 2;
        BGobj.Nodes(i).Color = [1 1 1];
        BGobj.Nodes(i).FontSize = 12;
        BGobj.Nodes(i).TextColor = [0 0 1];
    end
    if ~isempty(strfind(atom_names{i}, 'O'))
        BGobj.Nodes(i).Shape = 'circle';
        BGobj.Nodes(i).LineColor= [1 0 0];
        BGobj.Nodes(i).TextColor= [1 0 0];
        BGobj.Nodes(i).LineWidth = 2;
        BGobj.Nodes(i).Color = [1 1 1];
        BGobj.Nodes(i).FontSize = 12;
        BGobj.Nodes(i).TextColor = [1 0 0];
    end
    if ~isempty(strfind(atom_names{i}, 'H'))
        BGobj.Nodes(i).Shape = 'circle';
        BGobj.Nodes(i).LineColor= [.5 0 1];
        BGobj.Nodes(i).TextColor= [.5 0 1];
        BGobj.Nodes(i).LineWidth = 2;
        BGobj.Nodes(i).Color = [1 1 1];
        BGobj.Nodes(i).FontSize = 10;
        BGobj.Nodes(i).TextColor = [.5 0 1];
    end
end
for i=1:length(BGobj.Edges)
    BGobj.Edges(i).LineWidth = 2;
end

function [atom_names, matrix] = convert_inchi_heavy_atoms_to_graph(inchi)
global Error_Msg
content = strsplit(inchi,'/');
if length(content) < 3
    Error_Msg{end+1} = 'The InChI string is not complete';
    Error_Msg{end+1} = inchi;
    Error_Msg{end+1} = 'The structure file is not compatible with the inchi-1 program';
    atom_names ={};
    matrix = [];
    return
end

if ~isempty(strfind(content{2}, '.')) || ~isempty(strfind(content{3}, ';')) || ~isempty(strfind(content{3}, '*'))
    splited_inchis = split_inchi(inchi);
    atom_names = {};
    matrix = [];
    for i=1:length(splited_inchis)
        [c_atom_names, c_matrix] = call_parse_inchi(splited_inchis{i});
        atom_names = [atom_names; c_atom_names];
        new_matrix = zeros(size(matrix, 1)+size(c_matrix, 1));
        new_matrix(1:size(matrix, 1), 1:size(matrix, 1)) = matrix;
        new_matrix(size(matrix, 1)+1:end, size(matrix, 1)+1:end) = c_matrix;
        matrix = new_matrix;
    end
else
    [atom_names, matrix] = call_parse_inchi(inchi);
end

function [atom_names, matrix] = call_parse_inchi(inchi)
global Error_Msg
Inchi_split = strsplit(inchi,'/', 'CollapseDelimiters', false);
if length(Inchi_split) < 3
    Error_Msg{end+1} = 'The InChi string is not complete';
    Error_Msg{end+1} = inchi;
    return
end
% parse atoms
Atoms_seq = Inchi_split{2};
Atoms_seq = strsplit(Atoms_seq, '.');
Atoms_seq = Atoms_seq{1};
%Atoms_cell = cell(length(Atoms_seq), 1);
Atom_seq_counter = 0;
for i=1:length(Atoms_seq)
   % Atoms_seq(i)
    if isstrprop(Atoms_seq(i), 'lower')
        if i == 1
            Error_Msg{end+1} = sprintf('the atom %s was not recognized!', Atoms_seq(i));
            return
        end
        Atoms_cell{Atom_seq_counter} = sprintf('%s%s', Atoms_cell{Atom_seq_counter}, Atoms_seq(i));
    else
        Atom_seq_counter = Atom_seq_counter+1;
        Atoms_cell{Atom_seq_counter} = Atoms_seq(i);
    end
end
%[c_list, n_list] = split_char_vs_nums(Atoms_cell);
c_list = {};
n_list =[];

merged = merge_split_char_vs_nums(Atoms_cell);
i = 1;
while i <= length(merged)
    if isnan(str2double(merged{i}))
        if i+1> length(merged) || ~isnumeric(merged{i+1})
            if strcmpi(merged{i}, 'H') || strcmpi(merged{i}, 'D')
                i = i+1;
                continue
            end
            c_list{end+1} = merged{i};
            n_list = [n_list; 1];
            i = i+1;
        else
            if strcmpi(merged{i}, 'H') || strcmpi(merged{i}, 'D')
                i = i+2;
                continue
            end
            c_list{end+1} = merged{i};
            n_list = [n_list; merged{i+1}];
            i = i+2;
        end
    end
end
num_atoms = sum(n_list);

matrix = zeros(num_atoms);
if isempty(matrix)
    atom_names = [];
    return
end
Atoms_dictionary = [];
Atoms_counter =1;
for i=1:length(c_list)
    if strcmp(c_list(i), 'H')
        continue;
    end
    for j=1:n_list(i)
        Atoms_dictionary{Atoms_counter, 1} = c_list{i};
        Atoms_dictionary{Atoms_counter, 2} = Atoms_counter;
        Atoms_counter = Atoms_counter+1;
    end
end

% heavy atom connectivities
if ~isempty(Inchi_split{3})
    heavyatom_seq = Inchi_split{3};
    %heavyatom_seq = heavyatom_seq(2:end);
    if ~isempty(heavyatom_seq(2:end)) && strcmp(heavyatom_seq(1), 'c')
        heavyatom_seq = heavyatom_seq(2:end);
        content = strsplit(heavyatom_seq, ';');
        heavyatom_seq = content{1};
        heavyatom_seq_cell = cell(length(heavyatom_seq), 1);
        for i=1:length(heavyatom_seq)
            heavyatom_seq_cell{i} = heavyatom_seq(i);
        end
        [c_list, n_list] = split_char_vs_nums(heavyatom_seq_cell);
        for i=2:length(n_list)
            if strcmp(c_list{i-1}, '-')
                %fprintf('%d-%d\n', n_list(i-1), n_list(i))
                matrix(n_list(i-1), n_list(i)) = 1;
            end
            if strcmp(c_list{i-1}, ')')
                [index, error_msg] = find_root_index_pClose(n_list, c_list, i-1);
                if ~isempty(error_msg)
                    Error_Msg{end+1} = error_msg;
                    return
                end
                %fprintf('%d-%d\n', index, n_list(i))
                matrix(index, n_list(i)) = 1;
            end
            if strcmp(c_list{i-1}, '(')
                %fprintf('%d-%d\n', n_list(i-1), n_list(i))
                matrix(n_list(i-1), n_list(i)) = 1;
            end
            if strcmp(c_list{i-1}, ',')
                [index, error_msg] = find_root_index_pClose(n_list, c_list, i-1);
                if ~isempty(error_msg)
                    Error_Msg{end+1} = error_msg;
                    %errordlg(error_msg)
                    return
                end
                %fprintf('%d-%d\n', index, n_list(i))
                matrix(index, n_list(i)) = 1;
            end
        end
    end
end

atom_names = Atoms_dictionary(:, 1);

% atom_names = cell(size(matrix, 1), 1);
% for i=1:size(matrix, 1)
%     atom_names{i} = sprintf('%s%d', Atoms_dictionary{i, 1}, i);
% end









function [index, error_msg] = find_root_index_pClose(n_list, c_list, c_index)
index = 0;
error_msg = '';
if strcmp(c_list(c_index), ')')
    counter = -1;
else
    counter = 0;
end
for iter = c_index:-1:1
    if strcmp(c_list(iter), ')')
        counter = counter+1;
    end
    if strcmp(c_list(iter), '(')
        if counter == 0
            index = n_list(iter);
            return
        else
            counter = counter-1;
        end
    end
end
error_msg = 'syntax error';

function merged = merge_split_char_vs_nums(STR)
merged = [];
array = isnan(str2double(STR));
c_list = [];
n_list = [];
iter = 1;
while iter <= length(array)
    %array(iter)
    %STR(iter)
    if array(iter) == 1
        c_list{end+1} = STR{iter};
        merged{end+1} = STR{iter};
        iter = iter+1;        
    else
        if strcmp(STR(iter), 'i')
            merged{end} = sprintf('%si', merged{end});
            iter=iter+1;
        else
            temp = '';
            while iter <=length(array) && ~array(iter)==1
                temp = sprintf('%s%s', temp, STR{iter});
                iter = iter+1;
            end
            n_list(end+1) = str2double(temp);
            merged{end+1} = str2double(temp);
        end
    end
end
Removed = false(length(merged), 1);
for i=1:length(merged)
    if strcmp(merged{i}, '-')
        start = merged{i-1};
        end_p = merged{i+1};
        if ~isnumeric(end_p)
            end_p = 1;
            for j=i+2:length(merged)
                if isnumeric(merged{j})
                    end_p = merged{j};
                    break
                end
            end
        end
        merged{i-1} = start:end_p;

        Removed(i) = true;
        Removed(i+1) = true;
    end
end
merged(Removed) = [];

function [c_list, n_list] = split_char_vs_nums(STR)
array = isnan(str2double(STR));
c_list = [];
n_list = [];
iter = 1;
while iter <= length(array)
    if array(iter) == 1
        c_list{end+1} = STR{iter};
        iter = iter+1;
    else
        temp = '';
        while iter <=length(array) && ~array(iter)==1
            temp = sprintf('%s%s', temp, STR{iter});
            iter = iter+1;
        end
        n_list(end+1) = str2double(temp);
    end
end



function [atom_names, matrix] = convert_inchi_to_full_graph(inchi)
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
for i=1:size(matrix, 1)
    for j=i+1:size(matrix, 1)
        matrix(j, i) = 0;
    end
end

function [atom_names, matrix] = call_parse_inchi(inchi)
global Error_Msg curr_num_conn
curr_num_conn = [];
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

matrix = get_symm(matrix);
curr_num_conn = zeros(size(matrix, 1), 1);
for i=1:length(curr_num_conn)
    curr_num_conn(i) = nnz(matrix(i, :));
end

N = size(Atoms_dictionary, 1);
if ~isempty(Inchi_split{4})
    protons_seq = Inchi_split{4};
    protons_seq = protons_seq(2:end);
    if ~isempty(protons_seq)
        %content = strsplit(protons_seq, ';');
        %protons_seq = content{1};
        %13H,1-2H2,(H,7,8)(H,9,10)(H,11,12)
        protons_seq_cell = cell(length(protons_seq), 1);
        for i=1:length(protons_seq)
            protons_seq_cell{i} = protons_seq(i);
        end
        merged = merge_split_char_vs_nums(protons_seq_cell);
        [proton_match, mobiles] = Parsing_Protons(merged, protons_seq);
        if ~isempty(proton_match)
            proton_match = sortrows(proton_match, 2);
        end
        if ~isempty(mobiles)
            s_proton_match = apply_mobiles(proton_match, mobiles);
        else
            s_proton_match{1} = proton_match;
        end
    end
end
col = size(matrix, 1);
if exist('s_proton_match', 'var')
    for i=1:length(s_proton_match)
        temp = s_proton_match{i};
        num_protons = temp(:, 1);
        heavy_indices = temp(:, 2);
        for j=1:length(heavy_indices)
            for k=1:num_protons(j)
                col = col+1;
                matrix(heavy_indices(j), col) = 1;
                matrix(col, heavy_indices(j)) = 1;
                atom_names{end+1, 1} = 'H';
            end
        end
    end
end
matrix = complete(matrix);

function matrix = complete(matrix)
for i=1:size(matrix, 1)
    for j=1:size(matrix, 2)
        if matrix(i, j) == 1
            matrix(j, i) = 1;
        else
            matrix(j, i) = 0;
        end
    end
end
function matrix = get_symm(matrix)
for i=1:size(matrix, 1)
    for j=1:size(matrix, 1)
        if matrix(i, j) == 1
            matrix(j, i) = 1;
        end
        if matrix(j, i) == 1;
            matrix(i, j) = 1;
        end
    end
end


function s_proton_match = apply_mobiles(proton_match, mobiles)

for i=1:size(mobiles, 1)
    num_atoms = mobiles{i, 1};
    Len = length(mobiles{i, 2});
    array = [zeros(Len, 1), mobiles{i, 2}];
    index = 0;
    while num_atoms~= 0
        index = index+1;
        if index > Len
            index = 1;
        end
        array(index, 1) = array(index, 1)+1;
        num_atoms = num_atoms-1;
    end
    proton_match = [proton_match; array];
end
s_proton_match{1} = sortrows(proton_match, 2);
% possibilities = cell(size(mobiles, 1), 1);
% limits = zeros(size(mobiles, 1), 1);
% % if size(mobiles, 1) > 1
% %     fprintf('\n\n*****************************\n\n\n*****************************\n\n\n*****************************\n\n\n*****************************\n\n\n*****************************\n');
% % end
% for i=1:size(mobiles, 1)
%     num_proton = mobiles{i, 1};
%     to = mobiles{i, 2};
%     cases = get_cases(to, num_proton);
%     Assignments = cell(size(cases, 1), 1);
%     for j=1:size(cases, 1)
%         row = cases(j, :);
%         temp = [];
%         for k=1:length(to)
%             temp = [temp; [to(k), row(k)]];
%         end
%         Assignments{j} = temp;
%     end
%     possibilities{i} = Assignments; %nchoosek(to, num_proton);
%     limits(i) = size(possibilities{i}, 1);
% end
% s_proton_match = cell(prod(limits), 1);
% array = ones(length(limits), 1);
% 
% for iteration=1:prod(limits)
%     temp = proton_match;
%     for i=1:length(possibilities)
%         
%         assignments = possibilities{i}{array(i)};
%         for j=1:size(assignments, 1)
%             list = find(temp(:, 2) == assignments(j, 1));
%             if isempty(list)
%                 index = size(temp, 1)+1;
%                 temp(index, 1) = assignments(j, 2); % num protons
%                 temp(index, 2) = assignments(j, 1); % index
%             else
%                 temp(list, 1) = temp(list, 1)+assignments(j, 2);
%             end
%         end
%     end
%     s_proton_match{iteration} = temp;
%     array = get_next(array, limits);
% end


function array = get_next(array, limits)
for i=length(array):-1:1
    array(i) = array(i)+1;
    if array(i) > limits(i)
        array(i) = 1;
    else
        return;
    end
end


function cases = get_cases(to, num_proton)
global curr_num_conn

to_conn = (curr_num_conn(to))';
n = length(to);
d = num_proton;
c = nchoosek(1:d+n-1,n-1);
m = size(c,1);
t = ones(m,d+n-1);
t(repmat((1:m).',1,n-1)+(c-1)*m) = 0;
u = [zeros(1,m);t.';zeros(1,m)];
v = cumsum(u,1);
cases = diff(reshape(v(u==0),n+1,m),1).';
remove = false(size(cases, 1), 1);
for i=1:size(cases, 1)
    if nnz(cases(i, :) > 3) ~= 0 || nnz(cases(i, :)+to_conn > 4) ~= 0
        remove(i) = true;
    end
end
cases(remove, :) = [];


function [proton_match, mobiles] = Parsing_Protons(merged, protons_seq)
used = false(length(merged), 1);
i = 1;
p_open = 0;
proton_match = [];
mobiles_counter = 0;
mobiles = {};
while i <= length(merged)
    %merged{i}
    if strcmp(merged{i}, 'H') 
        if ~p_open
            if i < length(merged) && isnumeric(merged{i+1})
                number_of_H = merged{i+1};
                used(i+1) = true;
            else
                number_of_H = 1;
            end
            to_atom = merged{i-1};
            used(i-1) = true;
            % getting previous , separated atom indices
            for j=i-2:-1:1
                if used(j)
                    break;
                end
                if ~used(j) && isnumeric(merged{j})
                    to_atom = [to_atom, merged{j}];
                    used(j) = true;
                end
            end
            if length(to_atom) > 1
                for j=1:length(to_atom)
                    %fprintf('H%d is attached to %s%d\n', number_of_H, Atoms_dictionary{to_atom(j), 1}{1}, to_atom(j))
                    %fprintf('H%d is attached to %d\n', number_of_H, to_atom(j))
                    proton_match = [proton_match;[number_of_H, to_atom(j)]];
                end
            else
                %fprintf('H%d is attached to %s%d\n', number_of_H, Atoms_dictionary{to_atom, 1}{1}, to_atom)
                %fprintf('H%d is attached to %d\n', number_of_H, to_atom)
                proton_match = [proton_match;[number_of_H, to_atom]];
            end
        else % mobile protons
            %merged{i}
            %merged{i+1}
            if isnumeric(merged{i+1})
                number_of_H = merged{i+1};
                %to_atom = assign_mobile_proton(number_of_H, proton_match, i+3, merged, used); % merged{i+3};%
                [indices, used] = assign_mobile_proton(i+3, merged, used);
                mobiles_counter = mobiles_counter+1;
                mobiles{mobiles_counter, 1} = number_of_H;
                mobiles{mobiles_counter, 2} = indices;
                %used(i+1) = true;
                %used(i+3) = true;
                %used(i+5) = true;
            else % we should take care of "-"
                number_of_H = 1;
                %to_atom = merged{i+2};
                [indices, used] = assign_mobile_proton(i+2, merged, used);
                mobiles_counter = mobiles_counter+1;
                mobiles{mobiles_counter, 1} = number_of_H;
                mobiles{mobiles_counter, 2} = indices;
                %used(i+2) = true;
                %used(i+4) = true;
            end
            %fprintf('H%d is attached to %s%d\n', number_of_H, Atoms_dictionary{to_atom, 1}{1}, to_atom)
            %fprintf('H%d is attached to %d\n', number_of_H, to_atom)
        end
    end
    if strcmp(merged{i}, '(')
        p_open = 1;
    end
    if strcmp(merged{i}, ')')
        p_open = 0;
    end
    i = i+1;
end

function [indices, used] = assign_mobile_proton(index, merged, used)

indices = [];
for i=index:length(merged)
    used(i) = true;
    if strcmp(merged{i}, ')')
        break
    end
    if isnumeric(merged{i})
        indices = [indices; merged{i}];
    end
end






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
    if strcmp(merged{i}, '-') && isnumeric(merged{i-1})
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



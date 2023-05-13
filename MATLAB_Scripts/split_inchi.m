function [inchis, mirror_list] = split_inchi(inchi)


%inchi = 'InChI=1S/C12H12N2.2ClH/c13-12(10-6-2-1-3-7-10)11-8-4-5-9-14-11;;/h1-9,12H,13H2;2*1H/t12-;;/m0../s1';
% inchi = 'InChI=1S/2H3N.H2O8S2/c;;1-9(2,3)7-8-10(4,5)6/h2*1H3;(H,1,2,3)(H,4,5,6)';
%inchi = 'InChI=1S/2C6H9O7.3Na.10H2O.2O.2Sb/c2*7-1-2(8)3(9)4(10)5(11)6(12)13;;;;;;;;;;;;;;;;;/h2*2-5,7-8H,1H2,(H,12,13);;;;10*1H2;;;;/q2*-3;3*+1;;;;;;;;;;;;-1;+3;+4/p-3/t2*2-,3-,4+,5-;;;;;;;;;;;;;;;;;/m11................./s1';
%inchi = 'InChI=1S/Ga.3H';
%inchi = 'InChI=1S/Sn.4H/q+4;;;;';

[heavy_atom_list, connections_list, protons_list, stero_list, mirror_list] = get_components(inchi);

Len = max([length(heavy_atom_list), length(connections_list), length(protons_list)]);
inchis = cell(Len, 1);
if ~isempty(stero_list)
    for index=1:Len
        inchis{index} = sprintf('InChI=1S/%s/c%s/h%s/t%s', heavy_atom_list{index}, connections_list{index}, protons_list{index}, stero_list{index});
    end
else
    for index=1:Len
        inchis{index} = sprintf('InChI=1S/%s/c%s/h%s', heavy_atom_list{index}, connections_list{index}, protons_list{index});
    end
end
return

function [heavy_atom_list, connections_list, protons_list, stero_list, mirror_list] = get_components(inchi)
content = strsplit(inchi, '/');
heavy_atoms = content{2};
heavy_atom_list = {};
heavy_content = strsplit(heavy_atoms, '.');
for i=1:length(heavy_content)
    current_block = heavy_content{i};
    if ~isnan(str2double(current_block(1)))
        j = 1;
        while ~isnan(str2double(current_block(j)))
            j=j+1;
        end
        num_str = current_block(1:j-1);
        if strcmp(current_block(j), '*')
            current_block = current_block(j+1:end);
        else
            current_block = current_block(j:end);
        end
        for j=1:str2double(num_str)
            heavy_atom_list{end+1} = current_block;
        end
    else
        heavy_atom_list{end+1} = current_block;
    end
end
if length(content) < 3
    connections_list = cell(length(heavy_atom_list), 1);
    protons_list= cell(length(heavy_atom_list), 1);
    stero_list = cell(length(heavy_atom_list), 1);
    return
end

connections_list = cell(length(heavy_atom_list), 1);
for content_index = 3:length(content)
    connections = content{content_index};
    if strcmp(connections(1), 'c')
        connections = connections(2:end);
        splitted = strsplit(connections, ';', 'CollapseDelimiters', false);
        connections_list = {};
        for i=1:length(splitted)
            if ~isempty(strfind(splitted{i}, '*'))
                split = strsplit(splitted{i}, '*', 'CollapseDelimiters', false);
                for j=1:str2double(split{1})
                    connections_list{end+1} = split{2};
                end
            else
                connections_list{end+1} = splitted{i};
            end
        end
        break
    end
end

protons_list= cell(length(heavy_atom_list), 1);
for content_index = 3:length(content)
    protons = content{content_index};
    if strcmp(protons(1), 'h')
        protons = protons(2:end);
        splitted = strsplit(protons, ';', 'CollapseDelimiters', false);
        protons_list = {};
        for i=1:length(splitted)
            current_block = splitted{i};
            if ~isempty(strfind(current_block, '*'))
                c_split = strsplit(current_block, '*');
                for j=1:str2double(c_split{1})
                    protons_list{end+1} = c_split{2};
                end
            else
                protons_list{end+1} = current_block;
            end
        end
        break;
    end
end

stero_list = cell(length(heavy_atom_list), 1);
for i=length(content):-1:1
    if strcmp(content{i}(1), 't')
        stero_list = {};
        stero = content{i};
        stero = stero(2:end);
        split = strsplit(stero, ';', 'CollapseDelimiters', false);
        for j=1:length(split)
            if ~isempty(strfind(split{j}, '*'))
                n_split = strsplit(split{j}, '*', 'CollapseDelimiters', false);
                for k=1:str2double(n_split{1})
                    stero_list{end+1} = n_split{2};
                end
            else
                stero_list{end+1} = split{j};
            end
        end
        break
    end
end


mirror_list = ones(length(heavy_atom_list), 1);
for i=length(content):-1:1
    if strcmp(content{i}(1), 'm')
        mirrors = content{i};
        mirrors = mirrors(2:end);
        split = strsplit(mirrors, '.', 'CollapseDelimiters', false);
        if length(split) == length(mirror_list)
            for j=1:length(split)
                if ~isempty(split{j}) % if empty or 0, multiply by 1, if is 1, multiply t by -1
                    if str2double(split{j}) == 1
                        mirror_list(j) = -1;
                    end
                end
            end
            break
        else
            counter = 0;
            for j=1:length(split)
                if ~isempty(split{j})
                    m_array = split{j};
                    for k=1:length(m_array)
                        if str2double(m_array(k)) == 0
                            counter = counter+1;
                        else
                            counter = counter+1;
                            mirror_list(counter) = -1;
                        end
                    end
                else
                    counter = counter+1;
                end
            end
        end
    end
end

% content = strsplit(inchi, '/');
% inchis = {};
% inchi_counter = 0;
% content_formula = strsplit(content{2}, '.');
% for index=1:length(content_formula)
%     current_block = content_formula{index};
%     str_num_ions = '';
%     i = 1;
%     while ~isnan(str2double(current_block(i)))
%         str_num_ions = sprintf('%s%s', str_num_ions, current_block(i));
%         i = i+1;
%     end
%     if isempty(str_num_ions) % there is one compound in this block
%         segment = get_other_parts(content, index);
%         inchi_counter = inchi_counter+1;
%         inchis{inchi_counter} = sprintf('InChI=1S/%s', current_block);
%         for i=1:length(segment)
%             inchis{inchi_counter} = sprintf('%s/%s', inchis{inchi_counter}, segment{i});
%         end
%     else % there are more than one atom in this block
%         if strcmp(current_block(length(str_num_ions)+1), '*')
%             % I dont know how to deal with this yet
%             i = 0;
%         else
%             current_block=current_block(length(str_num_ions)+1:end);
%             num_ions = str2double(str_num_ions);
%             for new_index=index:index+num_ions-1
%                 segment = get_other_parts(content, new_index);
%                 inchi_counter = inchi_counter+1;
%                 inchis{inchi_counter} = sprintf('InChI=1S/%s', current_block);
%                 for i=1:length(segment)
%                     inchis{inchi_counter} = sprintf('%s/%s', inchis{inchi_counter}, segment{i});
%                 end
%             end
%         end
%     end
% end



function segment = get_other_parts(content, index)
counter = 0;
segment ={};
for i=3:length(content)
    current_content = content{i};
    letter = current_content(1);
    current_content = current_content(2:end);
    if ~strcmp(letter, 'c') && ~strcmp(letter, 'h') && ~strcmp(letter, 't')
        continue
    end
    deli = get_delim(letter);
    splitted = strsplit(current_content, deli, 'CollapseDelimiters', false);
    if index > length(splitted) || ~isempty(strfind(splitted{index}, '*'))
        splitted = strsplit(splitted{end}, '*');
        if length(splitted) == 2
            counter = counter+1;
            segment{counter} = sprintf('%s%s', letter, splitted{2});
        else
            if strcmp(splitted, 'D')
                continue;
            else
                i = 0;
            end
        end
    else
        counter = counter+1;
        segment{counter} = sprintf('%s%s', letter, splitted{index});
    end
end


function deli = get_delim(letter)
switch letter
    case 'c'
        deli = ';';
    case 'h'
        deli = ';';
    case 't'
        deli = ';';
    case 'm' % there could be no dots
        deli = '.';
    case 's' % there is nothing
        deli = '';
    case 'q'
        deli = ';';
    case 'p'
        deli = '';
end
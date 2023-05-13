function [matrix_out, msg] = local_optimization(in_Indices, in_processing_info, in_domain, in_spectrum)
global matrix Indices lw guassian_coeff lorentzian_coeff field ftnum domain spectrum roi processing_info selected_spin_region

processing_info = in_processing_info;
in_matrix = in_processing_info.spin_matrix;
in_lw = in_processing_info.line_width;
in_guassian_coeff = in_processing_info.gau_coeff;
in_lorentzian_coeff = in_processing_info.lor_coeff;
in_field = in_processing_info.field;
in_ftnum = in_processing_info.numpoints;
in_roi = [in_processing_info.ROI_min, in_processing_info.ROI_max];


matrix = in_matrix;
Indices = in_Indices;
lw = in_lw;
guassian_coeff = in_guassian_coeff;
lorentzian_coeff = in_lorentzian_coeff;
field = in_field;
ftnum = in_ftnum;
domain = in_domain;
spectrum = in_spectrum;
roi = in_roi;

selected_spin_region = get_selected_spins_domain(Indices);

Optimization_variables = {'Optimization on:'};
for i=1:size(selected_spin_region, 1)
    Optimization_variables{end+1} = sprintf('[%.03f, %.03f] ppm', selected_spin_region(i, 1), selected_spin_region(i, 2));
end
for i=1:size(Indices, 1)
    Optimization_variables{end+1} = sprintf('matrix(%d, %d)', Indices(i, 1), Indices(i, 2));
end
h_msg = msgbox(Optimization_variables, 'please wait!');
set(h_msg,'WindowStyle','modal');
figure(h_msg);

vector = zeros(size(Indices, 1), 1);
for i=1:size(Indices, 1)
    vector(i) = matrix(Indices(i, 1), Indices(i, 2));
end


options = optimset('Display', 'off');
iteration = 0;
old_value = 10^3;
h = waitbar(0,'Optimization process, Please wait...');
set(h,'WindowStyle','modal');
figure(h);
while 1
    [vector_out, fval, exitflag] = fminsearch(@get_differences,vector,options);
    iteration = iteration+1;
    waitbar(iteration / 10, h)
    if abs(fval-old_value) < 10^-2
        break
    else
        old_value = fval;
        vector = vector_out;
    end
    if iteration >10
        break
    end
end
close(h);
close(h_msg);
% rmsd = get_differences(vector)
matrix_out = matrix;
for i=1:size(Indices, 1)
    matrix_out(Indices(i, 1), Indices(i, 2)) = vector_out(i);
end

if exitflag == 1
    msg = sprintf('Simplex process coverged! L2: %.03f', fval);
elseif exitflag == 0
    msg = sprintf('Maximum num iterations was reached. L2: %.03f', fval);
else
    msg = 'Simplex operation has crashed!';
end

function selected_spins_region = get_selected_spins_domain(Indices)
global domain processing_info parameters_CS_range

selected_spins_region = [];
indices = reshape(Indices, size(Indices, 1)*size(Indices, 2), 1);
indices = unique(indices);
boolean_array = false(size(domain));

for i=1:length(indices)
    cs = processing_info.spin_matrix(indices(i), indices(i));
    region = domain > cs-parameters_CS_range & domain < cs+parameters_CS_range;
    boolean_array(region) = true;
end

counter = 0;
flag = false;
for i=1:length(boolean_array)
    if flag && ~boolean_array(i)
        flag = false;
        selected_spins_region(counter, 2) = domain(i);
    end
    if boolean_array(i) && ~flag
        flag = true;
        counter= counter+1;
        selected_spins_region(counter, 1) = domain(i);
    end
end

function rmsd = get_differences(vector)
global matrix Indices domain spectrum roi processing_info selected_spin_region
matrix_in = matrix;
for i=1:size(Indices, 1)
    matrix_in(Indices(i, 1), Indices(i, 2)) = vector(i);
end
processing_info.spin_matrix = matrix_in;
[sim_ppm, sim_fid] = Diagonalization(processing_info);
rmsd = get_rmsd(sim_ppm, sim_fid, selected_spin_region);

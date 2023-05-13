function [matrix_out, msg] = local_optimization_on_groups(in_Indices, in_grouped_indices, in_processing_info, in_domain, in_spectrum)
global matrix Indices grouped_indices domain spectrum roi processing_info selected_spin_region 
processing_info = in_processing_info;
in_matrix = processing_info.spin_matrix;
in_roi = [processing_info.ROI_min, processing_info.ROI_max];

grouped_indices = in_grouped_indices;
matrix = in_matrix;
Indices = in_Indices;
roi = in_roi;
domain = in_domain;
spectrum = in_spectrum;



selected_spin_region = get_selected_spins_domain(Indices);

Optimization_variables = {'Optimization on:'};
for i=1:size(selected_spin_region, 1)
    Optimization_variables{end+1} = sprintf('[%.03f, %.03f] ppm', selected_spin_region(i, 1), selected_spin_region(i, 2));
end
for i=1:size(Indices, 1)
    Optimization_variables{end+1} = sprintf('matrix(%d, %d)', Indices(i, 1), Indices(i, 2));
end

h = msgbox(Optimization_variables, 'please wait!');
set(h,'WindowStyle','modal');
figure(h);

Uniq = unique(grouped_indices);
vector = zeros(length(Uniq), 1);
for i=1:length(Uniq)
    curr_indices = grouped_indices == Uniq(i);
    if curr_indices > size(in_Indices, 1)
        errordlg('The number of spins did not match! Are you optimizing over a merged matrix?')
        close(h)
        matrix_out = matrix;
        msg = 'Error';
        return
    end
    curr_positions = in_Indices(curr_indices, :);
    Sum = 0;
    for j=1:size(curr_positions, 1)
        Sum = Sum+matrix(curr_positions(j, 1), curr_positions(j, 2));
    end
    Avg = Sum/size(curr_positions, 1);
    vector(i) = Avg;
end


options = optimset('Display', 'off');
iteration = 0;
old_value = 10^3;
h_wait = waitbar(0,'Optimization process, Please wait...');
set(h_wait,'WindowStyle','modal');
figure(h_wait);
while 1
    [vector_out, fval, exitflag] = fminsearch(@get_differences,vector,options);
    iteration = iteration+1;
    waitbar(iteration / 10, h_wait)
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

close(h_wait);


matrix_out = matrix;
Uniq = unique(grouped_indices);
for i=1:length(Uniq)
    curr_indices = grouped_indices == Uniq(i);
    curr_positions = Indices(curr_indices, :);
    for j=1:size(curr_positions, 1)
        matrix_out(curr_positions(j, 1), curr_positions(j, 2)) = vector_out(i);
    end
end

close(h);
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
global matrix Indices grouped_indices domain spectrum roi processing_info selected_spin_region 

matrix_in = matrix;
Uniq = unique(grouped_indices);
for i=1:length(Uniq)
    curr_indices = grouped_indices == Uniq(i);
    curr_positions = Indices(curr_indices, :);
    for j=1:size(curr_positions, 1)
        matrix_in(curr_positions(j, 1), curr_positions(j, 2)) = vector(i);
    end
end

processing_info.spin_matrix = matrix_in;
%processing_info.spin_matrix_changed = 1;
[sim_ppm, sim_fid] = Diagonalization(processing_info);

rmsd = get_rmsd(sim_ppm, sim_fid, selected_spin_region );

% roi_region_spec = domain > roi(1) & domain < roi(2);
% spec_domain = domain(roi_region_spec);
% spec_fid = spectrum(roi_region_spec);
% spec_fid = spec_fid ./max(spec_fid );
% roi_region_sim = sim_ppm > roi(1) & sim_ppm < roi(2);
% sim_ppm = sim_ppm(roi_region_sim);
% sim_fid = sim_fid(roi_region_sim);
% sim_fid = sim_fid./max(sim_fid);
% 
% step = min(min(diff(sim_ppm)), min(diff(spec_domain)));
% Min = max([min(sim_ppm), min(spec_domain)]);
% Max = min([max(sim_ppm), max(spec_domain)]);
% new_domain = Min:step:Max;
% 
% sim_fid = interp1(sim_ppm, sim_fid,new_domain);
% spec_fid = interp1(spec_domain, spec_fid,new_domain);
% 
% 
% sim_fid(isnan(sim_fid)) = 0;
% spec_fid(isnan(spec_fid)) = 0;
% sim_fid = sim_fid-min(sim_fid);
% spec_fid = spec_fid-min(spec_fid);
% 
% 
% rmsd = sqrt(sum((sim_fid-spec_fid).^2));

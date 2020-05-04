function [new_coupling_matrix, msg] = optimize_additional_couplings(in_processing_info, in_domain, in_spectrum, in_selected_groups)
global domain spectrum roi processing_info_opt selected_groups




in_roi = [in_processing_info.ROI_min, in_processing_info.ROI_max];

selected_groups = in_selected_groups;
processing_info_opt = in_processing_info;
domain = in_domain;
spectrum = in_spectrum;
roi = in_roi;

Optimization_variables = {'Optimization on:', 'additional coupling constants'};
h = msgbox(Optimization_variables, 'please wait!');

grouped_groups = unique(in_selected_groups(:, 3));
num_vars = length(grouped_groups);

temp_vector = zeros(size(in_selected_groups, 1), 1);
for i=1:size(in_selected_groups, 1)
    indices = find(in_processing_info.additional_couplings_groups(:, 3) == in_selected_groups(i, 1) & in_processing_info.additional_couplings_groups(:, 4) == in_selected_groups(i, 2));
    temp_vector(i) = in_processing_info.additional_couplings_groups(indices(1), 2);
end

vector = zeros(num_vars, 1);
vector_entry_index = 0;
seen = false(size(in_selected_groups, 1), 1);
for i=1:size(in_selected_groups, 1)
    if ~seen(i)
        indices = in_selected_groups(:, 3) == in_selected_groups(i, 3);
        seen(indices) = true;
        vector_entry_index = vector_entry_index+1;
        vector(vector_entry_index) = mean(temp_vector(indices));
    end
end


%set(h,'WindowStyle','modal');
%figure(h);
%vector = in_couplings;
options = optimset('Display', 'off');
[vector, fval, exitflag] = fminsearch(@get_differences,vector, options);

vector_out = zeros(size(selected_groups, 1), 1);
vector_entry_index = 0;
seen = false(size(selected_groups, 1), 1);
for i=1:size(selected_groups, 1)
    if ~seen(i)
        indices = selected_groups(:, 3) == selected_groups(i, 3);
        seen(indices) = true;
        vector_entry_index = vector_entry_index+1;
        vector_out(indices) = vector(vector_entry_index);
    end
end

new_coupling_matrix = in_processing_info.additional_couplings_groups;
for i=1:size(in_selected_groups, 1)
    indices = in_processing_info.additional_couplings_groups(:, 3) == in_selected_groups(i, 1) & in_processing_info.additional_couplings_groups(:, 4) == in_selected_groups(i, 2);
    new_coupling_matrix(indices, 2) = vector_out(i);
end




% for i =1:length(atom_indices)
%     for j=1:length(vector_out)
%         new_coupling_matrix = [new_coupling_matrix; [atom_indices(i), vector_out(j)]];
%     end
% end

close(h);
if exitflag == 1
    msg = sprintf('Simplex process coverged! L2: %.03f', fval);
elseif exitflag == 0
    msg = sprintf('Maximum num iterations was reached. L2: %.03f', fval);
else
    msg = 'Simplex operation has crashed!';
end





function rmsd = get_differences(vector)
global processing_info_opt domain spectrum roi  selected_groups

%
vector_temp = zeros(size(selected_groups, 1), 1);
vector_entry_index = 0;
seen = false(size(selected_groups, 1), 1);
for i=1:size(selected_groups, 1)
    if ~seen(i)
        indices = selected_groups(:, 3) == selected_groups(i, 3);
        seen(indices) = true;
        vector_entry_index = vector_entry_index+1;
        vector_temp(indices) = vector(vector_entry_index);
    end
end

%fprintf('[%f, %f]\n', vector(1), vector(2));
for i=1:size(selected_groups, 1)
    indices = processing_info_opt.additional_couplings_groups(:, 3) == selected_groups(i, 1) & processing_info_opt.additional_couplings_groups(:, 4) == selected_groups(i, 2);
    processing_info_opt.additional_couplings_groups(indices, 2) = vector_temp(i);
end


processing_info_opt.additional_couplings = processing_info_opt.additional_couplings_groups(:, 1:2);
[sim_ppm, sim_fid] = Diagonalization(processing_info_opt);

roi_region_spec = domain > roi(1) & domain < roi(2);
spec_domain = domain(roi_region_spec);
spec_fid = spectrum(roi_region_spec);
spec_fid = spec_fid ./max(spec_fid );
roi_region_sim = sim_ppm > roi(1) & sim_ppm < roi(2);
sim_ppm = sim_ppm(roi_region_sim);
sim_fid = sim_fid(roi_region_sim);
sim_fid = sim_fid./max(sim_fid);


step = min(min(diff(sim_ppm)), min(diff(spec_domain)));
Min = max([min(sim_ppm), min(spec_domain)]);
Max = min([max(sim_ppm), max(spec_domain)]);
new_domain = Min:step:Max;

sim_fid = interp1(sim_ppm, sim_fid,new_domain);
spec_fid = interp1(spec_domain, spec_fid,new_domain);

sim_fid(isnan(sim_fid)) = 0;
spec_fid(isnan(spec_fid)) = 0;
sim_fid = sim_fid-min(sim_fid);
spec_fid = spec_fid-min(spec_fid);

rmsd = sqrt(sum((sim_fid-spec_fid).^2));



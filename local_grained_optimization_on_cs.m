function matrix_out= local_grained_optimization_on_cs(in_Indices, in_processing_info, In_domain, In_spectrum, Min, Max)
global matrix Indices domain spectrum roi processing_info selected_spin_region 
h = msgbox('Optimizing chemical shifts', 'please wait!');
set(h,'WindowStyle','modal');
figure(h);

processing_info = in_processing_info;
Indices = in_Indices;
domain = In_domain;
spectrum = In_spectrum;
in_roi = [in_processing_info.ROI_min, in_processing_info.ROI_max];
roi = in_roi;
in_matrix = in_processing_info.spin_matrix;
matrix = in_matrix;

selected_spin_region = get_selected_spins_domain(Indices);

%options = optimset('Display', 'off');
%value_out = fminbnd(@get_differences, Min, Max, options);
value_out = my_fminbnd(Min, Max);

matrix_out = matrix;
for i=1:size(Indices, 1)
    matrix_out(Indices(i, 1), Indices(i, 2)) = value_out;
end
close(h);

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

% function rmsd = get_differences(value)
% global matrix Indices processing_info domain spectrum roi selected_spin_region %counter 
% 
% in_matrix = matrix;
% for i=1:size(Indices, 1)
%     in_matrix(Indices(i, 1), Indices(i, 2)) = value;
% end
% 
% processing_info.spin_matrix = in_matrix;
% [sim_ppm, sim_fid] = Diagonalization(processing_info);
% rmsd = get_rmsd(sim_ppm, sim_fid, selected_spin_region);

function value_out = my_fminbnd(Min, Max)
global matrix Indices processing_info domain spectrum roi selected_spin_region 
values = Min:(Max-Min)/101:Max;
rmsds = zeros(length(values), 1);
for val_iter=1:length(values)
    in_matrix = matrix;
    for i=1:size(Indices, 1)
        in_matrix(Indices(i, 1), Indices(i, 2)) = values(val_iter);
    end
    processing_info.spin_matrix = in_matrix;
    [sim_ppm, sim_fid] = Diagonalization(processing_info);
    rmsds(val_iter) = get_rmsd(sim_ppm, sim_fid, selected_spin_region);
end
[~, index] = min(rmsds);
value_out = values(index);

% roi_region_spec = domain > roi(1) & domain < roi(2);
% spec_domain = domain(roi_region_spec);
% spec_fid = spectrum(roi_region_spec);
% spec_fid = spec_fid ./max(spec_fid );
% roi_region_sim = sim_ppm > roi(1) & sim_ppm < roi(2);
% sim_ppm = sim_ppm(roi_region_sim);
% sim_fid = sim_fid(roi_region_sim);
% sim_fid = sim_fid./max(sim_fid);
% 
% 
% step = min(min(diff(sim_ppm)), min(diff(spec_domain)));
% Min = max([min(sim_ppm), min(spec_domain)]);
% Max = min([max(sim_ppm), max(spec_domain)]);
% new_domain = Min:step:Max;
% 
% sim_fid = interp1(sim_ppm, sim_fid,new_domain);
% spec_fid = interp1(spec_domain, spec_fid,new_domain);
% 
% sim_fid(isnan(sim_fid)) = 0;
% spec_fid(isnan(spec_fid)) = 0;
% sim_fid = sim_fid-min(sim_fid);
% spec_fid = spec_fid-min(spec_fid);
% 
% %rmsd = sqrt(sum((sim_fid-spec_fid).^2));
% rmsd = sum(abs((sim_fid-spec_fid)))/length(spec_fid);

%
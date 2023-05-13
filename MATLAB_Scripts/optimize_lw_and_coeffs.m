function vector_out = optimize_lw_and_coeffs(in_processing_info, in_domain, in_spectrum)
global domain spectrum roi processing_info

in_roi = [in_processing_info.ROI_min, in_processing_info.ROI_max];

processing_info = in_processing_info;
domain = in_domain;
spectrum = in_spectrum;
roi = in_roi;

Optimization_variables = {'Optimization on:', 'lw, Gaussian_coeff, Lorentzian_coeff'};
h = msgbox(Optimization_variables, 'please wait!');
set(h,'WindowStyle','modal');
figure(h);

for iter=1:4
    % optimize line shape
    %options = optimset('Display', 'off', 'PlotFcns', @optimplotx);
    options = optimset('Display', 'off');
    vector_out_gauss = fminbnd(@get_differences_line_shape, 0, 1, options);

    % optimize line width
    options = optimset('Display', 'off');
    processing_info.gau_coeff = vector_out_gauss;
    processing_info.lor_coeff =  1-vector_out_gauss;
    vector_out_lw = fminbnd(@get_differences_line_width, 0, 5, options);
    processing_info.line_width = vector_out_lw;
end
vector_out = [vector_out_lw, 1-vector_out_gauss, vector_out_gauss];

% vector = [in_lw, in_lorentzian_coeff, in_guassian_coeff];
% options = optimset('Display', 'off');
% [vector_out, fval, exitflag] = fminsearch(@get_differences,vector, options);

close(h);
% if exitflag == 1
%     msg = sprintf('Simplex process coverged! L2: %.03f', fval);
% elseif exitflag == 0
%     msg = sprintf('Maximum num iterations was reached. L2: %.03f', fval);
% else
%     msg = 'Simplex operation has crashed!';
% end



function rmsd = get_differences_line_width(vector)
global processing_info domain spectrum roi


processing_info.line_width = vector;
[sim_ppm, sim_fid] = Diagonalization(processing_info);

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

%rmsd = sqrt(sum((sim_fid-spec_fid).^2));
rmsd = sum(abs((sim_fid-spec_fid)))/length(spec_fid);



function rmsd = get_differences_line_shape(vector)
global processing_info domain spectrum roi

processing_info.gau_coeff = vector;
processing_info.lor_coeff = 1-vector;

[sim_ppm, sim_fid] = Diagonalization(processing_info);

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

%rmsd = sqrt(sum((sim_fid-spec_fid).^2));
rmsd = sum(abs((sim_fid-spec_fid)))/length(spec_fid);














% 10_Nov_2016
% function [vector_out, msg] = optimize_lw_and_coeffs(in_processing_info, in_domain, in_spectrum)
% global domain spectrum roi processing_info
% in_lw = in_processing_info.line_width;
% in_guassian_coeff = in_processing_info.gau_coeff;
% in_lorentzian_coeff = in_processing_info.lor_coeff;
% in_roi = [in_processing_info.ROI_min, in_processing_info.ROI_max];
% 
% processing_info = in_processing_info;
% domain = in_domain;
% spectrum = in_spectrum;
% roi = in_roi;
% 
% Optimization_variables = {'Optimization on:', 'lw, Gaussian_coeff, Lorentzian_coeff'};
% h = msgbox(Optimization_variables, 'please wait!');
% set(h,'WindowStyle','modal');
% figure(h);
% vector = [in_lw, in_lorentzian_coeff, in_guassian_coeff];
% options = optimset('Display', 'off');
% [vector_out, fval, exitflag] = fminsearch(@get_differences,vector, options);
% 
% close(h);
% if exitflag == 1
%     msg = sprintf('Simplex process coverged! L2: %.03f', fval);
% elseif exitflag == 0
%     msg = sprintf('Maximum num iterations was reached. L2: %.03f', fval);
% else
%     msg = 'Simplex operation has crashed!';
% end
% 
% function rmsd = get_differences(vector)
% global processing_info domain spectrum roi
% 
% 
% processing_info.line_width = vector(1);
% processing_info.lor_coeff =  vector(2);
% processing_info.gau_coeff = vector(3);
% [sim_ppm, sim_fid] = Diagonalization(processing_info);
% 
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
% rmsd = sqrt(sum((sim_fid-spec_fid).^2));
% 
% 


function rmsd = get_rmsd(sim_ppm, sim_fid, selected_region)
global domain spectrum %counter

%roi_region_spec = domain > roi(1) & domain < roi(2);
region = false(size(domain));
for i=1:size(selected_region, 1)
    indices = domain > selected_region(i, 1) & domain < selected_region(i, 2);
    region(indices) = true;
end
spec_domain = domain(region);
spec_fid = spectrum(region);
spec_fid = spec_fid ./max(spec_fid );

%roi_region_sim = sim_ppm > roi(1) & sim_ppm < roi(2);
region = false(size(sim_ppm));
for i=1:size(selected_region, 1)
    indices = sim_ppm > selected_region(i, 1) & sim_ppm < selected_region(i, 2);
    region(indices) = true;
end
sim_ppm = sim_ppm(region);
sim_fid = sim_fid(region);
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

% h = figure(); plot(spec_domain, spec_fid, 'b');
% hold on
% plot(sim_ppm, sim_fid, 'r')
% title(sprintf('%04f', rmsd))
% saveas(h, sprintf('test_%d.jpg', counter), 'jpg');
% counter = counter+1;
% close(h)


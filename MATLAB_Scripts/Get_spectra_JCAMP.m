function [spectrum, domain, field] = Get_spectra_JCAMP(Entry, folder_path)
fpath = sprintf('%s/%s', folder_path, Entry.spectrum.path);

JCAMPStruct = jcampread(fpath);
Notes = JCAMPStruct.Notes;
for i=1:size(Notes, 1)
    if strcmp(Notes{i, 1}, '.OBSERVEFREQUENCY')
        field = str2double(Notes{i, 2});
    end
end
if strcmp(JCAMPStruct.Blocks.XUnits, 'HZ')
    domain = JCAMPStruct.Blocks.XData./field;
    %figure, plot(domain, JCAMPStruct.Blocks.YData)
else
    domain = JCAMPStruct.Blocks.XData;
end
spectrum = JCAMPStruct.Blocks.YData;
spectrum = spectrum./max(spectrum);
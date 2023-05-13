function [spectrum, domain, field] = Get_csv_spectrum(Entry, folder_path)
field = 500;
fpath = sprintf('%s/%s', folder_path, Entry.spectrum.path);
fin = fopen(fpath, 'r');
tline = fgetl(fin);
counter = 0;
while ischar(tline)
    content = strsplit(tline, ',');
    counter = counter+1;
    domain(counter) = str2double(content{1});
    spectrum(counter) = str2double(content{2});
    tline = fgetl(fin);
end
fclose(fin);
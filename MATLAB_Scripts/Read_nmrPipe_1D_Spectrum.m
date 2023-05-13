
function [spectrum, domain, field] = Read_nmrPipe_1D_Spectrum(Entry, folder_path)
input_file = sprintf('%s/%s', folder_path, Entry.spectrum.path);

filein = fopen(input_file, 'r', 'b');
if filein<1
    Error_Handle('Couldnt read the spectra')
end
[header, ~] = fread(filein, 512, 'float32');

n_dimension = header(10);

if (fix(n_dimension) ~= n_dimension) || (abs(n_dimension) > 10)      % we should read little-endial rather than big-endian 
    fclose(filein);
    filein = fopen(input_file, 'r', 'l');
    [header, ~] = fread(filein, 512, 'float32');
    n_dimension = header(10);
end

tp = header(222);
n1 = header(220);
n2 = header(100);
SW(1) = header(101);
frq(1) = header(120);
ref(1) = header(102);

if tp == 0 
    spectra_size(1) = n2;
    spectra_size(2) = n1;
elseif tp == 1  
    spectra_size(1) = n1;
    spectra_size(2) = n2;
end
    
middle(1) = (ref(1) + SW(1)/2)/frq(1);

data = cell(n1, 1);
for i = 1:n1
    [data{i}, ~] = fread(filein, n2, 'float32');
end

spectrum = zeros(spectra_size(1), spectra_size(2));

if tp == 0
	for i = 1:spectra_size(2)
        spectrum(:,i) = data{i};    
	end
elseif tp == 1
	for i = 1:spectra_size(1)
        spectrum(i,:) = data{i}';    
	end
end    
fclose(filein);
Params.xT = length(spectrum);

Params.xCAR = middle(1);
Params.xOBS = frq(1);
Params.n_dimension = n_dimension;
spectrum = spectrum';
spectrum = flipud(spectrum);
spectrum = fliplr(spectrum);
field = Params.xOBS;
Params.xSW = SW(1);
Max_ppm = (.5-(1               /Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
Min_ppm = (.5-(length(spectrum)/Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
if Min_ppm > 10
    Params.xSW = header(230);
    Max_ppm = (.5-(1               /Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
    Min_ppm = (.5-(length(spectrum)/Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
end

domain = (Min_ppm:(Max_ppm-Min_ppm)/(length(spectrum)-1):Max_ppm)';





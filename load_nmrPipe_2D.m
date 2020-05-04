function [spectrum, Params, domain_x, field_x, domain_y, field_y] = load_nmrPipe_2D(input_file)

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
SW(2) = header(230);
frq(1) = header(120);
frq(2) = header(219);
ref(1) = header(102);
ref(2) = header(250);

if tp == 0 
    spectra_size(1) = n2;
    spectra_size(2) = n1;
elseif tp == 1  
    spectra_size(1) = n1;
    spectra_size(2) = n2;
end
    
middle(1) = (ref(1) + SW(1)/2)/frq(1);
if frq(2) == 0
    middle(2) = 0;
else
    middle(2) = (ref(2) + SW(2)/2)/frq(2);
end
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
[Params.xT, Params.yT]= size(spectrum);
Params.xSW = SW(1);
Params.ySW = SW(2);
Params.xCAR = middle(1);
Params.yCAR = middle(2);
Params.xOBS = frq(1);
Params.yOBS = frq(2);
Params.n_dimension = n_dimension;
spectrum = spectrum';




Max_ppm = (.5-(1               /Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
Min_ppm = (.5-(length(spectrum)/Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
if Min_ppm > 10
    Params.xSW = header(230);
    Max_ppm = (.5-(1               /Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
    Min_ppm = (.5-(length(spectrum)/Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
end
domain_x = Min_ppm:(Max_ppm-Min_ppm)/(Params.xT-1):Max_ppm;
field_x = Params.xOBS;



Max_ppm = (.5-(1               /Params.yT))/(Params.yOBS/Params.ySW)+Params.yCAR;
Min_ppm = (.5-(length(spectrum)/Params.yT))/(Params.yOBS/Params.ySW)+Params.yCAR;

domain_y = Min_ppm:(Max_ppm-Min_ppm)/(Params.yT-1):Max_ppm;
field_y = Params.yOBS;



function [spectrum, domain, field, OFFSET] = Get_spectra_bruker(Entry, folder_path)
path_1H = Entry.spectrum.path;
input_file = sprintf('%s/%s/pdata/1/1r', folder_path, path_1H);
Acqus_File_Path =  sprintf('%s/%s/acqus', folder_path, path_1H);
Proc_File_Path = sprintf('%s/%s/pdata/1/procs', folder_path, path_1H);
[spectrum, Params] = Read_Bruker_1D(input_file, Acqus_File_Path, Proc_File_Path);
spectrum = spectrum./max(spectrum);
freq_max = (.5-(0/Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
freq_min = (.5-((Params.xT-1)/Params.xT))/(Params.xOBS/Params.xSW)+Params.xCAR;
domain = freq_min:(freq_max-freq_min)/(length(spectrum)-1):freq_max;
OFFSET = (Params.xOFFSET-freq_max);
domain = domain+ OFFSET;
field = Params.SF;

function [spectrum, Params] = Read_Bruker_1D(input_file, Acqus_File_Path, Proc_File_Path)
fid = fopen(input_file, 'rb');
if fid<1
    error('File not found %s\n', input_file);
else
    spectrum = fread(fid, 'int');
end
fclose(fid);

[OBS, CAR, Error] = Get_Bruker_Info_1D_Acqus(Acqus_File_Path);
if ~strcmp(Error, '')
    error(Error)
end
[SW, Length, OFFSET, SF, Error] = Get_Bruker_Info_1D_Procs(Proc_File_Path);
if ~strcmp(Error, '')
    error(Error)
end
Params.xOFFSET = OFFSET;
Params.xT = length(spectrum);
Params.xOBS = OBS;
Params.xCAR = CAR;
Params.xSW = SW;
Params.Length = Length;
Params.SF = SF;

function [OBS, CAR, Error] = Get_Bruker_Info_1D_Acqus(Acqus_File_Path)

fid = fopen(Acqus_File_Path, 'r');
if fid < 1
    error('Could not open the acqus file!')
end

OBS = 0;
CAR = 0;
O1 = 0;

tline = fgetl(fid);
Satisfied = false;
while ~Satisfied
    if ~isempty(strfind(tline, '##$O1= '))
        tline = strrep(tline, '##$O1= ', '');
        O1 = str2double(tline);
    end
    if ~isempty(strfind(tline, '##$BF1= '))
        tline = strrep(tline, '##$BF1= ', '');
        OBS = str2double(tline);
    end
    tline = fgetl(fid);
    if ~ischar(tline) || (OBS~=0 && O1 ~= 0)
        Satisfied = true;
    end
end

if (OBS~=0 && O1 ~= 0)
    CAR = O1/OBS;
    Error = '';
else
    Error = 'Could not find all the parameters from the aqcus file';
end
fclose(fid);

function [SW, Length, OFFSET, SF, Error] = Get_Bruker_Info_1D_Procs(Proc_File_Path)

fid = fopen(Proc_File_Path, 'r');
if fid < 1
    error('Could not open the proc file!')
end

SW = 0;
Length = 0;
OFFSET = 0;
tline = fgetl(fid);
Satisfied = false;
SF = 0;
while ~Satisfied
    
    if ~isempty(strfind(tline, '##$SF= '))
        tline = strrep(tline, '##$SF= ', '');
        SF = str2double(tline);
    end
    if ~isempty(strfind(tline, '##$OFFSET= '))
        tline = strrep(tline, '##$OFFSET= ', '');
        OFFSET = str2double(tline);
    end    
    if ~isempty(strfind(tline, '##$SW_p= '))
        tline = strrep(tline, '##$SW_p= ', '');
        SW = str2double(tline);
    end
    if ~isempty(strfind(tline, '##$SI= '))
        tline = strrep(tline, '##$SI= ', '');        
        Length = str2double(tline);
    end
    tline = fgetl(fid);
    if ~ischar(tline) || (SW~=0 && Length ~= 0)
        Satisfied = true;
    end
end

if (SW~=0 && Length ~= 0)
    Error = '';
else
    Error = 'Could not find all the parameters from the aqcus file';
end
fclose(fid);

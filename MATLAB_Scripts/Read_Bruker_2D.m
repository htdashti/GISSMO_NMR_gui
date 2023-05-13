function [Spectrum, Params] = Read_Bruker_2D(input_file, Acqus_2D_H_File_Path, Procs_2D_H_File_Path, Acqus_2D_C_File_Path, Procs_2D_C_File_Path)



% 
% [FID, MESSAGE] = fopen(File,'r',endian);
% if FID == -1
% 	disp(MESSAGE);
% 	error(['RBNMR: Error opening file (',File,').']);
% end
% 
% A.Data = fread(FID,'int32');



fid_aqus = fopen(Acqus_2D_H_File_Path, 'r');
fid_procs = fopen(Procs_2D_H_File_Path, 'r');
if fid_aqus < 1 || fid_procs < 1
    fclose(fid_aqus);
    fclose(fid_procs);
    error('Could not open %s or %s\n', Acqus_2D_H_File_Path, Procs_2D_H_File_Path);
else
    [H_OBS, H_CAR, H_Error_aqus] = Get_Bruker_Info_1D_Acqus(fid_aqus);
    [H_SW, H_Length, Field, OFFSET, BYTORDP, XDIM, H_Error_proc] = Get_Bruker_Info_1D_Procs(fid_procs);
    if ~isempty(H_Error_aqus) || ~isempty(H_Error_proc)
        fclose(fid_aqus);
        fclose(fid_procs);
        error('Something went wrong with the params in %s or %s\n', Acqus_2D_H_File_Path, Procs_2D_H_File_Path);
    end
end
fclose(fid_aqus);
fclose(fid_procs);

Params.xfield = Field;
Params.xOBS = H_OBS;
Params.xCAR = H_CAR;
Params.xSW = H_SW;
Params.xT = H_Length;
Params.xOFFSET = OFFSET;
Params.xXDIM = XDIM;

fid_acqus = fopen(Acqus_2D_C_File_Path, 'r');
fid_procs = fopen(Procs_2D_C_File_Path, 'r');
if fid_acqus < 1 || fid_procs < 1
    fclose(fid_acqus);
    fclose(fid_procs);
    error('Could not open  %s or %s \n', Acqus_2D_C_File_Path, Procs_2D_C_File_Path);
else
    [C_OBS, C_CAR, C_Error_aqus] = Get_Bruker_Info_1D_Acqus(fid_acqus);
    [C_SW, C_Length, Field, OFFSET, BYTORDP, XDIM, C_Error_proc] = Get_Bruker_Info_1D_Procs(fid_procs);
    if ~isempty(C_Error_aqus) || ~isempty(C_Error_proc)
        fclose(fid_acqus);
        fclose(fid_procs);
        error('Something went wrong with the params in %s or %s\n', Acqus_2D_C_File_Path, Procs_2D_C_File_Path);
    end
end
fclose(fid_acqus);
fclose(fid_procs);

Params.yfield = Field;
Params.yOBS = C_OBS;
Params.yCAR = C_CAR;
Params.ySW = C_SW;
Params.yT = C_Length;
Params.yOFFSET = OFFSET;
Params.yXDIM = XDIM;

if BYTORDP == 0
    endian = 'l';
else
    endian = 'b';
end

fid = fopen(input_file, 'r', endian);
if fid < 1
    error('File not found %s\n', input_file);
else
    Spectrum_2D = fread(fid, 'int32');
end
fclose(fid);

%Spectrum = reshape(Spectrum_2D, H_Length, C_Length);

% from https://www.mathworks.com/matlabcentral/fileexchange/40332-rbnmr/content/rbnmr.m
%  Reorder submatrixes (se XWinNMR-manual, chapter 17.5 (95.3))
Spectrum = Spectrum_2D;
SI1 = Params.xT; SI2 = Params.yT;
XDIM1 =Params.xXDIM; XDIM2 =Params.yXDIM;

NoSM = SI1*SI2/(XDIM1*XDIM2);    % Total number of Submatrixes
NoSM2 = SI2/XDIM2;		 			% No of SM along F1

Spectrum = reshape(...
    permute(...
    reshape(...
    permute(...
    reshape(Spectrum,XDIM1,XDIM2,NoSM),...
    [2 1 3]),...
    XDIM2,SI1,NoSM2),...
    [2 1 3]),...
    SI1,SI2)';
            



function [SW, Length, Field, OFFSET, BYTORDP, XDIM, Error] = Get_Bruker_Info_1D_Procs(fid)

SW = 0;
Length = 0;
Field = 0;
tline = fgetl(fid);
Satisfied = false;
while ~Satisfied
    if ~isempty(strfind(tline, '##$SW_p= '))
        tline = strrep(tline, '##$SW_p= ', '');
        SW = str2double(tline);
    end
    if ~isempty(strfind(tline, '##$SI= '))
        tline = strrep(tline, '##$SI= ', '');        
        Length = str2double(tline);
    end
    if ~isempty(strfind(tline, '##$SF= '))
        tline = strrep(tline, '##$SF= ', '');        
        Field = str2double(tline);
    end
    if ~isempty(strfind(tline, '##$OFFSET= '))
        tline = strrep(tline, '##$OFFSET= ', '');
        OFFSET = str2double(tline);
    end
    if ~isempty(strfind(tline, '##$BYTORDP= '))
        tline = strrep(tline, '##$BYTORDP= ', '');
        BYTORDP = str2double(tline);
    end
    if ~isempty(strfind(tline, '##$XDIM= '))
        tline = strrep(tline, '##$XDIM= ', '');
        XDIM = str2double(tline);
    end
    
    tline = fgetl(fid);
    if ~ischar(tline) 
        Satisfied = true;
    end
end

if (SW~=0 && Length ~= 0 && Field ~= 0)
    Error = '';
else
    Error = 'Could not find all the parameters from the aqcus file';
end


function [OBS, CAR, Error] = Get_Bruker_Info_1D_Acqus(fid)

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

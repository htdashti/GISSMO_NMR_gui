function [sim_ppm, sim_fid] = Diagonalization_w_coefficients(processing_info)

[sim_ppm, sim_fid] =  get_trans_matrices(processing_info);

function [ppm, spec] = get_trans_matrices(processing_info)


matrix = processing_info.spin_matrix;
field = processing_info.field;
ftnum = processing_info.numpoints;
lw = processing_info.line_width;
lorentzian_coeff = processing_info.lor_coeff;
guassian_coeff = processing_info.gau_coeff;
additional_coupling = processing_info.additional_couplings;
spin_index = additional_coupling(:, 1);
spin_coeffs= additional_coupling(:, 2);
spin_matrix_changed_flag = processing_info.spin_matrix_changed;


Spins=length(diag(matrix));
spin(Spins, Spins).shift = 0;
for ii=1:Spins
  spin(ii,ii).shift=matrix(ii,ii)*field;
end
for ii=1:Spins
  for jj=ii+1:Spins
    spin(ii,jj).J=matrix(ii,jj);
  end
end

[State, OBS, Ham] = get_matrices(spin, spin_matrix_changed_flag);


Ham = full(Ham);
[v,s]=eig(Ham);
v=sparse(v);
s=diag(s);
clear Ham
mask = (abs(v) >= .01*max(max(v))); %remove values less than threshold
v = v.*mask;
clear mask
max_ppm = -1;
min_ppm = 10;
trans_ppm_list = cell(length(OBS), 1);
for spin_iter=1:length(OBS)
    obs = OBS{spin_iter};
    Ar=(v'*obs*v).*(v'*State*v);
    mask = (abs(Ar) >= .01*max(max(Ar))); %remove values less than threshold
    Ar = Ar.*mask;
    clear mask obs

    [xx,yy,c]=find(Ar);
    c=c/max(c);
    clear Ar
    trans = [abs(s(yy(:))-s(xx(:))) c];
    ppms = trans(:, 1)./field;
    trans_ppm_list{spin_iter} = [ppms c];
    if max(ppms) > max_ppm
        max_ppm = max(ppms);
    end
    if min(ppms) < min_ppm
        min_ppm = min(ppms);
    end
end
[max_ppm, min_ppm] = Check_for_zero_domain(max_ppm, min_ppm);

Max_Coeff = 1.2;
Min_Coef = .8;
Max_ppm = max(diag(matrix));
Min_ppm = min(diag(matrix));
Min_domain = Min_Coef*Min_ppm;
Max_domain = Max_Coeff*Max_ppm;
[Max_domain, Min_domain] = Check_for_zero_domain(Max_domain, Min_domain);
Step = max([(max_ppm-min_ppm)/(ftnum-1), 10^-4]);
ppm = processing_info.ppm; %ppm = Min_Coef*min_ppm:Step:Max_Coeff*max_ppm;
if length(ppm) == 1
    Step = max([(Max_domain-Min_domain)/(ftnum-1), 10^-4]);
    ppm = Min_Coef*min(Min_domain):Step:Max_Coeff*Max_domain;    
end
% sw=(Max_domain-Min_domain)*field;
% dw= 2/sw;
dw = processing_info.dw;

sim_fid = 0;
temp = 0;
for spin_iter =1:length(OBS)
    trans_ppm = trans_ppm_list{spin_iter};
    spec=zeros(length(ppm),1);
    for ii=1:length(trans_ppm(:,1))
      [~,n]=min(abs((trans_ppm(ii,1))-ppm));
      spec(n)=spec(n)+trans_ppm(ii,2);
    end
    fd=ifft(spec);
    t=0:length(fd)-1;
    coef = 1;
    list = find(spin_iter == spin_index);
    for i=1:length(list)
        %coef = coef.*cos(t.*dw*spin_coeffs(list(i))/4);
        coef = coef.*cos(pi.*t.*dw*spin_coeffs(list(i))/2);
    end
    %ex=lorentzian_coeff*exp(-t*dw*pi*lw)+guassian_coeff*exp(-t.^2*dw*pi*lw);
    ex=lorentzian_coeff*exp(-t*dw*pi*lw)+guassian_coeff*exp(-t*dw*pi*lw);
    temp = temp+coef'.*ex'.*fd;
end
sim_fid = sim_fid+real(fft(temp));
spec = sim_fid./max(sim_fid);
spec = Mean_zero_spectrum(spec);

function [max_ppm, min_ppm] = Check_for_zero_domain(max_ppm, min_ppm)
if abs(max_ppm-min_ppm) <= 10^-1
    Mean = mean([max_ppm, min_ppm]);
    max_ppm = Mean+.1;
    min_ppm = Mean-.1;
end

function [State, OBS, Ham] = get_matrices(spin, spin_matrix_changed_flag)
global g_State g_OBS
e=eye(2);
x=0.5*fliplr(e);
z=0.5*e;
z(2,2)=-0.5;
y=sqrt(-1)*(z*x-x*z);
spin_len = size(spin, 1);
 if spin_matrix_changed_flag %g_spin_len ~= spin_len
%     g_spin_len = spin_len;
    State = get_State(spin_len, x);
    OBS = get_OBS(spin_len, State, y, x);
    Ham=get_Ham(spin_len,x, y, z,spin);
else
    State = g_State;
    OBS = g_OBS;
    Ham = get_precal_Ham(spin_len, z,spin);
end

function Ham = get_precal_Ham(n, z,spin)
global g_cout1 g_cout2 g_cout3 g_c_fin
N = 2^n;
Ham = sparse(N,N);  
for i=1:n-1
    c1=z;
    e1=eye(2^(i-1)); e2=eye(2^(n-i));
    c=kron(kron(e1,c1),e2);
    Ham=Ham+c*spin(i,i).shift;
    for j=i+1:n
        J_Coupling = spin(i,j).J;
        cout1 = g_cout1{i, j};
        cout2 = g_cout2{i, j};
        cout3 = g_cout3{i, j};
        Ham = Ham+(cout1+cout2+cout3)*J_Coupling;
    end
end

Ham=Ham+g_c_fin*spin(n,n).shift;


function Ham=get_Ham(n, x, y, z, spin)
global g_cout1 g_cout2 g_cout3 g_c_fin
N = 2^n;
Ham = sparse(N,N);  
c1=z;
for i=1:n-1
    e1=speye(2^(i-1)); 
    e2=speye(2^(n-i));
    c=kron(kron(e1,c1),e2);
    Ham=Ham+c*spin(i,i).shift;
    clear e1 e2 c
    for j=i+1:n
        J_Coupling = spin(i,j).J;
        e1=speye(2^(i-1)); e2=speye(2^(j-i-1)); e3=speye(2^(n-j));
        cout1=kron(kron(kron(kron(e1,x),e2),x),e3);
        cout2=kron(kron(kron(kron(e1,y),e2),y),e3);
        cout3=kron(kron(kron(kron(e1,z),e2),z),e3);
        g_cout1{i, j} = cout1;
        g_cout2{i, j} = cout2;
        g_cout3{i, j} = cout3;
        Ham = Ham+(cout1+cout2+cout3)*J_Coupling;
        clear e1 e2 e3 cout1 cout2 cout3
    end
end

i=n;
c1 = z;
e1=speye(2^(i-1)); e2=speye(2^(n-i));
c=kron(kron(e1,c1),e2);
g_c_fin = c;
Ham=Ham+c*spin(i,i).shift;


function Obs = get_OBS(n, State,y, x)
global g_OBS

Spins = n;
Obs = cell(Spins, 1);
for ii=1:Spins
    c1=x;
    e1=speye(2^(ii-1));
    e2=speye(2^(Spins-ii));
    c=kron(kron(e1,c1),e2);
    obsx=c;
    clear e1 e2 c
    c1=y;
    e1=speye(2^(ii-1));
    e2=speye(2^(Spins-ii));
    c=kron(kron(e1,c1),e2);
    obsy=sqrt(-1)*c;
    clear e1 e2 c
    Obs{ii}=obsx+obsy;
end
g_OBS = Obs;

function State = get_State(n, x)
global g_State

N = 2^n;
State = sparse(N,N);
c1=x;
for i=1:n
    e1=speye(2^(i-1));
    e2=speye(2^(n-i));
    c=kron(kron(e1,c1),e2);
    State = State+c;
    clear e1 e2 c
end
g_State = State;






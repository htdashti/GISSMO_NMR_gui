function [sim_ppm, sim_fid] = Diagonalization(processing_info)
if ~isempty(processing_info.additional_couplings)
    [sim_ppm, sim_fid] = Diagonalization_w_coefficients(processing_info);
    return
end
matrix = processing_info.spin_matrix;
field = processing_info.field;
ftnum = processing_info.numpoints;
lw = processing_info.line_width;
lorentzian_coeff = processing_info.lor_coeff;
guassian_coeff = processing_info.gau_coeff;
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

Ar=(v'*OBS*v).*(v'*State*v);
mask = (abs(Ar) >= .01*max(max(Ar))); %remove values less than threshold
Ar = Ar.*mask;
clear mask OBS State

[xx,yy,c]=find(Ar);
c=c/max(c);
clear Ar

trans = [abs(s(yy(:))-s(xx(:))) c];
trans_ppm = [trans(:, 1)./field c];


Max_Coeff = 1.2;
Min_Coef = .8;
Max_ppm = max(diag(matrix));
Min_ppm = min(diag(matrix));
Min_domain = Min_Coef*Min_ppm;
Max_domain = Max_Coeff*Max_ppm;
[Max_domain, Min_domain] = Check_for_zero_domain(Max_domain, Min_domain);
 
Step = max([(max(trans_ppm(:, 1))-min(trans_ppm(:, 1)))/(ftnum-1), 10^-4]);
ppm = processing_info.ppm; %Min_Coef*min(trans_ppm(:, 1)):Step:Max_Coeff*max(trans_ppm(:, 1));
if length(ppm) == 1
    Step = max([(Max_domain-Min_domain)/(ftnum-1), 10^-4]);
    ppm = Min_Coef*min(Min_domain):Step:Max_Coeff*Max_domain;    
end
spec=zeros(length(ppm),1);
for ii=1:length(trans_ppm(:,1))
  [~,n]=min(abs((trans_ppm(ii,1))-ppm));
  spec(n)=spec(n)+trans_ppm(ii,2);
end

fd=ifft(spec);
% sw=(Max_domain-Min_domain)*field;
% dw= 2/sw;
dw = processing_info.dw;

t=0:length(fd)-1;

%ex=lorentzian_coeff*exp(-t*dw*pi*lw)+guassian_coeff*exp(-t.^2*dw*pi*lw);
ex=lorentzian_coeff*exp(-t*dw*pi*lw)+guassian_coeff*exp(-t*dw*pi*lw);
sim_fid = real(fft(ex'.*fd));

%sim_fid = flipud(sim_fid);
sim_fid = sim_fid./max(sim_fid);
sim_fid = Mean_zero_spectrum(sim_fid);
sim_ppm = ppm;

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
if spin_matrix_changed_flag
    State = get_State(spin_len, x);
    OBS = get_OBS(spin_len, State, y);
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


function OBS = get_OBS(n, State,y)
global g_OBS

OBS = State;
c1=y;
for i=1:n
    e1=speye(2^(i-1));
    e2=speye(2^(n-i));
    c=kron(kron(e1,c1),e2);
    OBS=OBS+sqrt(-1)*c;
    clear e1 e2 c
end
g_OBS = OBS;

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
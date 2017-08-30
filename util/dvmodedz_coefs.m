function a = dvmodedz_coefs(dz,rho,res)

% a = dvmodedz_coefs(dz,rho,res) Calculates coefficients a_mn =
% Integral[dphi_m/dz phi_n dz].  Input 'res' is multiplication
% factor for higher resolution vertical modes:  nzh = res*nz.

nz = length(dz);
z = get_z(dz);

% Interpolating mean density and getting high res modes
N = res*nz;
dzh(1:N,1)=1/N;
zh = get_z(dzh);
rhoh=interp1(z,rho,zh,'spline');
[kdh,phih] = vmodes(dzh,rhoh,1);
dphihdz = zeros(size(phih));
for m=1:N
  dphihdz(:,m) = (ddz(phih(:,m),zh))';
end
 
% Calculating coefficients a_mn = Integral[dphi_m/dz phi_n dz]
a = zeros(nz,nz);
for m=1:nz
  for n = 1:nz
    a(m,n) = -(phih(:,n).*dzh)'*dphihdz(:,m);
  end
end


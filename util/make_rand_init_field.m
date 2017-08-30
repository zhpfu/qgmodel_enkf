function [psi]=make_rand_init_field(kmax,k0,delk);

% [psi] = MAKE_RAND_INIT_FIELD(kmax,k0,delk)
%    Make initial streamfunction field with initial energy centered
%    at wavenumber k0, with gaussian distribution about isotropic
%    wavenumber of width delk.  Resulting field is size 2*(kmax+1).
%

nkx = 2*kmax+1; nky = kmax+1;

[kx_,ky_] = ndgrid(-kmax:kmax,0:kmax);

k_ = sqrt(kx_.^2+ky_.^2);
k_(kmax+1,1) =1;             % artificially set to 1 to avoid sing.

E = zeros(size(k_));
E(:,:) = exp(-(k_-k0).^2/delk);
psik = sqrt(E)./k_.*exp(2*pi*i*rand(size(E)));

disp('Normalizing field to E_tot=1 ...')

e = real(sum(sum(k_.^2.*psik.*conj(psik))));
psik = psik/sqrt(e);

psi = spec2grid(psik);


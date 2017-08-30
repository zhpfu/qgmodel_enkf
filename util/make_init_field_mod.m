function [qk,psik,psikm]=make_init_field_mod(dz,rho,F,kmax,k0,m0,delk);

% [qk,psik,psikm] = MAKE_INIT_FIELD_MOD(dz,rho,F,kmax,k0,m0,delk)
%     Make initialization field for a decay run which corresponds
%     to a field with energy centroid at isotropic horizontal 
%     wavenumber k0 with width delk and vertical mode number m0.  
%     Multiplies amp by a random phase at each wavenumber and 
%     inverts to get PV.  Output is spectral PV field, qk, and it 
%     is normalized such that total KE in field is 1.
%
%     See also MAKE_INIT_FIELD_MUM, 

nkx = 2*kmax+1; nky = kmax+1; nz = length(dz);

disp('Calculating initial energy spectrum...')

[kz,evec] = vmodes(dz,rho,F);
[kx_,ky_,kz_] = ndgrid(-kmax:kmax,0:kmax,kz);

k_ = sqrt(kx_.^2+ky_.^2);
k_(kmax+1,1,:)=1;             % artificially set to 1 to avoid sing.
mu_ = sqrt(k_.^2+kz_.^2);     % 3d geostrophic wavenumber

E = zeros(size(k_));
E(:,:,m0) = exp(-(k_(:,:,m0)-k0).^2/delk);
psikm = sqrt(E)./mu_.*exp(2*pi*i*rand(size(E)));

disp('Normalizing field to E_tot=1 ...')

e = real(sum(sum(sum(mu_.^2.*psikm.*conj(psikm)))));
psikm = psikm/sqrt(e);

disp('Inverting modal psi to layered psi...')

for k = 1:nkx;
   for l = 1:nky;
      psik(k,l,:) = evec*squeeze(psikm(k,l,:));
   end
end

disp('Calculating PV field from psi field...')

qk = get_qk(psik,dz,rho,F);

% McWilli '90 method

%a1 = 60; a2 = 60; a3 = 4; dphi = .083;
%phi_ = atan(kz_./k_);
%phi0 = atan(kz(m0)/k0);
%mu0 = sqrt(k0^2+kz(m0)^2);
%E = mu_.^a1./(mu_+(a2/a1)*mu0).^(a1+a2)./...
%  (1+((phi_-phi0)/dphi).^a3);


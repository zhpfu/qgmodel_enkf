function [qk,psik]=make_init_field_mum(dz,rho,u,F,beta,dc,nu,hve,kmax);

% [qk,psik] = MAKE_INIT_FIELD_MUM(dz,rho,u,F,beta,dc,nu,hve,kvec,lvec)
%     Make initialization field for a decay run which corresponds
%     to the most unstable vertical modes (MUM) at each wavenumber for
%     a given shear in the linear problem.  Multiplies amplitude
%     by a random phase at each wavenumber and inverts to get PV.
%     Output is spectral PV field, qk, and it is normalized such 
%     that total KE in field is 1.  
%
%     See also QGGR, MAKE_INIT_FIELD_MOD.

nkx = 2*kmax+1; nky = kmax+1; nz = length(dz);
mask = zeros(nkx,nky,nz);
i = sqrt(-1);

disp('Calculating growth rates and amplitudes...')

[gr,cm,amp] = qggr(dz,rho,u,F,beta,dc,nu,hve,-kmax:kmax,0:kmax);
amp(1:kmax+1,1,:) = 0.;  % Zero out irrelevant part of field

disp('Making psi field...')

for l = 1:nkx             % Use only the unstable part of the spectrum
  for m = 1:nky
    if gr(l,m)>0
      mask(l,m,1) = 1;
   end
  end
end
for n=1:nz
  mask(:,:,n) = mask(:,:,1);
end
psik = amp.*mask.*exp(2*pi*i*rand(size(amp)));
qk = get_qk(psik,dz,rho,F);

disp('Calculating KE spectra...')

[KE,APE] = get_budget(psik,qk,dz,rho,F);
e = sum(sum(sum(KE))) + sum(sum(sum(APE)));
psik = psik/sqrt(e);
qk = get_qk(psik,dz,rho,F);
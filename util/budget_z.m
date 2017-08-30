function [KE,APE,G,B,D,H] = budget_z(psik,dz,rho,F,ubar,dc,tdc,nu,hve);

% [KE,APE,G,B,D,H]= BUDGET_Z(psik,dz,rho,F,ubar,dc,tdc,nu,hve) 
%     Calculates E budget spectra for the zonal shear forcing (G), the 
%     dissipation by bottom drag (B), by thermal damping (D) and by
%     hyperviscosity (H).  Also calculates the kinetic energy spectra (KE)
%     and available potential energy (APE).  Uses spectral 
%     streamfunction (psik) field, as well as layer thicknesses (dz), 
%     densities (rho), and mean zonal velocities (ubar), and the Froude 
%     number (F), drag coefficient (dc), thermal damping coef (tdc), 
%     the hyperviscosity (nu) and hyperviscous exponent (hve).  Each
%     output is a full spectral field in the horizontal, but G and KE are 
%     3 dimensional, giving spectra for each layer.
%
%     See also BUDGET_MODE.

nkx = size(psik,1); nky = size(psik,2);  nz = size(psik,3);
kmax = nky-1; i = sqrt(-1);
qk = get_pv(psik,dz,rho,F);

if (length(dz)~=nz|length(rho)~=nz|size(qk,3)~=nz)
   error('Inconsistent number of layers in inputs');
end
if (nkx+1~=nky*2) 
   error('These are not spectral fields')
end
if nargin < 5
   ubar(1:nz,1)=0.; dc=0.; tdc=0.; nu=0.; hve=1;
end

[a,b,c,dz,rho,drho] = get_strat_params(dz,rho,F);
S = get_shear(a,b,c,ubar);

[kxm,kym] = ndgrid(-kmax:kmax,0:kmax);
ksqd = kxm.^2+kym.^2;

% All energetics multiplied by 2 since half spectral field is used

for n=1:nz
   KE(:,:,n) = dz(n)*rho(n)*ksqd.*real(psik(:,:,n).*conj(psik(:,:,n)));
   if n~=nz
      APE(:,:,n) = F*real(conj(psik(:,:,n+1)-psik(:,:,n)).*...
                   (psik(:,:,n+1)-psik(:,:,n))/drho(n));
   end
   G(:,:,n) = -2*real(dz(n)*i*kxm.*conj(psik(:,:,n)).*...
              (S(n)*psik(:,:,n)-ubar(n)*qk(:,:,n)));
   H(:,:,n) = 2*real(dz(n)*rho(n)*nu*ksqd.^hve.*conj(psik(:,:,n)).*...
      qk(:,:,n));     
end
D = 2*tdc*real(dz(1)*rho(1)*conj(psik(:,:,1)).*...
    (psik(:,:,2)-psik(:,:,1))+...
     dz(2)*rho(2)*conj(psik(:,:,2)).*(psik(:,:,1)-psik(:,:,2)));
B = -2*real(dc*dz(nz)*rho(nz)*ksqd.*conj(psik(:,:,nz)).*psik(:,:,nz));


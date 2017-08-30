function [KEm,APEm,Gm,Bm,Dm,Hm] = ...
   budget_mode(psikm,dz,rho,F,ubar,dc,tdc,nu,hve);

% [KE,APE,G,B,D,H] = BUDGET_MODE(psikm,dz,rho,F,ubar,dc,tdc,nu,hve) 
%     Calculates E budget spectra for the zonal shear forcing (G), 
%     the dissipation by bottom drag (B), by thermal damping 
%     (D) and by hyperviscosity (H).  Also calculates the kinetic 
%     energy spectra (KE) and available potential energy (APE).
%     Uses spectral streamfunction (psik) and PV (qk) fields, as 
%     well as layer thicknesses (dz), densities (rho), and mean  
%     zonal velocities (ubar), and the Froude number (F), drag  
%     coefficient (dc), thermal damping coefficient (tdc), the 
%     hyperviscosity (nu) and hyperviscous exponent (hve).  Each  
%     output is a full spectral field in the horizontal, but G and 
%     KE are 3 dimensional, giving spectra for each layer.
%
%     See also BUDGET_Z.

nkx = size(psikm,1); nky = size(psikm,2);  nz = size(psikm,3);
kmax = nky-1;

% Defaults:
ud = zeros(size(dz)); dcd = 0; tdcd = 0; nud = 0; hved = 1;

switch(nargin)
   case 4, hve = hved; nu = nud; tdc = tdcd; dc = dcd; u = ud;  
   case 5, hve = hved; nu = nud; tdc = tdcd; dc = dcd; 
   case 6, hve = hved; nu = nud; tdc = tdcd; 
   case 7, hve = hved; nu = nud; 
   case 8, error('Must specify hve with nu...')
end

if (length(dz)~=nz|length(rho)~=nz|length(ubar)~=nz)
   error('Inconsistent number of layers in inputs');
end
if (nkx+1~=nky*2) 
   error('These are not spectral fields')
end

KEm = zeros(size(psikm)); 
APEm = zeros(size(psikm)); 
Gm = zeros(size(psikm)); 
Dm = zeros(size(psikm)); 
Bm = zeros(size(psikm));
Hm = zeros(size(psikm));

[e,kd,evec] = tripintcoef(dz,rho,F);

um = evec'*(dz.*ubar);           % modal projection of mean shear
[kx_,ky_] = ndgrid(-kmax:kmax,0:kmax);
ksqd_ = kx_.^2+ky_.^2;

cntr=0;
if nargout>2 
   disp(strcat('Need ',num2str(length(find(abs(e)>100*eps))),' cycles...'))
end

% All energetics multiplied by two since only half spectral field is used

for p=1:nz
   KEm(:,:,p) = ksqd_.*real(psikm(:,:,p).*conj(psikm(:,:,p)));
   APEm(:,:,p) = kd(p)^2*real(psikm(:,:,p).*conj(psikm(:,:,p)));
   if nargout>2 
      for m=1:nz
         for n=1:nz
            if abs(e(m,n,p))>100*eps
              cntr=cntr+1;
              disp(num2str(cntr))
              Gm(:,:,p) = Gm(:,:,p)+2*real(e(m,n,p).*um(m).*...
                 conj(psikm(:,:,p)).*i.*kx_.*...
                 (kd(m)^2-kd(n)^2-ksqd_).*psikm(:,:,n));
            end
         end
         Dm(:,:,p) = Dm(:,:,p) - ...
            2*tdc*(evec(1,p)*(evec(1,m)-evec(2,m))*dz(1) + ...
            evec(2,p)*(evec(2,m)-evec(1,m))*dz(2))* ...
            real(conj(psikm(:,:,p)).*psikm(:,:,m));
         Bm(:,:,p) = Bm(:,:,p) - ...
            2*dc*evec(nz,m)*evec(nz,p)*dz(nz)* ...
            ksqd_.*real(conj(psikm(:,:,p)).*psikm(:,:,m));
      end
      Hm(:,:,p) = -2*real(nu*ksqd_.^hve.*conj(psikm(:,:,p)).*...
                        (ksqd_+kd(p)^2).*psikm(:,:,p));
   end
end

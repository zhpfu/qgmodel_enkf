function Gm = gen_mode(psikm,dz,rho,F,ubar,e);

% Gm =  GEN_MODE(psikm,dz,rho,F,ubar,e) 
%     Calculates E budget spectra for the zonal shear forcing (G)
%     Uses spectral streamfunction (psik) and PV (qk) fields, as 
%     well as layer thicknesses (dz), densities (rho), and mean  
%     zonal velocities (ubar), the Froude number (F) and the
%     triple interaction coefficient matrix (e) (size nz,nz,nz).  
%
%     See also BUDGET_Z.

nkx = size(psikm,1); nky = size(psikm,2);  nz = size(psikm,3);
kmax = nky-1;

if (length(dz)~=nz|length(rho)~=nz|length(ubar)~=nz)
   error('Inconsistent number of layers in inputs');
end
if (nkx+1~=nky*2) 
   error('These are not spectral fields')
end

Gm = zeros(size(psikm)); 

[kd,evec] = vmodes(dz,rho,F);

um = evec'*(dz.*ubar);           % modal projection of mean shear
[kx_,ky_] = ndgrid(-kmax:kmax,0:kmax);
ksqd_ = kx_.^2+ky_.^2;

cntr=0; 
disp(strcat('Need ',num2str(length(find(abs(e)>100*eps))),' cycles...'))

% All energetics multiplied by two since only half spectral field is used

for p=1:nz
   for m=1:nz
      for n=1:nz
         if (abs(e(m,n,p))>100*eps)
           cntr=cntr+1;
           disp(num2str(cntr))
           Gm(:,:,p) = Gm(:,:,p)+2*real(e(m,n,p).*um(m).*...
              conj(psikm(:,:,p)).*i.*kx_.*...
              (kd(m)^2-kd(n)^2-ksqd_).*psikm(:,:,n));
         end
      end
   end
end


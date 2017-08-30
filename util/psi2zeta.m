function zetak = psi2zeta(psik)

nz = size(psik,3); kmax = size(psik,2)-1;

[kx_,ky_,z_] = ndgrid(-kmax:kmax,0:kmax,1:nz);

for t = 1:size(psik,4)
  zetak(:,:,:,t) = -(kx_.^2+ky_.^2).*psik(:,:,:,t);
end


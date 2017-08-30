function tempk = psi2temp(psik)

kmax = size(psik,2)-1;
nz = size(psik,3);

[kx_,ky_,z_] = ndgrid(-kmax:kmax,0:kmax,1:nz);

for t = 1:size(psik,4)
  tempk(:,:,:,t) = -sqrt(kx_.^2+ky_.^2).*psik(:,:,:,t);
end

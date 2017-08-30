function vk=psi2uv(psik);

kmax = size(psik,2)-1; nz=size(psik,3);

if (mod(kmax,2)==0)
  disp('This is probably not a SPECTRAL psi field...')
end

[kx_,ky_,z_] = ndgrid(-kmax:kmax,0:kmax,1:nz);

for t = 1:size(psik,4)
  vk(:,:,:,t) =  i*kx_.*psik(:,:,:,t);
end

function zetak=uv2zeta(uk,vk)

kmax = size(uk,2)-1; nz=size(uk,3);
[kx_,ky_,z_] = ndgrid(-kmax:kmax,0:kmax,1:nz);

for t = 1:size(uk,4)
  zetak(:,:,:,t) = i*kx_.*vk(:,:,:,t)-i*ky_.*uk(:,:,:,t);
end



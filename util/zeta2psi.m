function psik = zeta2psi(zetak)

nz = size(zetak,3); kmax = size(zetak,2)-1;

[kx_,ky_,z_] = ndgrid(-kmax:kmax,0:kmax,1:nz);

k2_ = kx_.^2+ky_.^2;
k2_(kmax+1,1,:) = 1;    % artificially set irrelevant point to 1 to 
                      % avoid singularity in inversion

for t = 1:size(zetak,4)
  psik(:,:,:,t) = -(1./k2_).*zetak(:,:,:,t);
end


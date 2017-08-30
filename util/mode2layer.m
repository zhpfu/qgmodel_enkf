function fl = mode2layer(fm,dz,rho);

%  fl = MODE2LAYER(fm,dz,rho) 
%     Calculate projection of 3-d field fm given on modes onto layers.
%     Fields can be either spectral or physical.
%
%     See also LAYER2MODE, VMODES.

nx = size(fm,1); ny = size(fm,2); nz = size(fm,3); nt = size(fm,4);

if (length(dz)~=nz), error('Incongruent vectors'); end

[kd,evec] = vmodes(dz,rho,1);

for i = 1:nx
  for j = 1:ny
    for t = 1:nt
      fl(i,j,:,t) = evec*squeeze(fm(i,j,:,t));
    end
  end
end

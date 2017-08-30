function fm = layer2mode(fl,dz,rho);

%  fm = LAYER2MODE(fl,dz,rho) Calculates
%     the projection of 3-d field fl given on layers of thickness
%     dz onto modes given by vmode.  Fields can be either spectral 
%     or physical.
%
%     See also MODE2LAYER, VMODES.

nx = size(fl,1); ny = size(fl,2); nz = size(fl,3);

%if (length(dz)~=nz), error('Incongruent vectors');, end

dz = dz/sum(dz);          % fractional layer thicknesses
[kd,evec] = vmodes(dz(:),rho(:),1);

for m = 1:nz
   evecn(:,m) = evec(:,m).*dz(:);
end

fm = zeros(size(fl));

for i = 1:nx
  for j = 1:ny
    for t = 1:size(fl,4)
      fm(i,j,:,t) = evecn'*squeeze(fl(i,j,:,t));
    end
  end
end


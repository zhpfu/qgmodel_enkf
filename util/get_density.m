function [densitym,density] = get_density(psim,dz,rho,res);

% [densitym,density] = get_density(psim,dz,rho)  Calculate eddy density
%   rho' = rho-<rho>(z) = -dpsi/dz.  Use vertical modes to
%   calculate dpsi/dz = Sum_m(Psim_m*dphi_m/dz).
%   Optional density is z-coord
%   density field.  psim is modal psi field and densitym is modal density. 

nx=size(psim,1); ny=size(psim,2); nz = length(dz);
z  = get_z(dz);
a = dvmodedz_coefs(dz,rho,res);

disp('Calculating modal density field')
densitym = zeros(size(psim));
for i=1:nx
  for j=1:ny
      densitym(i,j,:) = -squeeze(psim(i,j,:))'*a;
  end
end

if nargout>1 
  disp('Calculating z-coord density') 
  density = mode2layer(densm,dz,rho)
end
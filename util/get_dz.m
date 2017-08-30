function dz = get_dz(z);

% dz = GET_DZ(z)  
%     Calculates layer thicknesses from depths z.
%     Assumes z(i) is distance from center of ith layer to surface.
%
%     See also GET_Z.

nz=length(z);
dz(1) = 2*z(1);
for n=2:nz
  dz(n) = 2*(z(n)-sum(dz(1:n-1)));
end
dz=dz';
  
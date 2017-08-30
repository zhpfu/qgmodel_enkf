function z = get_z(dz);

% z = GET_Z(dz)  
%     Calculates depth function z from layer thicknesses 
%     dz (assumes z(i) is distance from center of ith layer to 
%     surface).
%
%     See also GET_DZ.

nh=length(dz);
z(1) = dz(1)/2;
for n=2:nh
  z(n) = sum(dz(1:n-1))+dz(n)/2;
end
z=-z(:);

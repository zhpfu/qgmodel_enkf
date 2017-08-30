function [outf,zout] = interp3dfield(field,zin,N,method);

% [outf,zout] = INTERP3DFIELD(field,zin,N,method) 
%     Uses INTERP1 to interpolate 3d field in the vertical.  
%     No horizontal interpolation.  Data in field given at 
%     points 'zin' in the 3rd dimension, and use 'method' 
%     to interpolate to 'N' equally spaced vertical levels.
%
%     See also INTERP1.

dz(1:N,1)=1/N;
zout = get_z(dz);
for x = 1:size(field,1)
   for y = 1:size(field,2)
      outf(x,y,:)=interp1(zin,squeeze(field(x,y,:)),zout,method);
   end
end

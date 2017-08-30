function [fs,zs] = zgridshift(f,z,opt);

%  [fs,zs] = zgridshift(f,z)  NOT FINISHED
%
%     Shift function f, whose values correspond to coordinates in
%     z (generally non-uniformly spaced), to a new grid zs that is
%     shifted by a half space.  The default returns a vector whose
%     length is length(f)-1.  Optional input OPT is interpreted as
%     follows:
%     OPT = 0:  default (length(fs) = length(f) - 1)
%     OPT = 1:  extrapolate above top point by half the spacing
%               between the first to z values (length(fs)=length(f)) 
%     OPT = 2:  extrapolate below the bottom point in the same way
%     OPT = 3:  extrapolate both ends (length(fs)=length(f)+1)
%
%     Note that the index is assumed to start at the largest value
%     of z, since we are typically looking at ocean data, where
%     convention dictates that z=0 is at the surface, and that the
%     upper layer has the lowest index value.
%
% NOT FINISHED

if (length(f)~=length(z)), error('Length f ~= length z'), end
nz = length(f)

% Extrapolate f to middle of each layer

switch opt
case 0
  zs = (z(2:end)-z(1:end-1))/2;
  dz = z(2:end)-z(1:end-1);
  df = f(2:end)-f(1:end-1);
  fs = f(2:end) + (zs-z(1:end-1)).*df./dz;
case 1
  dz = zeros(length(zi));
  dz(1) = abs(z(1));
  dz(2:nz) = abs(z(2:end)-z(1:end-1));
  fs = zeros(size(f));
  fs(1) = f(1) - (f(2)-f(1))*dz(1)/(2*dz(2));
  fs(2:end) = f(2:end)-.5*(f(2:end)-f(1:end-1));
case 2
case 3
  
end

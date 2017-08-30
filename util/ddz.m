function fz = ddz(f,z)

% fz = DDZ(f,z)  Calculates vertical derivative at same discretization 
%     points as f is specified on.  Assumes f(0)=f(1) and f(N+1)=f(N).
%     Coordinate positions of f given in vector z.  f can be either
%     1D or 3D, where in the latter case it is assumed that the
%     third dimension is the z-coordinate.

switch ndims(f)
  case 2    % Stupid matlab doens't think anything has ndim = 1 or 0...
    nz = length(f);
    fz = zeros(size(f));
    fz(1) = (f(1)-f(2))/(z(1)-z(2));
    fz(2:nz-1) = (f(1:nz-2)-f(3:nz))./(z(1:nz-2)-z(3:nz));
    fz(nz) = (f(nz-1)-f(nz))/(z(nz-1)-z(nz));
  case 3
    nz = size(f,3);
    fz = zeros(size(f));
    fz(:,:,1) = (f(:,:,1)-f(:,:,2))/(z(1)-z(2));
    for kk=2:nz-1
      fz(:,:,kk)  = (f(:,:,kk-1)-f(:,:,kk+1))/(z(kk-1)-z(kk+1));
    end
    fz(:,:,nz) = (f(:,:,nz-1)-f(:,:,nz))/(z(nz-1)-z(nz));
end
